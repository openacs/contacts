ad_page_contract {


    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

} {
    {party_id:integer ""}
    {object_type ""}
    {return_url ""}
}
set user_id [auth::require_login]
permission::require_write_permission -object_id [ad_conn package_id] -action "write"

if { [contact::exists_p $party_id] } {
    set context [list "\#acs-kernel.common_Edit\#"]
    set title "\#acs-kernel.common_Edit\# [contact::get::name $party_id]"
    set object_type [contact::get::object_type $party_id]
} else {
    set context [list "\#acs-kernel.common_Add\#"]
    if { $object_type == "organization" } {
        set title "\#contacts.Add_an_Organization\#"
    } else {
        set title "\#contacts.Add_a_Person\#"
        set object_type "person"
    }
    set party_id [contacts::util::next_object_id]
}


if { $object_type == "organization" } {
    set object_id [contacts::util::organization_object_id]
}

if { $object_type == "person" } {
    set object_id [contacts::util::person_object_id]
}

ad_form -name entry -action contact-ae -form {
    party_id:key
    object_type:text(hidden)
    return_url:text(hidden),optional
}

ad_form -extend -name entry -form [contacts::get::ad_form_elements $object_id $party_id]

if { [contacts::categories::enabled_p]} {
    ad_form -extend -name entry -form {
        {category_ids:integer(category),multiple,optional {label "Categories"}
            {html {size 7}} {value {$party_id [ad_conn package_id]}}}
    }
}

ad_form -extend -name entry \
    -new_request {
    } -edit_request {
        if { [contact::exists_p $party_id] } {
            contacts::get::ad_form_values $object_id $party_id
        }
    } -validate {
    } -on_submit {


        if { ![contact::exists_p $party_id] } {
            set creation_user [ad_conn user_id]
            set creation_ip [ad_conn peeraddr]

            if { $object_type == "organization" } {
                set option_id_temp [lindex $contact_attribute__organization_type 0]
                db_1row get_organization_type_id {
                                        select organization_type_id 
                                          from contact_attribute_options cao,
                                               organization_types ot
                                         where cao.option = ot.type
                                           and cao.option_id  = :option_id_temp
                                }

                db_1row create_org { select organization__new ( 
                                                       null,
                                                       :contact_attribute__organization_name,
                                                       null,
                                                       :party_id,
                                                       :organization_type_id,
                                                       null,
                                                       null,
                                                       null,
                                                       :creation_user,
                                                       :creation_ip,
                                                       null
                                                       ) as party_id }
            } else {
                db_1row create_person { select person__new (
                                                            :party_id,
                                                            'person',
                                                            now(),
                                                            :creation_user,
                                                            :creation_ip,
                                                            null,
                                                            null,
                                                            :contact_attribute__first_names,
                                                            :contact_attribute__last_name,
                                                            null
                                                            ) as party_id }
            }
        }

        contacts::save::ad_form::values $object_id $party_id
        if { [contacts::categories::enabled_p]} {
            category::map_object -remove_old -object_id $party_id $category_ids
        }
    } -after_submit {
        if { ![exists_and_not_null return_url] } {
            set return_url "./"
        }
        ad_returnredirect -message "Contact '[contact::get::name $party_id]' Updated" $return_url
        ad_script_abort
    }





ad_return_template
