# packages/contacts/lib/contact-relationships.tcl
#
# Include for the relationships of a contact
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-06-21
# @arch-tag: 291a71c2-5442-4618-bb9f-13ff23d854b5
# @cvs-id $Id$

foreach required_param {party_id} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {package_id} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

if {[empty_string_p $package_id]} {
    set package_id [ad_conn package_id]
}

multirow create rels relationship relation_url contact contact_url attribute value
set default_group [contacts::default_group]

db_foreach get_relationships {} {
    set contact_url [contact::url -party_id $other_party_id]
    if {[organization::organization_p -party_id $party_id]} {
	set other_object_type "person"
    } else {
	set other_object_type "organization"
    } 
    set relation_url [export_vars -base "/contacts/add/$other_object_type" -url {{group_ids $default_group} {object_id_two "$party_id"} rel_type}]    
    set role_singular [lang::util::localize $role_singular]
    multirow append rels $role_singular $relation_url $other_name $contact_url {} {}

    # NOT YET IMPLEMENTED - Checking to see if role_singular or role_plural is needed

    if { [ams::list::exists_p -package_key "contacts" -object_type ${rel_type} -list_name ${package_id}] } {
        set details_list [ams::values -package_key "contacts" -object_type $rel_type -list_name $package_id -object_id $rel_id -format "text"]

        if { [llength $details_list] > 0 } {
            foreach {section attribute_name pretty_name value} $details_list {
                multirow append rels $role_singular $relation_url $other_name $contact_url $pretty_name $value
            }
        }
    }
}
