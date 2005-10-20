ad_page_contract {

    @author Al-Faisal El-Dajani (faisal.dajani@gmail.com)
    @creation-date 2005-10-18
} {
    {party_id ""}
}

foreach optional_param {sender_id recipient_id page page_size page_flush_p orderby object_id} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

if {![exists_and_not_null party_id]} {
    set party_id $sender_id
}

ad_return_template