ad_page_contract {
     

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

} {
    {party_id:integer,multiple}
    {confirm_p:boolean 0}
}


if { !$confirm_p } {
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
    db_dml make_current_contact {
        delete from contact_archives where party_id = :party_id
    }
}

ad_returnredirect "./"
ad_script_abort
}
