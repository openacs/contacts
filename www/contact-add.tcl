ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {object_type "person"}
} -validate {
    valid_type -requires {object_type} {
	if { [lsearch [list organization person] $object_type] < 0 } {
	    ad_complain "You have not specified a valid contact type"
	}
    }
}

set package_id [ad_conn package_id]
set form "$package_id\__[contacts::default_group]"

set form_elements [ams::ad_form::elements -package_key "contacts" -object_type $object_type -list_name $form -key party_id]
lappend form_elements {object_type:text(hidden)}

if { $object_type == "person" } {
    set title "Add a Person"
} else {
    set title "Add an Organization"
}

set user_id [ad_conn user_id]
set context [list $title]


ad_form -name party_ae \
    -mode "edit" \
    -cancel_label "Cancel" \
    -cancel_url [export_vars -base contact -url {party_id}] \
    -edit_buttons [list [list Save save] [list "Save and Add Another" save_add_another]] \
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
	    ad_return_error "Configuration Error" "Some of the required elements for this form are missing. Please contact an administrator and make sure that the following attributes are included in the default group's form for this object type:<ul><li>[join $missing_elements "</li><li>"]</li></ul>" 
	}
    } -edit_request {
    } -on_submit {

	# MGEDDERT: I NEED TO MAKE SURE THAT VALUES THAT NEED TO BE UNIQUE ARE UNIQUE

	# for orgs name needs to be unique
	# for all of them email needs to be unique

	if { $object_type == "person" } {
	    if { ![exists_and_not_null first_names] } {
		template::element::set_error party_ae first_names "First Names is required"
	    }
	    if { ![exists_and_not_null last_name] } {
		template::element::set_error party_ae last_name "Last Name is required"
	    }
	} else {
	    if { ![exists_and_not_null name] } {
		template::element::set_error party_ae name "Name is required"
	    }
	}
	if { ![template::form::is_valid party_ae] } {
	    break
	}

    } -new_data {

	if { $object_type == "person" } {
	    if { [string is false [exists_and_not_null email]] } {
		set email "$party_id@bogusdomain.com"
		set username $party_id
	    }
	    if { [string is false [exists_and_not_null username]] } {
		set username $email
	    }
	    if { [string is false [exists_and_not_null url]] } {
		set url ""
	    }
	    db_transaction {
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
		

		if { "$email" == "$party_id@bogusdomain.com" } {
		    # we need to delete the party email address
		    party::update -party_id $party_id -email "" -url [db_string get_url { select url from parties where party_id = :party_id } -default {}]
		}
		
		if { [string equal $creation_info(creation_status) "ok"] } {
		    group::add_member \
			-group_id [application_group::group_id_from_package_id -package_id [ad_conn subsite_id]] \
			-user_id $party_id \
			-rel_type "membership_rel"
		} else {
		    ns_log warning "contacts/www/contact add user error: \n creation_status \n $creation_info(creation_status) \n creation_message \n $creation_info(creation_message) \n element_messages \n $creation_info(element_messages)"
		    error $creation_info(creation_status)
		}
	    } on_error {
		ad_return_error "Error" "The error was: $errmsg"
	    }
	} else {
	    # name is not included in this list because its required and checked for above
	    set elements_for_insert [list legal_name notes reg_number email url]
	    foreach element_for_insert $elements_for_insert {
		if { [string is false [exists_and_not_null $element_for_insert]] } {
		    set $element_for_insert ""
		}
	    }
	    set peeraddr [ad_conn peeraddr]

            db_transaction {
		set party_id [db_exec_plsql do_insert_org {
			select organization__new ( 
					  :legal_name,
					  :name,
					  :notes,
					  null,
					  null,
					  :reg_number,
					  :email,
					  :url,
					  :user_id,
					  :peeraddr,
					  :package_id
					  )
		    }]
		set group_id [application_group::group_id_from_package_id -package_id [ad_conn subsite_id]]
                set rel_id [db_string insert_rels { select acs_rel__new (NULL::integer,'organization_rel',:group_id,:party_id,NULL,:user_id,:peeraddr) as org_rel_id }]
		#            db_1row insert_member { select acs_rel__new (NULL::integer,'membership_rel',:group_id,:party_id,NULL,:user_id,:peeraddr) }
                db_dml insert_state { insert into membership_rels (rel_id,member_state) values (:rel_id,'approved') }
            }
	}

	contact::special_attributes::ad_form_save -party_id $party_id -form "party_ae"
	ams::ad_form::save -package_key "contacts" \
	    -object_type $object_type \
	    -list_name $form \
	    -form_name "party_ae" \
	    -object_id [contact::revision::new -party_id $party_id]

	callback contact::contact_new_form -package_id $package_id -contact_id $party_id -form party_ae -object_type $object_type

	util_user_message -html -message "The $object_type <a href=\"contact?party_id=$party_id\">[contact::name -party_id $party_id]</a> was added"

    } -after_submit {
        if { [exists_and_not_null formbutton\:save_add_another] } {
            ad_returnredirect "contact-add?object_type=${object_type}"
        } else {
            ad_returnredirect "./"
        }
	ad_script_abort
    }



ad_return_template
