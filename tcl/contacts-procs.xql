<?xml version="1.0"?>
<queryset>
 
<fullquery name="contacts::get::values::multirow.select_attribute_values">
<querytext>

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
                          and not deleted_p ) cav
                 on (caom.attribute_id = cav.attribute_id)
           where caom.object_id = '$object_id'
             and caom.attribute_id = ca.attribute_id
             and ca.widget_id = cw.widget_id
             and not ca.depreciated_p
             and (
                      cav.option_map_id   is not null 
                   or cav.address_id      is not null
                   or cav.number_id       is not null
                   or cav.value           is not null
                   or cav.time            is not null
                   or ca.attribute in ($custom_field_sql_list)
                 )
             and acs_permission__permission_p(ca.attribute_id,'$user_id','$permission')
           order by caom.sort_order
</querytext>
</fullquery>

<fullquery name="contacts::get::values::multirow.organization_name_from_party_id">      
  <querytext>
        select name
          from organizations
         where organization_id = :party_id 
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.legal_name_from_party_id">      
  <querytext>
        select legal_name
          from organizations
         where organization_id = :party_id 
  </querytext>
</fullquery>

<fullquery name="contacts::get::values::multirow.reg_number_from_party_id">      
  <querytext>
        select reg_number
          from organizations
         where organization_id = :party_id 
  </querytext>
</fullquery>

<fullquery name="contacts::get::values::multirow.first_names_from_party_id">      
  <querytext>
        select first_names
          from persons
         where person_id = :party_id 
  </querytext>
</fullquery>

<fullquery name="contacts::get::values::multirow.last_name_from_party_id">      
  <querytext>
        select last_name
          from persons
         where person_id = :party_id
  </querytext>
</fullquery>

<fullquery name="contacts::get::values::multirow.email_from_party_id">
  <querytext>
        select email
          from parties
         where party_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.url_from_party_id">
  <querytext>
        select url
          from parties
         where party_id = :party_id
  </querytext>
</fullquery>

<fullquery name="contacts::get::values::multirow.organization_types_from_party_and_attribute_id">
  <querytext>
        select cao.option_id, cao.option 
          from contact_attribute_options cao,
               organization_types ot,
               organization_type_map otm
         where cao.option = ot.type
           and cao.attribute_id  = :attribute_id
           and otm.organization_type_id = ot.organization_type_id
           and otm.organization_id = :party_id
  </querytext>
</fullquery>

<fullquery name="contacts::get::values::multirow.">
  <querytext>
  </querytext>
</fullquery>


</queryset>
