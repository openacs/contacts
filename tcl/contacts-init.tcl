ad_library {
    
    Init file for contacts
    
    @author Matthew Geddert (openacs@geddert.com)
    @creation-date 2004-08-16
    @cvs-id $Id$
}


set attribute_id [attribute::new \
              -object_type "person" \
              -attribute_name "first_names" \
              -datatype "string" \
              -pretty_name "First Names" \
              -pretty_plural "First Names" \
              -table_name "" \
              -column_name "" \
              -default_value "" \
              -min_n_values "0" \
              -max_n_values "1" \
              -sort_order "1" \
              -storage "type_specific" \
              -static_p "f" \
                      -if_does_not_exist]

ams::attribute::new \
              -attribute_id $attribute_id \
              -widget "textbox" \
              -dynamic_p "f"

set attribute_id [attribute::new \
              -object_type "person" \
              -attribute_name "last_name" \
              -datatype "string" \
              -pretty_name "Last Name" \
              -pretty_plural "Last Names" \
              -table_name "" \
              -column_name "" \
              -default_value "" \
              -min_n_values "0" \
              -max_n_values "1" \
              -sort_order "1" \
              -storage "type_specific" \
              -static_p "f" \
                      -if_does_not_exist]

ams::attribute::new \
              -attribute_id $attribute_id \
              -widget "textbox" \
              -dynamic_p "f"

set attribute_id [attribute::new \
              -object_type "party" \
              -attribute_name "email" \
              -datatype "string" \
              -pretty_name "Email Address" \
              -pretty_plural "Email Addresses" \
              -table_name "" \
              -column_name "" \
              -default_value "" \
              -min_n_values "0" \
              -max_n_values "1" \
              -sort_order "1" \
              -storage "type_specific" \
              -static_p "f" \
                      -if_does_not_exist]

ams::attribute::new \
              -attribute_id $attribute_id \
              -widget "email" \
              -dynamic_p "f"

set attribute_id [attribute::new \
              -object_type "organization" \
              -attribute_name "name" \
              -datatype "string" \
              -pretty_name "Name" \
              -pretty_plural "Names" \
              -table_name "" \
              -column_name "" \
              -default_value "" \
              -min_n_values "1" \
              -max_n_values "1" \
              -sort_order "1" \
              -storage "generic" \
              -static_p "f" \
                      -if_does_not_exist]

ams::attribute::new \
              -attribute_id $attribute_id \
              -widget "textbox" \
              -dynamic_p "t"

