ad_library {

  Support procs for the contacts package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

}

namespace eval contact:: {

    ad_proc -public name {
        party_id
    } {
        this returns the contact's name
    } {
        return [contact::get::name $party_id]
    }

    ad_proc -public create {
        {-party_id ""}
        {-email ""}
        {-url ""}
        {-deleted_p "f"}
        {-deleted_user ""}
        {-deleted_time ""}
        {-deleted_reason ""}
    } {
        this code creates a new contact and returns the newly created party_id
    } {

        v_organization_id := organization__new (
                                                p_legal_name,
                                                p_name, -- UNIQUE
                                                p_notes,
                                                p_organization_id,
                                                p_organization_type_id,
                                                p_reg_number,
                                                p_email,
                                                p_url,
                                                p_creation_user,
                                                p_creation_ip,
                                                p_context_id,
                                                );
        
        v_person_id := person__new (
                                    p_party_id,
                                    p_object_type, -- default person (could be user or contact)
                                    p_creation_date,
                                    p_creation_user,
                                    p_creation_ip,
                                    p_email,
                                    p_url,
                                    p_first_names,
                                    p_last_name,
                                    p_context_id
                                    );
        

        set creation_user [ad_conn user_id]
        set creation_ip [ad_conn peeraddr]
        set context_id [ad_conn package_id]
        return [db_exec_plsql get_party_id { select contact__create (:party_id,
                                                                       :email,
                                                                       :url,
                                                                       :deleted_p,
                                                                       :deleted_user,
                                                                       :deleted_time,
                                                                       :deleted_reason,
                                                                       now(),
                                                                       :creation_user,
                                                                       :creation_ip,
                                                                       :context_id
                                                                       )}]
    }


    ad_proc -public exists_p {
        party_id
    } {
        this code returns 1 if the party_id exists
    } {
        return [db_0or1row exists_p_select { select 1 from contacts where party_id = :party_id }]
    }

    ad_proc -public get {
        party_id
    } {
        get the info on the contact
    } {

	db_0or1row get_contact_info { select * from contacts where party_id = :party_id }

        set contact_info [ns_set create]
        ns_set put $contact_info party_id         $party_id         
        ns_set put $contact_info object_type      $object_type      
        ns_set put $contact_info name             $name             
        ns_set put $contact_info legal_name       $legal_name       
        ns_set put $contact_info reg_number       $reg_number       
        ns_set put $contact_info first_names      $first_names      
        ns_set put $contact_info last_name        $last_name        
        ns_set put $contact_info sort_first_names $sort_first_names 
        ns_set put $contact_info sort_last_name   $sort_last_name   
        ns_set put $contact_info email            $email            
        ns_set put $contact_info url              $url              
        ns_set put $contact_info user_p           $user_p           

        # Now, set the variables in the caller's environment
        ad_ns_set_to_tcl_vars -level 2 $contact_info
        ns_set free $contact_info

    }



}

namespace eval contact::get:: {

    ad_proc -public array { 
        party_id
        array
    } {
        get the info from addresses
    } {
        upvar $array row
        db_0or1row select_address_info { select * from contacts where party_id = :party_id } -column_array row
    }


    ad_proc -public object_type {
        party_id
    } {
        returns the parties object_type
    } {
        contact::get $party_id
        return $object_type
    }

    ad_proc -public name {
        party_id
    } {
        returns the parties sort_first_names
    } {
        contact::get $party_id
        return $sort_first_names
    }

}

namespace eval contacts::util:: {

    ad_proc -public party_is_user_p {
        party_id
    } {
        returns 1 if the party is a user and 0 if not
    } {
        return [db_0or1row get_party_is_user_p { select '1' from users where user_id = :party_id } ]
    }


    ad_proc -public next_object_id {
    } {
        returns the next available object_id
    } {
        db_1row get_next_object_id { select nextval from acs_object_id_seq }
        return $nextval
    }
    

    ad_proc -public organization_object_id {
    } {
        returns the object_id of the organization contact_object_type
    } {
        db_1row get_object_id { select object_id from contact_object_types where object_type = 'organization' }
        return $object_id
    }

    ad_proc -public person_object_id {
    } {
        returns the object_id of the organization contact_object_type
    } {
        db_1row get_object_id { select object_id from contact_object_types where object_type = 'person' }
        return $object_id
    }

    
    # some of this codes was borrowed from the directory module
    ad_proc letter_bar {
        {-export_vars ""}
        {-letter ""}
        {-initial_list:required}
    } {
        Returns an A-Z bar with greyed out letters not
        in initial_list and bolds "letter".
    
        Includes all existing url vars except those in
        the "excluded_vars" list.
    } {
        set all_letters [list A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]
    
        set html_list [list]
        foreach l $all_letters {
    	if { [lsearch -exact $initial_list $l] == -1 } {
    	    # This means no user has this initial
    	    lappend html_list "$l"
    	} elseif { [string compare $l $letter] == 0 } {
    	    lappend html_list "<strong>$l</strong>"
    	} else {
    	    lappend html_list "<a href=\"./?letter=$l\&$export_vars\">$l</a>"
    	}
        }
        if { [empty_string_p $letter] || [string compare $letter "all"] == 0 } {
            lappend html_list "<strong>\#contacts.All\#</strong>"
        } else {
            lappend html_list "<a href=\"./?letter=\&$export_vars\">\#contacts.All\#</a>"
        }
        return "[join $html_list " | "]"
    }
    
    
}









namespace eval contacts::get {
    ad_proc -public ad_form_elements {
        object_id
        party_id
    } {
        this code lists the form elements for a contact (after checking whether or not the user has permission to edit/add this info)
    } {


        set locale [lang::conn::locale -site_wide]
        set user_id [ad_conn user_id]

        set query {
           select * 
             from contact_attributes ca,
                  contact_widgets cw,
                  contact_attribute_object_map caom,
                  contact_attribute_names can
            where caom.object_id = :object_id
              and ca.attribute_id = can.attribute_id
              and can.locale = :locale
              and caom.attribute_id = ca.attribute_id
              and ca.widget_id = cw.widget_id
              and not ca.depreciated_p
              and acs_permission__permission_p(ca.attribute_id,:user_id,'write')
            order by caom.sort_order
        }

        set active_group_id ""

        set element_list ""
        if { [contact::exists_p $party_id] } {
            set object_type [contact::get::object_type $party_id]
        } else {
            # since the party doesn't exist yet, we assume that
            # contacts is calling this proc to create a person
            # or an organization
            if { $object_id == [contacts::util::organization_object_id] } {
                set object_type "organization"
            } else {
                set object_type "person"
            }
        }
        db_foreach select_attributes $query {


#            set custom_fields [list organization_name legal_name reg_number first_names last_name email url]
            set custom_fields [list first_names last_name email url]
            if { [lsearch $custom_fields $attribute] >= 0 } {
                if { [contacts::util::party_is_user_p $party_id] } {
                    if { ![string compare $party_id [ad_conn user_id]] } { 
                        set help_text "This will change your account info."
                    } elseif { [acs_user::site_wide_admin_p] } {
                        set help_text "This will change [person::name -person_id $party_id]'s account info."
                    } else {
#                        set help_text "You may not edit this information since [person::name -person_id $party_id] is a user of this system."
                        set widget "inform"
                    }
                } 
            }


            if { [contacts::util::party_is_user_p $party_id] && ![string compare $attribute "email"] } {
                set required_p 1
            }
            if { $object_type == "person" } {
                set custom_fields [list first_names last_name]
                if { [lsearch $custom_fields $attribute] >= 0 } {
                    set required_p 1
                }
            }
            if { $object_type == "organization" } {
                set custom_fields [list organization_name organization_type]
                if { [lsearch $custom_fields $attribute] >= 0 } {
                    set required_p 1
                }
            }






            set widget_string "contact_attribute__$attribute\:$datatype\($widget\)"


            if { ![exists_and_not_null required_p] } {
                append widget_string ",optional"
            } else {
                if { [string is false $required_p] } { 
                    append widget_string ",optional"
                }
            }
            if { [exists_and_not_null multiple_p] } {
                if { [string is true $multiple_p] } { 
                    append widget_string ",multiple"
                }
            }

            if { [exists_and_not_null nospell_p] } {
                if { [string is true $nospell_p] } { 
                    append widget_string ",nospell"
                }
            }


            set temp_element [list $widget_string [list "label" "$name"]]

            if { $storage_column == "option_map_id" } {
                lappend temp_element [list "options" [db_list_of_lists select_element_options { 
                                                                      select option, option_id
                                                                        from contact_attribute_options
                                                                       where attribute_id = :attribute_id
                                                                       order by sort_order 
                } ]]
            }

            if { [exists_and_not_null help_p] } {
                if { [string is true $help_p] } {
                    lappend temp_element "help"
                }
            }

            if { [exists_and_not_null help_text] } { 
                lappend temp_element [list "help_text" $help_text]
            } 

            if { $datatype == "date" && [exists_and_not_null format] } { 
                lappend temp_element [list "format" "$format"]
            }

            if { [exists_and_not_null html] } {
                set temp_html ""
                foreach element [lrange $html 0 [llength $html]] {
                    lappend temp_html "[lindex $element 0]" 
                }
                if { [exists_and_not_null temp_html] } {
                    lappend temp_element [list "html" $temp_html]
                }
            }

            if { [exists_and_not_null heading] } {
                lappend temp_element [list "section" "$heading"]
            }

            lappend element_list "$temp_element"
        }

        return $element_list
    }





    ad_proc -public ad_form_values {
        object_id
        party_id
    } {
        get the attribute_values for a contact 
    } {


        if { [contact::exists_p $party_id] } {
        set user_id [ad_conn user_id]



        set query {

          select ca.attribute_id,
                 ca.attribute, 
                 cav.option_map_id,
                 cav.address_id,
                 cav.number_id,
                 to_char(cav.time,'YYYY MM DD') as time,
                 cav.value,
                 cav.value_format,
                 cw.storage_column
            from contact_attributes ca,
                 contact_widgets cw,
                 contact_attribute_object_map caom left join 
                     ( select * 
                         from contact_attribute_values 
                        where party_id = :party_id
                          and not deleted_p ) cav on (caom.attribute_id = cav.attribute_id)
            where caom.object_id = :object_id
              and caom.attribute_id = ca.attribute_id
              and ca.widget_id = cw.widget_id
              and not ca.depreciated_p
              and acs_permission__permission_p(ca.attribute_id,:user_id,'write')
        }

        set courses_info_set [ns_set create]

        db_foreach select_attributes $query {

            set attribute_value $value

            if { $storage_column == "address_id" } {
                if { [exists_and_not_null address_id] } {
                    contacts::postal_address::get -address_id "$address_id" -array "address_info"
                    set attribute_value [list $address_info(delivery_address) $address_info(municipality) $address_info(region) $address_info(postal_code) $address_info(country_code)]
                } else {
                    set attribute_value [list {} {} {} {} {US}]
                }
            }
            if { $storage_column == "number_id" && [exists_and_not_null number_id] } { 
                contacts::telecom_number::get -number_id $number_id -array "telecom_info"
                set attribute_value $telecom_info(subscriber_number)
            }
            if { $storage_column == "time" && [exists_and_not_null time] } { set attribute_value $time }
            if { $storage_column == "option_map_id" && [exists_and_not_null option_map_id] } {
                set attribute_value_temp ""
                db_foreach select_options_from_map { select option_id from contact_attribute_option_map where option_map_id = :option_map_id } {
                    lappend attribute_value_temp $option_id
                }
                set attribute_value_temp [string trim $attribute_value_temp]
                if { [exists_and_not_null attribute_value_temp] } {
                    set attribute_value $attribute_value_temp
                }
            }


            set custom_fields [list organization_name legal_name reg_number first_names last_name email url]

            if { [lsearch $custom_fields $attribute] >= 0 } {
                db_0or1row get_attribute_value "
                                            select $attribute as attribute_value
                                              from contacts
                                             where party_id = $party_id
                    "
            }
            if { $attribute == "organization_type" } {
                set attribute_value [db_list_of_lists get_org_types {
                                        select option_id 
                                          from contact_attribute_options cao,
                                               organization_types ot,
                                               organization_type_map otm
                                         where cao.option = ot.type
                                           and cao.attribute_id  = :attribute_id
                                           and otm.organization_type_id = ot.organization_type_id
                                           and otm.organization_id = :party_id

                }]
            }

            ns_set put $courses_info_set contact_attribute__$attribute $attribute_value
        }

        # Now, set the variables in the caller's environment
        ad_ns_set_to_tcl_vars -level 2 $courses_info_set
        ns_set free $courses_info_set


    }
    }



}




namespace eval contacts::save::ad_form {



    ad_proc -public values {
        object_id
        party_id

    } {
        this code saves attributes input in a form
    } {
    
        set user_id [ad_conn user_id]

        if { [exists_and_not_null party_id] } {
            if { ![db_0or1row select_contact_p { select 1 from contacts where party_id = :party_id }] } {
                set party_id [contacts::contact::create -party_id $party_id]
            }
        } else {
            set party_id [contacts::contact::create]
        }
    

        set locale [lang::conn::locale -site_wide]

        set query {
           select * 
             from contact_attributes ca,
                  contact_widgets cw,
                  contact_attribute_object_map caom,
                  contact_attribute_names can
            where caom.object_id = :object_id
              and ca.attribute_id = can.attribute_id
              and can.locale = :locale
              and caom.attribute_id = ca.attribute_id
              and ca.widget_id = cw.widget_id
              and not ca.depreciated_p
              and acs_permission__permission_p(ca.attribute_id,:user_id,'write')
            order by caom.sort_order
        }


        set object_type [contact::get::object_type $party_id]

        set attr_value_temp ""

        db_foreach select_attributes $query {
    
            set attribute_value_temp [string trim [template::element::get_value entry "contact_attribute__$attribute"]]
            
            if { $storage_column == "address_id" } {
    
                # I need to verify that something has changed here
    
                set delivery_address [string trim [template::util::address::get_property delivery_address $attribute_value_temp]]
                set municipality     [string trim [template::util::address::get_property municipality     $attribute_value_temp]]
                set region           [string trim [template::util::address::get_property region           $attribute_value_temp]]
                set postal_code      [string trim [template::util::address::get_property postal_code      $attribute_value_temp]]
                set country_code     [string trim [template::util::address::get_property country_code     $attribute_value_temp]]
    
    
                set old_address_id ""
                db_0or1row select_old_address_id {
                    select cav.address_id as old_address_id
                      from contact_attribute_values cav,
                           postal_addresses pa
                     where cav.party_id = :party_id
                       and cav.attribute_id = :attribute_id
                       and not cav.deleted_p
                       and cav.address_id = pa.address_id
                       and pa.delivery_address = :delivery_address
                       and pa.municipality = :municipality
                       and pa.region = :region
                       and pa.postal_code = :postal_code
                       and pa.country_code = :country_code
                }
                if { [exists_and_not_null old_address_id] } {
                    # the address in the database is the same
                    set address_id $old_address_id
                } else {
                    # the address in the database is different so we need to add one
                    if { [exists_and_not_null delivery_address] && [exists_and_not_null country_code] } {
                        set address_id [contacts::postal_address::new \
                                            -delivery_address $delivery_address \
                                            -municipality $municipality \
                                            -region $region \
                                            -postal_code $postal_code \
                                            -country_code $country_code ]
                    } else {
                        set address_id ""
                    }
                }
    
                contacts::attribute::value::save \
                    -attribute_id $attribute_id \
                    -party_id $party_id \
                    -address_id $address_id
    
            }
            if { $storage_column == "number_id" } {
    
                set old_number_id ""
                db_0or1row select_old_number_id {
                    select cav.number_id as old_number_id
                      from contact_attribute_values cav,
                           telecom_numbers tn
                     where cav.party_id = :party_id
                       and cav.attribute_id = :attribute_id
                       and not cav.deleted_p
                       and cav.number_id = tn.number_id
                       and tn.subscriber_number = :attribute_value_temp
                }
                if { [exists_and_not_null old_number_id] } {
                    # the number in the database is the same
                    set number_id $old_number_id
                } else {
                    # the telecom_number in the database is different so we need to add one
                    if { [exists_and_not_null attribute_value_temp] } {
                        set number_id [contacts::telecom_number::new -subscriber_number $attribute_value_temp ]
                    } else {
                        set number_id ""
                    }
                }
    
                contacts::attribute::value::save \
                    -attribute_id $attribute_id \
                    -party_id $party_id \
                    -number_id $number_id
            }
            if { $storage_column == "option_map_id" } {
    
                set attribute_value_temp [string trim [template::element::get_values entry "contact_attribute__$attribute"]]
    
                if { [exists_and_not_null attribute_value_temp] } {
    
                    # first we verify that the address has changed. otherwise we pass on the old option_map_id
                    db_0or1row get_option_map_id { select option_map_id from contact_attribute_values where party_id = :party_id and attribute_id = :attribute_id and not deleted_p }
    
                    if { [exists_and_not_null option_map_id] } {
                        # we know that a previous entry exists
    
                        set old_option_ids ""
                        db_foreach get_old_options { select option_id from contact_attribute_option_map where option_map_id  = :option_map_id } {
                            lappend old_option_ids $option_id
                        }
                        set new_option_ids $attribute_value_temp
    
                        set same_count 0
                        foreach option_id $old_option_ids {
                            if {![empty_string_p $option_id]} {
                                if { [regsub -all $option_id $new_option_ids $option_id new_option_ids] } {
                                    incr same_count
                                }
                            }
                        }
                        if { [llength $new_option_ids] == $same_count && [llength $old_option_ids] == $same_count } {
                            # the lists have the same values - do nothing
                        } else {
                            # the lists are different 
                            db_1row get_new_option_map_id { select nextval('contact_attribute_option_map_id_seq') as option_map_id }
    
                            foreach option_id $attribute_value_temp {
                                if {![empty_string_p $option_id]} {
                                    db_dml insert_options_map { 
                                        insert into contact_attribute_option_map
                                        (option_map_id,party_id,option_id)
                                        values
                                        (:option_map_id,:party_id,:option_id)
                                    }
                                }
                            }
                        }
                    } else {
                        # there is no previous entry in the database         
                        db_1row get_new_option_map_id { select nextval('contact_attribute_option_map_id_seq') as option_map_id }
    
                        foreach option_id $attribute_value_temp {
                            if {![empty_string_p $option_id]} {
                                db_dml insert_options_map { 
                                    insert into contact_attribute_option_map
                                    (option_map_id,party_id,option_id)
                                    values
                                    (:option_map_id,:party_id,:option_id)
                                }
                            }
                        }
                    }
    
                    set attribute_value_temp $option_map_id
                }
    
                contacts::attribute::value::save \
                    -attribute_id $attribute_id \
                    -party_id $party_id \
                    -option_map_id $attribute_value_temp
            }
            if { $storage_column == "time" } {
                contacts::attribute::value::save \
                    -attribute_id $attribute_id \
                    -party_id $party_id \
                    -time [contacts::date::sqlify -date $attribute_value_temp]
            }
            if { $storage_column == "value" } {
                contacts::attribute::value::save \
                    -attribute_id $attribute_id \
                    -party_id $party_id \
                    -value $attribute_value_temp
            }
    




            set custom_fields [list organization_name legal_name reg_number organization_type first_names last_name email url]

            if { [lsearch $custom_fields $attribute] >= 0 } {
                if { $attribute == "email" } {
                    db_dml update_parties {
                        update parties set email = :attribute_value_temp where party_id = :party_id
                    }
                }
                if { $attribute == "url" } {
                    db_dml update_parties {
                        update parties set url = :attribute_value_temp where party_id = :party_id
                    }
                }
                if { $object_type == "organization" } {
                    # [list organization_name legal_name reg_number organization_type]
                    if { $attribute == "organization_name" } {
                        db_dml update_parties {
                            update organizations set name = :attribute_value_temp where organization_id = :party_id
                        }
                    }
                    if { $attribute == "legal_name" } {
                        db_dml update_parties {
                            update organizations set legal_name = :attribute_value_temp where organization_id = :party_id
                        }
                    }
                    if { $attribute == "reg_number" } {
                        db_dml update_parties {
                            update organizations set reg_number = :attribute_value_temp where organization_id = :party_id
                        }
                    }
                    if { $attribute == "organization_type" } {
                        db_dml delete_object_map { delete from organization_type_map where organization_id = :party_id }
                        set attribute_value_temp [string trim [template::element::get_values entry "contact_attribute__$attribute"]]
                        foreach option_id $attribute_value_temp {
                            if {![empty_string_p $option_id]} {
                                db_1row get_organization_type_id {
                                        select organization_type_id 
                                          from contact_attribute_options cao,
                                               organization_types ot
                                         where cao.option = ot.type
                                           and cao.option_id  = :option_id
                                }


                                db_dml insert_maping { insert into organization_type_map 
	                                                      (organization_id, organization_type_id) values
                                                              (:party_id, :organization_type_id) }
                            }
                        }
                    }
                }
                if { $object_type == "person" } {
                    # [list first_names last_name]
                    if { $attribute == "first_names" } {
                        db_dml update_parties {
                            update persons set first_names = :attribute_value_temp where person_id = :party_id
                        }
                    }
                    if { $attribute == "last_name" } {
                        db_dml update_parties {
                            update persons set last_name = :attribute_value_temp where person_id = :party_id
                        }
                    }

                    
                }


            }








        }
    
        return $party_id     
    
    }


}
