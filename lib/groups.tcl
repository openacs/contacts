#    @author Matthew Geddert openacs@geddert.com
#    @creation-date 2005-05-09
#    @cvs-id $Id$

if { [string is false [contact::exists_p -party_id $party_id]] } {
    error "The party_id specified does not exist"
}
if { [string is false [exists_and_not_null hide_form_p]] } {
    set hide_form_p 0
}
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

set groups_belonging_to [db_list get_party_groups { select group_id from group_distinct_member_map where member_id = :party_id }]

multirow create addable_groups group_id group top_level
set active_top_level ""
foreach group [contact::groups -expand "all" -privilege_required "create"] {
    if { [lindex $group 2] == "1" } { set active_top_level [lindex $group 0] }
    if { [lsearch $groups_belonging_to [lindex $group 1]] < 0 } {
        multirow append addable_groups [lindex $group 1] [lindex $group 0] $active_top_level
    }
}

multirow create groups group_id group sub_p
set sub_p "0"
foreach group [contact::groups -expand "all" -privilege_required "read"] {
    set group_name [lindex $group 0]
    if { [regexp {^(\.\.\.)(.*)} $group_name] } { 
	set sub_p "1"
    } else {
	set sub_p "0"
    }
    if { [lindex $group 2] == "1" } { set active_top_level [lindex $group 0] }
    if { [lsearch $groups_belonging_to [lindex $group 1]] >= 0 } {
        multirow append groups [lindex $group 1] $group_name $sub_p
    }
}




