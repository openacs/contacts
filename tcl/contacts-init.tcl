ad_library {
    
    Init file for contacts
    
    @author Matthew Geddert (openacs@geddert.com)
    @creation-date 2004-08-16
}

set attribute_id [attribute::new \
              -object_type "person" \
              -attribute_name "last_name" \
              -datatype "string" \
              -pretty_name "#ams.person_last_name#" \
              -pretty_plural "#ams.person_last_name_plural#" \
              -table_name "" \
              -column_name "" \
              -default_value "" \
              -min_n_values "0" \
              -max_n_values "1" \
              -sort_order "1" \
              -storage "type_specific" \
              -static_p "f" \
                      -if_does_not_exist]

lang::message::register en_US ams person_last_name "First Names" 
lang::message::register en_US ams person_last_name_plural "First Names"

ams::attribute::new \
              -attribute_id $attribute_id \
              -widget "textbox" \
              -dynamic_p "f"

set attribute_id [attribute::new \
              -object_type "person" \
              -attribute_name "first_names" \
              -datatype "string" \
              -pretty_name "#ams.person_first_names#" \
              -pretty_plural "#ams.person_first_names_plural#" \
              -table_name "" \
              -column_name "" \
              -default_value "" \
              -min_n_values "0" \
              -max_n_values "1" \
              -sort_order "1" \
              -storage "type_specific" \
              -static_p "f" \
                      -if_does_not_exist]

lang::message::register en_US ams person_first_names "Last Name" 
lang::message::register en_US ams person_first_names_plural "Last Names"

ams::attribute::new \
              -attribute_id $attribute_id \
              -widget "textbox" \
              -dynamic_p "f"

set attribute_id [attribute::new \
              -object_type "party" \
              -attribute_name "email" \
              -datatype "string" \
              -pretty_name "#ams.party_email#" \
              -pretty_plural "#ams.party_email_plural#" \
              -table_name "" \
              -column_name "" \
              -default_value "" \
              -min_n_values "0" \
              -max_n_values "1" \
              -sort_order "1" \
              -storage "type_specific" \
              -static_p "f" \
                      -if_does_not_exist]

lang::message::register en_US ams party_email "Email Address"
lang::message::register en_US ams party_email_plural "Email Addresses"

ams::attribute::new \
              -attribute_id $attribute_id \
              -widget "email" \
              -dynamic_p "f"

set attribute_id [attribute::new \
              -object_type "organization" \
              -attribute_name "name" \
              -datatype "string" \
              -pretty_name "#ams.organization_name#" \
              -pretty_plural "#ams.organization_name_plural#" \
              -table_name "" \
              -column_name "" \
              -default_value "" \
              -min_n_values "1" \
              -max_n_values "1" \
              -sort_order "1" \
              -storage "generic" \
              -static_p "f" \
                      -if_does_not_exist]

lang::message::register en_US ams organization_name "Organization Name"
lang::message::register en_US ams organization_name_plural "Organization Names"

ams::attribute::new \
              -attribute_id $attribute_id \
              -widget "textbox" \
              -dynamic_p "t"

