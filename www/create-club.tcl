ad_page_contract {

    Create the club for an organization.

} {
    {party_id:integer}
} -validate {
    contact_exists -requires {party_id} {
	if { ![contact::exists_p -party_id $party_id] } {
	    ad_complain "[_ contacts.lt_The_contact_specified]"
	}
    }
}


ad_progress_bar_begin -title "[_ contacts.Creating_Club]" -message_1 "[_ contacts.lt_We_are_creating_the_c]" -message_2 "[_ contacts.lt_We_will_continue_auto]"

set group_id [group::get_id -group_name "Customers"]
callback contact::organization_new_group -organization_id $party_id -group_id $group_id

ad_progress_bar_end -url  "/contacts/$party_id"