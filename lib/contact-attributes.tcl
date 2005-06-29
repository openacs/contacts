# packages/contacts/lib/contact-attributes.tcl
#
# Include for the contact attributes
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-06-21
# @arch-tag: 1df33468-0ff5-44e2-874a-5eec78747b8c
# @cvs-id $Id$

foreach required_param {party_id} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {package_id hidden_attributes} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

if {[empty_string_p $package_id]} {
    set package_id [ad_conn package_id]
}

set object_type [util_memoize [list acs_object_type $party_id]]
if { $object_type == "user" } {
    set object_type "person"
}
set groups_belonging_to [db_list get_party_groups { select group_id from group_distinct_member_map where member_id = :party_id }]
if { [lsearch $groups_belonging_to -2] < 0 } {
    ad_return_error "[_ contacts.lt_This_users_has_not_be]" "[_ contacts.lt_This_user_is_awaiting]"
}
set ams_forms [list "${package_id}__-2"]
foreach group [contact::groups -expand "all" -privilege_required "read"] {
    set group_id [lindex $group 1]
    if { [lsearch $groups_belonging_to $group_id] >= 0 } {
        lappend ams_forms "${package_id}__${group_id}"
    }
}
set revision_id [contact::live_revision -party_id $party_id]

# This is the multirow that gets the values for each attribute
# If you map the categories you have to check for the group (which is
# passed along in the form_name) and see the mapped categories. Then you have to
# retrieve the values for the category and append them to the
# attributes multirow with a section heading (e.g. the name of the
# category tree) and the pretty_name of the category along with the
# value.

multirow create attributes section attribute value
foreach form $ams_forms {
    set values [ams::values -package_key "contacts" -object_type $object_type -list_name $form -object_id $revision_id -format "html"]
    foreach {section attribute_name pretty_name value} $values {
        if { [lsearch $hidden_attributes $attribute_name] < 0 } {
            multirow append attributes $section $pretty_name $value
        }
    }
}
set append_list [list]
callback contact::append_attribute -multirow_name append_list -name [contact::name -party_id $party_id]
foreach append $append_list {
    multirow append attributes [lindex $append 0] [lindex $append 1] [lindex $append 2]
}
