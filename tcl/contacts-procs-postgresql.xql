<?xml version="1.0"?>
<queryset>

<fullquery name="contact::exists_p.exists_p">
  <querytext>
	select 1 from contacts where party_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contact::get.get_contact_info">
  <querytext>
	select * from contacts where party_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contact::get::array.select_address_info">
  <querytext>
	select * from contacts where party_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::util::party_is_user_p.get_party_is_user_p">
  <querytext>
	select '1' from users where user_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::util::next_object_id.get_next_object_id">
  <querytext>
	select nextval from acs_object_id_seq
  </querytext>
</fullquery>


<fullquery name="contacts::util::organization_object_id.get_organization_object_id">
  <querytext>
	select object_id from contact_object_types where object_type = 'organization'
  </querytext>
</fullquery>


<fullquery name="contacts::util::person_object_id.get_object_id">
  <querytext>
	select object_id from contact_object_types where object_type = 'person'
  </querytext>
</fullquery>


<fullquery name="contacts::get::ad_form_elements.select_attributes">
  <querytext>
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
  </querytext>
</fullquery>


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


<fullquery name="contact::get::values::multirow.first_names_from_party_id">
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


<fullquery name="contacts::get::values::multirow.select_options_from_map">
  <querytext>
        select cao.option, cao.option_id
          from contact_attribute_options cao,
               contact_attribute_option_map caom
         where caom.option_id = cao.option_id
           and caom.option_map_id = :option_map_id
  </querytext>
</fullquery>

<fullquery name="contacts::save::ad_form::values.select_attributes">
  <querytext>
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
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.select_old_address_id">
  <querytext>
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
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.select_old_number_id">
  <querytext>
        select cav.number_id as old_number_id
        from contact_attribute_values cav,
             telecom_numbers tn
        where cav.party_id = :party_id
           and cav.attribute_id = :attribute_id
           and not cav.deleted_p
           and cav.number_id = tn.number_id
           and tn.subscriber_number = :attribute_value_temp
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.get_option_map_id">
  <querytext>
        select option_map_id 
	from contact_attribute_values
	where party_id = :party_id
	   and attribute_id = :attribute_id and not deleted_p
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.get_old_options">
  <querytext>
        select option_id
	from contact_attribute_option_map 
	where option_map_id  = :option_map_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.get_new_option_map_id">
  <querytext>
        select nextval('contact_attribute_option_map_id_seq') as option_map_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.insert_options_map">
  <querytext>
        insert into contact_attribute_option_map
           (option_map_id,party_id,option_id)
        values
           (:option_map_id,:party_id,:option_id)
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_parties_email">
  <querytext>
        update parties set email = :attribute_value_temp where party_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_parties_url">
  <querytext>
        update parties set url = :attribute_value_temp where party_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_organizations_name">
  <querytext>
        update organizations set name = :attribute_value_temp where organization_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_organizations_legal_name">
  <querytext>
        update organizations set legal_name = :attribute_value_temp where organization_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_organizations_reg_number">
  <querytext>
        update organizations set reg_number = :attribute_value_temp where organization_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.delete_org_type_maps">
  <querytext>
        delete from organization_type_map where organization_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.get_organization_type_id">
  <querytext>
        select organization_type_id
        from contact_attribute_options cao,
             organization_types ot
        where cao.option = ot.type
           and cao.option_id  = :option_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.insert_mapping">
  <querytext>
        insert into organization_type_map
           (organization_id, organization_type_id)
        values
           (:party_id, :organization_type_id)
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_persons_first_names">
  <querytext>
        update persons set first_names = :attribute_value_temp where person_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_persons_last_name">
  <querytext>
        update persons set last_name = :attribute_value_temp where person_id = :party_id
  </querytext>
</fullquery>


</queryset>
