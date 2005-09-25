#    @author Matthew Geddert openacs@geddert.com
#    @creation-date 2005-05-09
#    @cvs-id $Id$

if { [string is false [contact::exists_p -party_id $party_id]] } {
    error "[_ contacts.lt_The_party_id_specifie]"
}
if { [string is false [exists_and_not_null hide_form_p]] } {
    set hide_form_p 0
}
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

set groups_belonging_to [db_list get_party_groups { select group_id from group_distinct_member_map where member_id = :party_id }]

set return_url "[contact::url -party_id $party_id]groups"
set object_type [contact::type -party_id $party_id]
if { [string is false $hide_form_p] } {
    set group_options [list]
    set active_top_level ""
    foreach group [contact::groups -expand "all" -privilege_required "create"] {
        if { [lindex $group 2] == "1" } { set active_top_level [lindex $group 0] }
        if { [lsearch $groups_belonging_to [lindex $group 1]] < 0 } {
            lappend group_options [list [lindex $group 0] [lindex $group 1]]
        }
    }
    if { [llength $group_options] > 0 } {
        set group_options [concat [list [list "- [_ ams.select_one] -" ""]] $group_options]
        set package_url [ad_conn package_url]
        set add_label [_ contacts.Add_to_Group]
        ad_form -name add_to_group -action "${package_url}group-party-add" \
            -form {
                    party_id:integer(hidden)
                    return_url:text(hidden),optional
                    {group_id:integer(select) {label {}} {options $group_options}}
                    {save:text(submit),optional {label {$add_label}}}
            } -on_request {
            } -after_submit {
            }

    } else {
        set no_more_available_p 1
    }
}


multirow create groups group_id group sub_p remove_url
set sub_p "0"
foreach group [contact::groups -expand "all" -privilege_required "read"] {
    set group_name [lindex $group 0]
    if { [regexp {^(\.\.\.)(.*)} $group_name] } { 
	set sub_p "1"
    } else {
	set sub_p "0"
    }
    set group_id [lindex $group 1]
    set remove_url [export_vars -base "/contacts/group-parties-remove" -url {group_id party_id return_url}] 
    if { [lindex $group 2] == "1" } { set active_top_level [lindex $group 0] }
    if { [lsearch $groups_belonging_to [lindex $group 1]] >= 0 } {
        multirow append groups [lindex $group 1] $group_name $sub_p $remove_url
    }
}

set default_group [contacts::default_group]
if { [permission::permission_p -object_id $default_group -privilege "delete"] } {
    set remove_url [export_vars -base "/contacts/group-parties-remove" -url {{group_id $default_group} party_id {return_url {/contacts/}}}] 
    if { [person::person_p -party_id $party_id] && [contact::email -party_id $party_id] != "" } {
        set upgrade_url [export_vars -base "/contacts/person-upgrade-to-user" -url {{person_id $party_id}}] 
    }
    set delete_p 1
} else {
    set delete_p 0
}

