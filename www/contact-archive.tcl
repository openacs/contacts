ad_page_contract {
     

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {party_id:integer,multiple}
    {confirm_p:boolean 0}
}


if { [string is false $confirm_p] } {
    set num_entries [llength $party_id]

    if { $num_entries == 0 } {
        ad_returnredirect "contacts"
        return
    }

    set title "Archive Contact [ad_decode $num_entries 1 "Entry" "Entries"]"
    set context [list $title]
    set yes_url "contact-archive?[export_vars { party_id:multiple { confirm_p 1 } }]"
    set no_url "./"

    return
}

set archived_user [ad_conn user_id]
set archived_reason "This contact is no longer needed"

foreach party_id $party_id {
    db_dml archive_contact {}
}

ad_returnredirect "./"
ad_script_abort
