ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {party_id:multiple,integer,notnull}
    {group_id:integer,notnull}
}

set party_id [lindex $party_id 0]
switch [contact::type -party_id $party_id] {
     person {
         set rel_type "membership_rel"
     }
     organization {
         set rel_type "organization_rel"
     }
}
relation_add -member_state "approved" $rel_type $group_id $party_id

ad_returnredirect [contact::url -party_id $party_id]

