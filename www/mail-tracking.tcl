ad_page_contract {

    @author Al-Faisal El-Dajani (faisal.dajani@gmail.com)
    @creation-date 2005-10-18
} {
    {party_id:integer}

} -validate {
    contact_exists -requires {party_id} {
	if {![contact::exists_p -party_id $party_id]} {
	    ad_complain "[_ contacts.lt_The_contact_specified]"
	}
    }
}
#??
ad_return_template