ad_page_contract {


    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {group_id:integer,notnull}
    {action:notnull}
    {return_url "./"}
} -validate {
    action_valid -requires {action} {
        if { [lsearch [list map unmap makedefault] $action] < 0 } {
            ad_complain "the action supplied is not valid"
        }
    }
    action_appropriate -requires {action} {
        set package_id [ad_conn package_id]
        set default_p [db_string group_mapped { select default_p from contact_groups where group_id = :group_id and package_id = :package_id } -default {}]
        set parent_id [contact::group::parent -group_id $group_id]

        if { [exists_and_not_null default_p] } {
            # the group is mapped
            if { $default_p && $action == "makedefault" } {
                ad_complain "This group is already the default"
            }
            if { [exists_and_not_null parent_id] && $action == "makedefault" } {
                ad_complain "You cannot make sub groups the default group"
            }
            if { $default_p && $action == "unmap" } {
                ad_complain "You cannot unmap the default group"
            }
            if { $action == "map" } {
                ad_complain "This group is already mapped"
            }
        } else {
            if { $action != "map" } {
                ad_complain "This action cannot be taken for unmapped groups"
            }
            if { [exists_and_not_null parent_id] } {
                if { ![db_0or1row parent_mapped { select 1 from contact_groups where group_id = :parent_id and package_id = :package_id }] } {
                    ad_complain "You cannot map groups whose parent groups are not mapped"
                }
            }
        }
    }
}



set package_id [ad_conn package_id]

switch $action {
    map {
        # if the group is the only one for this package it needs to be made the default
        set count [db_string get_count { select count(*) from contact_groups where package_id = :package_id } -default "0"]
        if { $count == 0 } {
            set default_p "1"
        } else {
            set default_p "0"
        }
        db_dml insert_map {
        insert into contact_groups
        (group_id,default_p,package_id)
        values
        (:group_id,:default_p,:package_id)
        }
    }
    unmap {
        db_dml delete_map {
            delete from contact_groups where group_id = :group_id and package_id = :package_id

        }
    }
    makedefault {
        db_dml remove_other_defaults {
            update contact_groups set default_p = 'f'  where package_id = :package_id
        }
        db_dml make_default {
            update contact_groups set default_p = 't' where package_id = :package_id and group_id = :group_id
        }
    }
}


ad_returnredirect $return_url
