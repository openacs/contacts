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
        ad_returnredirect "./"
        return
    }

    set title "Make [ad_decode $num_entries 1 "Entry" "Entries"] Current"
    set context [list $title]
    set yes_url "contact-current?[export_vars { party_id:multiple { confirm_p 1 } }]"
    set no_url "./"

    return
} else {

foreach party_id $party_id {
    db_dml unarchive_contact {}
}

ad_returnredirect "./"
ad_script_abort
}
