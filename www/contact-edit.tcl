ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {party_id:integer,notnull}
} -validate {
    contact_exists -requires {party_id} {
	if { ![contact::exists_p -party_id $party_id] && ![ad_form_new_p -key party_id] } {
	    ad_complain "[_ contacts.lt_The_contact_specified]"
	}
    }
}


set object_type [contact::type -party_id $party_id]
#set attach_url [attachments::add_attachment_url \
#                      -object_id $party_id \
#                      -return_url [contact::url -party_id $party_id] \
#                      -pretty_name [contact::name -party_id $party_id]]

 

set object_type [contact::type -party_id $party_id]
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

# set form_elements [ams::ad_form::elements -package_key "contacts" -object_type $object_type -list_name "${object_type}_[ad_conn package_id]" -key party_id]

set groups_belonging_to [db_list get_party_groups { select group_id from group_distinct_member_map where member_id = :party_id }]

set form_elements {party_id:key}
lappend form_elements {object_type:text(hidden)}


set ams_forms [list]
foreach group [contact::groups -expand "all" -privilege_required "read"] {
    set group_id [lindex $group 1]
    if { [lsearch $groups_belonging_to $group_id] >= 0 } {
        lappend ams_forms "${package_id}__${group_id}"
    }
}

foreach form $ams_forms {
    append form_elements " "
    append form_elements [ams::ad_form::elements -package_key "contacts" -object_type $object_type -list_name $form]
}
#ad_return_error "ERROR" $form_elements
ad_form -name party_ae \
    -mode "edit" \
    -form $form_elements \
    -has_edit "1" \
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
	    ad_return_error "[_ contacts.Configuration_Error]" "[_ contacts.lt_Some_of_the_required__1]"</li><li>"]</li></ul>" 
	}

    } -edit_request {
        set revision_id [contact::live_revision -party_id $party_id]
        foreach form $ams_forms {
            ams::ad_form::values -package_key "contacts" \
                -object_type $object_type \
                -list_name $form \
                -form_name "party_ae" \
                -object_id $revision_id
        }
        contact::special_attributes::ad_form_values -party_id $party_id -form "party_ae"
        
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
    } -edit_data {

	contact::special_attributes::ad_form_save -party_id $party_id -form "party_ae"
        set revision_id [contact::revision::new -party_id $party_id]
        foreach form $ams_forms {
            ams::ad_form::save -package_key "contacts" \
                -object_type $object_type \
                -list_name $form \
                -form_name "party_ae" \
                -object_id $revision_id
        }
	util_user_message -html -message "The $object_type <a href=\"contact?party_id=$party_id\">[contact::name -party_id $party_id]</a> was updated"

    } -after_submit {
        ad_returnredirect [contact::url -party_id $party_id]
	ad_script_abort
    }












ad_return_template
