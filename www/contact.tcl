ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {party_id:integer,notnull}
} -validate {
    contact_exists -requires {party_id} {
	if { ![contact::exists_p -party_id $party_id] } {
	    ad_complain "The contact specified does not exist"
	}
    }
}

set object_type [contact::type -party_id $party_id]
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

if { $object_type == "person" } {
    set hidden_attributes [list first_names last_name]
} elseif { $object_type == "organization" } {
    set hidden_attributes [list name]
}


set groups_belonging_to [db_list get_party_groups { select group_id from group_distinct_member_map where member_id = :party_id }]
if { [lsearch $groups_belonging_to -2] < 0 } {
    ad_return_error "This users has not been approved" "This user is awaiting administrator approval"
}
set ams_forms [list]
foreach group [contact::groups -expand "all" -privilege_required "read"] {
    set group_id [lindex $group 1]
    if { [lsearch $groups_belonging_to $group_id] >= 0 } {
        lappend ams_forms "${package_id}__${group_id}"
    }
}

set revision_id [contact::live_revision -party_id $party_id]

multirow create attributes section attribute value
foreach form $ams_forms {
    set values [ams::values -package_key "contacts" -object_type $object_type -list_name $form -object_id $revision_id -format "html"]
    foreach {section attribute_name pretty_name value} $values {
        if { [lsearch $hidden_attributes $attribute_name] < 0 } {
            multirow append attributes $section $pretty_name $value
        }
    }
}


set package_url [ad_conn package_url]

multirow create rels relationship contact contact_url attribute value
db_foreach get_relationships {} {
    set contact_url [contact::url -party_id $other_party_id]
    multirow append rels $role_singular $other_name $contact_url {} {}
    # NOT YET IMPLEMENTED - Checking to see if role_singular or role_plural is needed

    if { [ams::list::exists_p -package_key "contacts" -object_type ${rel_type} -list_name ${package_id}] } {
        set details_list [ams::values -package_key "contacts" -object_type $rel_type -list_name $package_id -object_id $rel_id -format "text"]
        if { [llength $details_list] > 0 } {
            foreach {section attribute_name pretty_name value} $details_list {
                multirow append rels $role_singular $other_name $contact_url $pretty_name $value
            }
        }
    }
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

# Get the linked projekt_id to display the subprojects if projects is installed

if { [string is false [empty_string_p [info procs "::application_data_link::get_linked"]]] } {

    set project_id [application_data_link::get_linked -from_object_id $party_id -to_object_type "content_item"]

    if {$project_id > 0} {
	set package_id [acs_object::get_element -object_id $project_id -element package_id]
	set base_url [apm_package_url_from_id $package_id]
	set project_url [export_vars -base $base_url {{project_item_id $project_id}}]
    } else {
	set project_url ""
    }

    set projects_enabled_p 1
} else {
    set projects_enabled_p 0
}


ad_return_template
