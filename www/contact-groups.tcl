ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {party_id:integer,notnull}
    {return_url "./"}
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set recipients [list]

lappend recipients "<a href=\"[contact::url -party_id $party_id]\">[contact::name -party_id $party_id]</a>"

set recipients [join $recipients ", "]


set group_options [contact::groups -expand "all" -privilege_required "create"]

set groups_belonging_to [db_list get_party_groups { select group_id from group_distinct_member_map where member_id = :party_id }]

set groups_to_add [list [list "-- select a group --" ""]]
foreach group $group_options {
    if { [lsearch "$groups_belonging_to" [lindex $group 1]] >= 0 } {
        # the party is part of this group
        lappend groups_in     [list [lindex $group 0] [lindex $group 1] [lindex $group 2]] 
    } else {
        lappend groups_to_add [list [lindex $group 0] [lindex $group 1]]
    }
}

if { [llength $group_options] == "0" } {
    ad_return_error "Insufficient Permissions" "You do not have permission to add users to groups"
}

set form_elements {
}
set edit_buttons [list [list "Add to Selected Group" create]]




ad_form -action group-parties-add \
    -name add_to_group \
    -edit_buttons $edit_buttons \
    -form {
        party_id:integer(hidden)
        return_url:text(hidden)
        {group_ids:text(select) {label ""} {options $groups_to_add}}
    } -on_request {
    } -on_submit {
	db_transaction {
            foreach group_id $group_ids {
                foreach party_id $party_ids {
                    # relation_add verifies that they aren't already in the group
                    switch [contact::type -party_id $party_id] {
                        person {
                            set rel_type "membership_rel"
                        }
                        organization {
                            set rel_type "organization_rel"
                        }
                    }
                    relation_add -member_state "approved" $rel_type $group_id $party_id
                }
            }
	}
    } -after_submit {
	ad_returnredirect $return_url
	ad_script_abort
    }


