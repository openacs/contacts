ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {object_type "person"}
    {group_ids ""}
    {rel_type ""}
    {object_id_two ""}
} -validate {
    valid_type -requires {object_type} {
	if { [lsearch [list organization person] $object_type] < 0 } {
	    ad_complain "[_ contacts.lt_You_have_not_specifie]"
	}
    }
}

set group_list [concat [list [list [_ contacts.All_Contacts] "-2" "0"]] [contact::groups]]
if {[empty_string_p $group_ids] && [llength $group_list] > 1} {
    ad_returnredirect "[export_vars -base "../select-groups" -url {object_type}]"
} elseif { [lsearch $group_ids "-2"] < 0 } {
    # an invalid group_ids list has been specified or they do not have permission to add person
    ad_return_error "[_ contacts.lt_Insufficient_Permissi]" "[_ contacts.lt_You_do_not_have_permi]"
}

set path_info [ad_conn path_info]
if { $path_info == "add/person" } {
    set object_type "person"
} elseif { $path_info == "add/organization" } {
    set object_type "organization"
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]

set form_elements {party_id:key}
lappend form_elements {object_type:text(hidden)}
lappend form_elements {rel_type:text(hidden),optional}
lappend form_elements {object_id_two:text(hidden),optional}

set default_group_id [contacts::default_group -package_id $package_id]
set default_group_id "-2"
set application_group_id [application_group::group_id_from_package_id -package_id [ad_conn subsite_id]]

if {[lsearch $group_ids $default_group_id] == -1} {
    lappend group_ids $default_group_id
}

lappend form_elements {group_ids:text(hidden)}

# Save Group Information
if {[lsearch $group_ids $application_group_id] == -1} {
    lappend group_ids $application_group_id
}

set group_list [contact::groups -expand "all" -privilege_required "read"]
set group_list "{{All Contacts} -2 0} $group_list"


ad_form -name party_ae \
    -mode "edit" \
    -cancel_label "[_ contacts.Cancel]" \
    -cancel_url [export_vars -base contact -url {party_id}] \
    -edit_buttons [list [list "[_ acs-kernel.common_Save]" save] ]\
    -form $form_elements

foreach group $group_list {
    set group_id [lindex $group 1]
    if { [lsearch $group_ids $group_id] >= 0 } {

	ad_form -extend -name party_ae -form [ams::ad_form::elements -package_key "contacts" -object_type $object_type -list_name "${package_id}__${group_id}"]
	
	# Add the category widget(s)
	set element_name "category_ids$group_id"
	if {$group_id < 0} {
	    set element_name "category_ids[expr 0 - $group_id]"
	}
	
	category::ad_form::add_widgets \
	    -container_object_id $group_id \
	    -categorized_object_id $user_id \
	    -form_name party_ae \
	    -element_name $element_name
	
    }
}

# Append relationship attributes

if {[exists_and_not_null rel_type]} {
    ad_form -extend -name party_ae -form [ams::ad_form::elements -package_key "contacts" -object_type $rel_type -list_name [ad_conn package_id]]
}

# Append the option to create a user who get's a welcome message send
# Furthermore set the title.

if { $object_type == "person" } {
     ad_form -extend -name party_ae \
	 -form {
	     {create_user_p:text(radio) 
		 {label "[_ contacts.Create_user]"} 
		 {options {{[_ acs-kernel.common_Yes] "t"} {[_ acs-kernel.common_no] "f"}}} 
		 {values "f"}
	     }
	 }
    set title "[_ contacts.Add_a_Person]"
} else {
    set title "[_ contacts.Add_an_Organization]"
}

set context [list $title]

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
	
	# Add the new categories
	
	set cat_ids [list]
	foreach group_id $group_ids {
	    set element_name "category_ids$group_id"
	    if {$group_id < 0} {
		set element_name "category_ids[expr - $group_id]"
	    }
	    
	    set cat_ids [concat $cat_ids \
			     [category::ad_form::get_categories \
				  -container_object_id $group_id \
				  -element_name $element_name]]
	}
	
	category::map_object -remove_old -object_id $user_id $cat_ids


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


	    foreach group_id $group_ids {
		group::add_member \
		    -group_id $group_id \
		    -user_id $party_id \
		    -rel_type "membership_rel"
	    }
	    

	    callback contact::person_new -package_id $package_id -contact_id $party_id
	    
	} else {
	    
	    # Initialize Party Entry for organization
	    set party_id [organization::new -organization_id $party_id -name $name]

	    foreach group_id $group_ids {
		if {![empty_string_p $group_id]} {

		    # relation-add does not work as there is no
		    # special procedure for organizations at the moment.
		    set rel_id [db_string insert_rels { select acs_rel__new (NULL::integer,'organization_rel',:group_id,:party_id,NULL,:user_id,:peeraddr) as org_rel_id }]
		    db_dml insert_state { insert into membership_rels (rel_id,member_state) values (:rel_id,'approved') }
		}
	    }

	    callback contact::organization_new -package_id $package_id -contact_id $party_id -name $name
	}
	
	# Save the contact information
	# No clue why this is not part of the db_transaction though ....
	contact::special_attributes::ad_form_save -party_id $party_id -form "party_ae"
        set revision_id [contact::revision::new -party_id $party_id]
        foreach group_id $group_ids {
            ams::ad_form::save -package_key "contacts" \
                -object_type $object_type \
                -list_name "${package_id}__${group_id}" \
                -form_name "party_ae" \
                -object_id $revision_id
	    # execute group specific callbacks
	    group::get -group_id $group_id -array group_array
	    set group_name ${group_array(group_name)}
	    regsub -all " " $group_name "_" group_name
	    regsub -all {[^-a-zA-Z0-9_]} $group_name "" group_name
	    
	    if {[info exists contact::${object_type}_${group_array(group_name)}_new]} {
		callback contact::${object_type}_${group_array(group_name)}_new -package_id $package_id -contact_id $party_id
	    }
	}
	
	# Insert the relationship
	if {[exists_and_not_null rel_type] && [exists_and_not_null object_id_two]} {
	    set rel_id {}
	    set context_id {}
	    set creation_user [ad_conn user_id]
	    set creation_ip [ad_conn peeraddr]
	    set rel_id [db_exec_plsql create_rel "select acs_rel__new (
                     :rel_id,
                     :rel_type,
                     :party_id,
                     :object_id_two,
                     :context_id,
                     :creation_user,
                     :creation_ip  
                    )"]
	    
	    if {[exists_and_not_null rel_type]} {
		ams::ad_form::save -package_key "contacts" \
		    -object_type $rel_type \
		    -list_name [ad_conn package_id] \
		    -form_name "party_ae" \
		    -object_id $rel_id
	    }
	}

	# Add the user to the
	util_user_message -html -message "The $object_type <a href=\"contact?party_id=$party_id\">[contact::name -party_id $party_id]</a> was added"

    } -after_submit {
	contact::flush -party_id $party_id
	contact::search::flush_results_counts
	#the formbutton does not work. No clue how to fix it.
#        if { [exists_and_not_null formbutton\:save_add_another] } {
#            ad_returnredirect [export_vars -base "/contacts/$object_type/add" -url]
#        } else {
	if {[empty_string_p $object_id_two]} {
	    ad_returnredirect [contact::url -party_id $party_id]
#            ad_returnredirect [export_vars -base "/contacts" -url {{query_id $group_id}}] 
	} else {
	    ad_returnredirect "/contacts/$object_id_two"
	}
	    #        }
	ad_script_abort
    }

if { $object_type == "person" && [parameter::get -boolean -parameter "AllPeopleAreUsers" -default "0"] } {
    template::element set_properties party_ae create_user_p widget hidden
    template::element set_value party_ae create_user_p "1"
}
ad_return_template
