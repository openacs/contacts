ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {party_id:integer,notnull}
    {rel_id:integer,notnull}
    {return_url ""}
} -validate {
    valid_party -requires {party_id} {
	if { ![contact::exists_p -party_id $party_id] } {
	    ad_complain "[_ contacts.lt_The_contact_specified]"
	}
    }
}

# ams::object_delete -object_id $rel_id
db_1row get_object_id_one {}
db_1row delete_rel {}

# flush cache for employee data
util_memoize_flush_regexp "::contact::employee_not_cached -employee_id $object_id_one"
util_memoize_flush_regexp "::contact::employee::get_not_cached -employee_id $object_id_one *"
util_memoize_flush_regexp "::contact::employee_not_cached -employee_id $party_id"
util_memoize_flush_regexp "::contact::employee::get_not_cached -employee_id $party_id *"


if { ![exists_and_not_null return_url] } {
    set return_url "$party_id/relationships"
}
ad_returnredirect -message "[_ contacts.Relationship_Deleted]" $return_url
ad_script_abort
