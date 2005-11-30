ad_page_contract {
    Add a Relationship and Manage Relationship Details

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-05-21
    @cvs-id $Id$
} {
    {object_id_one:integer,notnull}
    {object_id_two:integer,notnull}
    {party_id:integer,notnull}
    {rel_type:notnull}
    {return_url ""}
} -validate {
    contact_one_exists -requires {object_id_one} {
	if { ![contact::exists_p -party_id $object_id_one] } {
	    ad_complain "[_ contacts.lt_The_first_contact_spe]"
	}
    }
    contact_two_exists -requires {object_id_two} {
	if { ![contact::exists_p -party_id $object_id_two] } {
	    ad_complain "[_ contacts.lt_The_second_contact_sp]"
	}
    }
    party_id_valid -requires {object_id_one object_id_two party_id} {
	if { $party_id != $object_id_one && $party_id != $object_id_two } {
	    ad_complain "[_ contacts.lt_The_contact_specified_1]"
	}
    }
}

set rel_id_from_db [db_string get_rel_id {} -default {}]
if { [exists_and_not_null rel_id_from_db] } {
    set rel_id $rel_id_from_db
}
set package_id [ad_conn package_id]
set list_exists_p [ams::list::exists_p -package_key "contacts" -object_type ${rel_type} -list_name ${package_id}]

if { $list_exists_p } {

    set form_elements {
        rel_id:key
        {object_id_one:integer(hidden)}
        {object_id_two:integer(hidden)}
        {party_id:integer(hidden)}
        {rel_type:text(hidden)}
        {return_url:text(hidden),optional}
    }
    append form_elements [ams::ad_form::elements -package_key "contacts" -object_type $rel_type -list_name [ad_conn package_id]]

    ad_form -name rel_form \
        -mode "edit" \
        -form $form_elements \
        -on_request {
        } -new_request {
        } -edit_request {
            ams::ad_form::values -form_name "rel_form" -package_key "contacts" -object_type $rel_type -list_name [ad_conn package_id] -object_id $rel_id
        } -on_submit {
        } -new_data {
        } -edit_data {
        } -after_submit {
        }
    

}

if { !$list_exists_p || [template::form::is_valid "rel_form"] } {

    set existing_rel_id [db_string rel_exists_p {} -default {}]
    
    if { [empty_string_p $existing_rel_id] } {
	set rel_id {}
	set context_id {}
	set creation_user [ad_conn user_id]
	set creation_ip [ad_conn peeraddr]
	set rel_id [db_exec_plsql create_rel {}]
        db_dml insert_contact_rel {}
	#	callback contact::insert_contact_rel -package_id $package_id -form party_ae -object_type $object_type
        util_user_message -message "[_ contacts.Relationship_Added]"
    } else {
        util_user_message -message "[_ contacts.Relationship_Updated]"
    }
    if { $list_exists_p } {
        ams::ad_form::save -package_key "contacts" \
            -object_type $rel_type \
            -list_name [ad_conn package_id] \
            -form_name "rel_form" \
            -object_id $rel_id
    }
    if { ![exists_and_not_null return_url] } {
        set return_url "$party_id/relationships"
    }
    ad_returnredirect $return_url
    ad_script_abort
}

ad_return_template
