ad_page_contract {


    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

} {
    {party_id:integer}
    {return_url ""}
    groupby:optional
    orderby:optional
    {format "normal"}
    {status "normal"}
}


set actions_list [list "Edit" "[apm_package_url_from_id [ad_conn package_id]]contact-ae?party_id=$party_id\&return_url=$return_url" "Edit [contact::name $party_id]"]

list::create \
    -name attributes \
    -multirow attributes \
    -key comment_id \
    -row_pretty_plural "Attributes" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
    } -actions $actions_list \
    -bulk_actions {
    } -bulk_action_export_vars { 
    } -elements {
        attribute {
            label "Attribute"
            display_col attribute_name
        }
        attribute_value {
            label "Value"
            display_col attribute_value_html;noquote
        }
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                attribute {}
                attribute_value {}
            }
        }
    }




set user_id [ad_conn user_id]
set object_type [contact::get::object_type $party_id]
if { $object_type == "organization" } {
    set object_id [contacts::util::organization_object_id]
}

if { $object_type == "person" } {
    set object_id [contacts::util::person_object_id]
}

db_multirow -extend { attribute_value_html attribute_name } attributes select_attributes {

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
                 contact_attribute_object_map caom, 
                     ( select * 
                         from contact_attribute_values 
                        where party_id = :party_id
                          and not deleted_p ) cav
            where caom.attribute_id = cav.attribute_id
              and caom.object_id = :object_id
              and caom.attribute_id = ca.attribute_id
              and ca.widget_id = cw.widget_id
              and not ca.depreciated_p
              and acs_permission__permission_p(ca.attribute_id,:user_id,'read')
            order by caom.sort_order
      } {

          set attribute_name [contacts::attribute::name $attribute_id]


          set attribute_value $value

          if { $storage_column == "address_id" } {
              contacts::postal_address::get -address_id "$address_id" -array "address_info"
              set attribute_value "$address_info(delivery_address)
$address_info(municipality), $address_info(region)  $address_info(postal_code)
$address_info(country_code)"
            }
          if { $storage_column == "number_id" && [exists_and_not_null number_id] } { 
              contacts::telecom_number::get -number_id $number_id -array "telecom_info"
              set attribute_value $telecom_info(subscriber_number)
          }
          if { $storage_column == "time" && [exists_and_not_null time] } { set attribute_value $time }
          if { $storage_column == "option_map_id" && [exists_and_not_null option_map_id] } {
              set attribute_value_temp ""
              db_foreach select_options_from_map {
select cao.option
  from contact_attribute_options cao,
       contact_attribute_option_map caom
 where caom.option_id = cao.option_id
   and caom.option_map_id = :option_map_id } {
       if { [exists_and_not_null attribute_value_temp] } {
       # we know there has been a previous entry so we can put in a comma
       append attribute_value_temp ", "
   }
                  append attribute_value_temp $option
              }
              set attribute_value_temp [string trim $attribute_value_temp]
              if { [exists_and_not_null attribute_value_temp] } {
                  set attribute_value $attribute_value_temp
              }
          }

          set attribute_value_html [ad_convert_to_html $attribute_value]
      }
















ad_return_template
