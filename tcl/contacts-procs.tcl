ad_library {

  Support procs for the contacts package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

}

namespace eval contact:: {

    ad_proc -public name {
        party_id
    } {
        this returns the contact's name
    } {
        return [contact::get::name $party_id]
    }

    ad_proc -public exists_p {
        party_id
    } {
        this code returns 1 if the party_id exists
    } {
        return [db_0or1row exists_p {}]
    }

    ad_proc -public get {
        party_id
    } {
        get the info on the contact
    } {

	db_0or1row get_contact_info {}

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
        db_0or1row select_address_info {} -column_array row
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

    ad_proc -public custom_field_list {
        party_id
    } {
        set custom_field_list [list email url]
        set object_type [contact::get::object_type $party_id]
        if { $object_type == "organization" } {
            lappend custom_field_list "organization_type"
            lappend custom_field_list "organization_name"
            lappend custom_field_list "legal_name"
            lappend custom_field_list "reg_number"
        }
        if { $object_type == "person" } {
            lappend custom_field_list "first_names"
            lappend custom_field_list "last_name"
        }
        return $custom_field_list
}



}


    
namespace eval contacts::util:: {

    ad_proc -public party_is_user_p {
        party_id
    } {
        returns 1 if the party is a user and 0 if not
    } {
        return [db_0or1row get_party_is_user_p {} ]
    }


    ad_proc -public next_object_id {
    } {
        returns the next available object_id
    } {
        db_1row get_next_object_id {}
        return $nextval
    }
    

    ad_proc -public organization_object_id {
    } {
        returns the object_id of the organization contact_object_type
    } {
        db_1row get_organization_object_id {}
        return $object_id
    }

    ad_proc -public person_object_id {
    } {
        returns the object_id of the organization contact_object_type
    } {
        db_1row get_object_id {}
        return $object_id
    }
    
    # some of this codes was borrowed from the directory module
    ad_proc -public letter_bar {
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
    

    ad_proc -public sqlify_list {
        variable_list
    } {
        set output_list {}
        foreach item $variable_list {
            if { [exists_and_not_null output_list] } {
                append output_list ", "
            }
            append output_list "'$item'"
        }
        return $output_list
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

        set active_group_id ""

        set element_list ""
        if { [string is true [contact::exists_p $party_id]] } {
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
        db_foreach select_attributes {} {

            if { [lsearch [list first_names last_name email url] $attribute] >= 0 } {
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
                if { [lsearch [list first_names last_name] $attribute] >= 0 } {
                    set required_p 1
                }
            }
            if { $object_type == "organization" } {
                if { [lsearch [list organization_name organization_type] $attribute] >= 0 } {
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

        if { [string is true [contact::exists_p $party_id]] } {
            set user_id [ad_conn user_id]
        

            contacts::get::values::multirow -multirow_name "ad_form_values" -party_id $party_id -object_id $object_id -permission "write"


            set courses_info_set [ns_set create]

            template::multirow -unclobber foreach ad_form_values {
                ns_set put $courses_info_set contact_attribute__$attribute_name $ad_form_value
            }

            # Now, set the variables in the caller's environment
            ad_ns_set_to_tcl_vars -level 2 $courses_info_set
            ns_set free $courses_info_set

        }
    }



}


namespace eval contacts::get::values:: {

    ad_proc multirow {
        {-multirow_name}
        {-permission "read"}
        {-object_id}
        {-party_id}
        {-orderby "sort_order,asc"}
    } {
        Returns a multirow
    } {
    
        set user_id [ad_conn user_id]
    
        template::multirow create $multirow_name attribute_name attribute_id pretty_attribute_name ad_form_value pretty_value pretty_value_html sort_order sort_key
    
        set custom_field_list [contact::get::custom_field_list $party_id]
        set custom_field_sql_list [contacts::util::sqlify_list $custom_field_list]

        set sort_order "0"

        db_foreach select_attribute_values "" {
    
              set attribute_name $attribute
              set attribute_id $attribute_id
              set pretty_attribute_name [contacts::attribute::name $attribute_id]
    
              if { [lsearch $custom_field_list $attribute] >= 0 } {
    
                  if { $attribute == "organization_name" } {
                      set ad_form_value [db_string organization_name_from_party_id {} -default {}]
                      set pretty_value $ad_form_value
                  }
                  if { $attribute == "organization_type" } {
                      set ad_form_value [list]
                      set pretty_value {}
                      db_foreach organization_types_from_party_and_attribute_id {} {
                          if { [llength $ad_form_value] > 0 } {
                              append pretty_value "\n"
                          }
                          lappend ad_form_value $option_id
                          append pretty_value $option
                      }
                  }
                  if { $attribute == "legal_name" } {
                      set ad_form_value [db_string legal_name_from_party_id {} -default {}]
                      set pretty_value $ad_form_value
                  }
                  if { $attribute == "reg_number" } {
                      set ad_form_value [db_string reg_number_from_party_id {} -default {}]
                      set pretty_value $ad_form_value
                  }
                  if { $attribute == "first_names" } {
                      set ad_form_value [db_string first_names_from_party_id {} -default {}]
                      set pretty_value $ad_form_value
                  }
                  if { $attribute == "last_name" } {
                      set ad_form_value [db_string last_name_from_party_id {} -default {}]
                      set pretty_value $ad_form_value
                  }
                  if { $attribute == "email" } {
                      set ad_form_value [db_string email_from_party_id {} -default {}]
                      set pretty_value $ad_form_value
                  }
                  if { $attribute == "url" } {
                      set ad_form_value [db_string url_from_party_id {} -default {}]
                      set pretty_value $ad_form_value
                  }
    
              } else {
    
                  set pretty_value $value
                  set ad_form_value $value
    
                  if { $storage_column == "address_id" } {
                      contacts::postal_address::get -address_id "$address_id" -array "address_info"
                      set ad_form_value [list $address_info(delivery_address) $address_info(municipality) $address_info(region) $address_info(postal_code) $address_info(country_code)]
                      set pretty_value "$address_info(delivery_address)\n$address_info(municipality), $address_info(region)  $address_info(postal_code)\n$address_info(country_code)"
                  }
                  if { $storage_column == "number_id" && [exists_and_not_null number_id] } { 
                      contacts::telecom_number::get -number_id $number_id -array "telecom_info"
                      set ad_form_value $telecom_info(subscriber_number)
                      set pretty_value $telecom_info(subscriber_number)
                  }
                  if { $storage_column == "time" && [exists_and_not_null time] } { 
                      set ad_form_value $time
                      set pretty_value $time
                  }
                  if { $storage_column == "option_map_id" && [exists_and_not_null option_map_id] } {
                      set pretty_value {}
                      set ad_form_value [list]
                      db_foreach select_options_from_map {} {
                          if { [llength $ad_form_value] > 0 } {
                              # we know there has been a previous entry so we can put in a comma
                              append pretty_value "\n"
                          }
                          append pretty_value $option
                          lappend ad_form_value $option_id
                      }
                  }
    
              }
              if { [exists_and_not_null ad_form_value] || [exists_and_not_null pretty_value] } {
                  incr sort_order
                  set pretty_value_html [ad_convert_to_html $pretty_value]
                  template::multirow append $multirow_name $attribute_name $attribute_id $pretty_attribute_name $ad_form_value $pretty_value $pretty_value_html $sort_order
              }
    
          }

        set orderby [split $orderby ","]
        set orderby_field [lindex $orderby 0]
        if { [lindex $orderby 1] == "asc" } {
            set orderby_direction {-increasing}
        } else {
            set orderby_direction {-decreasing}
        }
        template::multirow sort $multirow_name -dictionary $orderby_direction $orderby_field
    
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
            if { ![contact::exists_p $party_id] } {
                set party_id [contacts::contact::create -party_id $party_id]
            }
        } else {
            set party_id [contacts::contact::create]
        }
    

        set locale [lang::conn::locale -site_wide]

        set object_type [contact::get::object_type $party_id]

        set attr_value_temp ""

        db_foreach select_attributes {} {
    
            set attribute_value_temp [string trim [template::element::get_value entry "contact_attribute__$attribute"]]
            
            if { $storage_column == "address_id" } {
    
                # I need to verify that something has changed here
    
                set delivery_address [string trim [template::util::address::get_property delivery_address $attribute_value_temp]]
                set municipality     [string trim [template::util::address::get_property municipality     $attribute_value_temp]]
                set region           [string trim [template::util::address::get_property region           $attribute_value_temp]]
                set postal_code      [string trim [template::util::address::get_property postal_code      $attribute_value_temp]]
                set country_code     [string trim [template::util::address::get_property country_code     $attribute_value_temp]]
    
    
                set old_address_id ""
                db_0or1row select_old_address_id {}
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
                db_0or1row select_old_number_id {}
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
                    db_0or1row get_option_map_id {}

                    if { [exists_and_not_null option_map_id] } {
                        # we know that a previous entry exists
    
                        set old_option_ids ""
                        db_foreach get_old_options {} {
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
                            db_1row get_new_option_map_id {}

                            foreach option_id $attribute_value_temp {
                                if {![empty_string_p $option_id]} {
                                    db_dml insert_options_map {}
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
                    db_dml update_parties_email {}
                }
                if { $attribute == "url" } {
                    db_dml update_parties_url {}
                }
                if { $object_type == "organization" } {
                    # [list organization_name legal_name reg_number organization_type]
                    if { $attribute == "organization_name" } {
                        db_dml update_organizations_name {}
                    }
                    if { $attribute == "legal_name" } {
                        db_dml update_organizations_legal_name {}
                    }
                    if { $attribute == "reg_number" } {
                        db_dml update_organizations_reg_number {}
                    }
                    if { $attribute == "organization_type" } {
                        db_dml delete_org_type_maps {}
                        set attribute_value_temp [string trim [template::element::get_values entry "contact_attribute__$attribute"]]
                        foreach option_id $attribute_value_temp {
                            if {![empty_string_p $option_id]} {
                                db_1row get_organization_type_id {}


                                db_dml insert_mapping {}
                            }
                        }
                    }
                }
                if { $object_type == "person" } {
                    # [list first_names last_name]
                    if { $attribute == "first_names" } {
                        db_dml update_persons_first_names {}
                    }
                    if { $attribute == "last_name" } {
                        db_dml update_persons_last_name {}
                    }

                    
                }


            }








        }
    
        return $party_id     
    
    }


}
