ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {object_type "person"}
    {group_id ""}
} -validate {
    valid_type -requires {object_type} {
	if { [lsearch [list organization person] $object_type] < 0 } {
	    ad_complain "[_ contacts.lt_You_have_not_specifie]"
	}
    }
}

set package_id [ad_conn package_id]

set form_elements {party_id:key}
lappend form_elements {object_type:text(hidden)}

set default_group_id [contacts::default_group -package_id $package_id]
set application_group_id [application_group::group_id_from_package_id -package_id [ad_conn subsite_id]]

set groups [list $default_group_id]
if {![empty_string_p group_id] && $group_id != $default_group_id} {
    lappend groups $group_id
    lappend form_elements {group_id:text(hidden) {value $group_id}}
}

# Save Group Information
if {$default_group_id != $application_group_id} {
    lappend groups $application_group_id
}


foreach group [contact::groups -expand "all" -privilege_required "read"] {
    set group_id [lindex $group 1]
    if { [lsearch $groups $group_id] >= 0 } {

	# Setup CATEGORY entry widgets in here
	set category_elements ""
        lappend ams_forms "${package_id}__${group_id}"
    }
}

foreach form $ams_forms {
    append form_elements " "
    append form_elements [ams::ad_form::elements -package_key "contacts" -object_type $object_type -list_name $form]
}

# Append the option to create a user who get's a welcome message send
# Furthermore set the title.

if { $object_type == "person" } {
    lappend form_elements {create_user_p:text(radio) \
			       {label "[_ contacts.Create_user]"}\
			       {options {{[_ acs-kernel.common_Yes] "t"} {[_ acs-kernel.common_no] "f"}}} \
			       {values "f"}
    }
    set title "[_ contacts.Add_a_Person]"
} else {
    set title "[_ contacts.Add_an_Organization]"
}

# Append the category Elements at the end. In the long run we should
# change this so you could mix/match category elements with the
# elements in AMS, but we are not there.
if {![empty_string_p $category_elements]} {
    lappend form_elements $category_elements
}

set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]
set context [list $title]

ad_form -name party_ae \
    -mode "edit" \
    -cancel_label "[_ contacts.Cancel]" \
    -cancel_url [export_vars -base contact -url {party_id}] \
    -edit_buttons [list [list "[_ acs-kernel.common_Save]" save] [list "[_ contacts.Save_and_Add_Another]" save_add_another]] \
    -form $form_elements

callback contact::contact_form -package_id $package_id -form party_ae -object_type $object_type

ad_form -extend -name party_ae \
    -on_request {

	if { $object_type == "person" }	{
	    set required_attributes [list first_names last_name email]
	} else {
	    set required_attributes [list name]
	}

	set missing_elements [list]
	foreach attribute $required_attributes {
	    if { [string is false [template::element::exists party_ae $attribute]] } {
		lappend missing_elements $attribute
	    }
	}
	# make the error message multiple item aware
	if { [llength $missing_elements] > 0 } {
            ad_return_error "[_ contacts.Configuration_Error]" "[_ contacts.lt_Some_of_the_required_]<ul><li>[join $missing_elements "</li><li>"]</li></ul>"
	}
    } -edit_request {
    } -on_submit {

	# MGEDDERT: I NEED TO MAKE SURE THAT VALUES THAT NEED TO BE UNIQUE ARE UNIQUE

	# for orgs name needs to be unique
	# for all of them email needs to be unique

	if { $object_type == "person" } {
	    if { ![exists_and_not_null first_names] } {
		template::element::set_error party_ae first_names "[_ contacts.lt_First_Names_is_requir]"
	    }
	    if { ![exists_and_not_null last_name] } {
		template::element::set_error party_ae last_name "[_ contacts.lt_Last_Name_is_required]"
	    }
	} else {
	    if { ![exists_and_not_null name] } {
		template::element::set_error party_ae name "[_ contacts.Name_is_required]"
	    }
	}
	if { ![template::form::is_valid party_ae] } {
	    break
	}

    } -new_data {

	if { $object_type == "person" } {
	    if { ![exists_and_not_null email] } {
		set email "$party_id@bogusdomain.com"
		set username $party_id
	    }
	    if { ![exists_and_not_null username] } {
		set username $email
	    }
	    if { ![exists_and_not_null url] } {
		set url ""
	    }

	    if {$create_user_p == "f"} {
		# Initialize Party Entry
		# We do not want to create a new user with each contact
		template::form create add_party
		template::element create add_party email -value "$email"
		template::element create add_party first_names -value "$first_names"
		template::element create add_party last_name -value "$last_name"
		template::element create add_party url -value "$url"
		
		set party_id [party::new -party_id $party_id -form_id add_party person]

	    } else {
		
                array set creation_info [auth::create_user \
                                             -user_id $party_id \
                                             -verify_password_confirm \
                                             -username $email \
                                             -email $email \
                                             -first_names $first_names \
                                             -last_name $last_name \
                                             -screen_name "" \
                                             -password "" \
                                             -password_confirm "" \
                                             -url $url \
                                             -secret_question "" \
                                             -secret_answer ""]
		if { ![string equal $creation_info(creation_status) "ok"] } {
		    ad_return_error "Error" "contacts/www/contact add user error: \n creation_status \n $creation_info(creation_status) \n creation_message \n $creation_info(creation_message) \n element_messages \n $creation_info(element_messages)"
                    error $creation_info(creation_status)
                }
	    }


	    if { "$email" == "$party_id@bogusdomain.com" } {
		    # we need to delete the party email address
		party::update -party_id $party_id -email "" -url $url
	    }


	    foreach group_id $groups {
		group::add_member \
		    -group_id $group_id \
		    -user_id $party_id \
		    -rel_type "membership_rel"
	    }
	    
	    
	} else {
	    
	    # Initialize Party Entry for organization
	    set party_id [organizations::new -organization_id $party_id -name $name]

	    foreach group_id $groups {
		if {![empty_string_p $group_id]} {

		    # relation-add does not work as there is no
		    # special procedure for organizations at the moment.
		    set rel_id [db_string insert_rels { select acs_rel__new (NULL::integer,'organization_rel',:group_id,:party_id,NULL,:user_id,:peeraddr) as org_rel_id }]
		    db_dml insert_state { insert into membership_rels (rel_id,member_state) values (:rel_id,'approved') }
		}
	    }
	}
	
	# Save the contact information
	# No clue why this is not part of the db_transaction though ....
	contact::special_attributes::ad_form_save -party_id $party_id -form "party_ae"
        set revision_id [contact::revision::new -party_id $party_id]
        foreach form $ams_forms {
            ams::ad_form::save -package_key "contacts" \
                -object_type $object_type \
                -list_name $form \
                -form_name "party_ae" \
                -object_id $revision_id
        }



	callback contact::contact_new_form -package_id $package_id -contact_id $party_id -form party_ae -object_type $object_type

	# Add the user to the
	util_user_message -html -message "The $object_type <a href=\"contact?party_id=$party_id\">[contact::name -party_id $party_id]</a> was added"

    } -after_submit {
        if { [exists_and_not_null formbutton\:save_add_another] } {
            ad_returnredirect [export_vars -base "contact-add" -url {object_type group_id}]
        } else {
            ad_returnredirect [export_vars -base "." -url {{query_id $group_id}}] 
        }
	ad_script_abort
    }



ad_return_template
