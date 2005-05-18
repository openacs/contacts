ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {party_id:integer,notnull}
    {rel_id:integer,notnull}
} -validate {
}

relation_remove $rel_id
ad_returnredirect -message "relation deleted" [contact::url -party_id $party_id]
ad_script_abort
