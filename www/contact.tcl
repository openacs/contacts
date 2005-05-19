ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {party_id:integer,notnull}
} -validate {
    contact_exists -requires {party_id} {
	if { ![contact::exists_p -party_id $party_id] && ![ad_form_new_p -key party_id] } {
	    ad_complain "The contact specified does not exist"
	}
    }
}

set object_type [contact::type -party_id $party_id]
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

set groups_belonging_to [db_list get_party_groups { select group_id from group_distinct_member_map where member_id = :party_id }]
if { [lsearch $groups_belonging_to -2] < 0 } {
    ad_return_error "This users has not been approved" "This user is awaiting administrator approval"
}
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

ad_form -name party_ae \
    -mode "display" \
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
	    ad_return_error "Configuration Error" "Some of the required elements for this form are missing. Please contact an administrator and make sure that the following attributes are included:<ul><li>[join $missing_elements "</li><li>"]</li></ul>" 
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
    } -new_data {
    } -edit_data {
    } -after_submit {
        ad_returnredirect "./"
    }


if { $object_type == "person" } {
    template::element::set_properties party_ae first_names widget hidden
    template::element::set_properties party_ae last_name widget hidden
} else {
    template::element::set_properties party_ae name widget hidden
}
foreach element [template::form::get_elements party_ae] {
    # ns_log notice $element [template::element::get_value party_ae $element]
    if { [template::element::get_value party_ae $element] == "" } {
        template::element::set_properties party_ae $element widget hidden
    }
}
# now we clean up the section headings (if necessary)
foreach element [template::form::get_elements party_ae] {
    set section [template::element::get_property party_ae $element section]
    set value   [template::element::get_value party_ae $element]
    if { ( $value == "" || $element == "first_names" || $element == "last_name" ) && $section != "" } {
        # there is a section heading for a "non-existant" element
        set carry_over_section $section
        template::element::set_properties party_ae $element section ""
    } else {
        if { [exists_and_not_null carry_over_section] && $value != "" && [template::element::get_property party_ae $element widget] != "hidden" } {
            if { ![exists_and_not_null section] } { set section $carry_over_section }
            template::element::set_properties party_ae $element section $section
            set carry_over_section ""
            set section ""
        }
    }
    set sec [template::element::get_property party_ae $element section]
}






set live_revision [contact::live_revision -party_id $party_id]
if { [exists_and_not_null live_revision] } {
    set update_date [db_string get_update_date { select to_char(publish_date,'Mon FMDD, YYYY at FMHH12:MIam') from cr_revisions where revision_id = :live_revision } -default {}]
}


if { [site_node::get_package_url -package_key "tasks"] != "" } {
    set tasks_enabled_p 1
} else {
    set tasks_enabled_p 0
}



ad_return_template
