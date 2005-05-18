<?xml version="1.0"?>
<queryset>


<fullquery name="contacts::attribute::create.create_attribute">
  <querytext>
        select contact__attribute_create (
					null,
					:widget_id,
					:label,
					:help_text,
					:help_p,
					:html,
					:format,
					now(),
					:creation_user,
					:creation_ip
					)
  </querytext>
</fullquery>


<fullquery name="contacts::attribute::delete.delete_attribute">
  <querytext>
        select contact__attribute_delete (
					:attribute_id
					)
  </querytext>
</fullquery>


<fullquery name="contacts::attribute::name.get_attribute_name">
  <querytext>
        select name from contact_attribute_names where attribute_id = :attribute_id and locale = :locale
  </querytext>
</fullquery>


<fullquery name="contacts::attribute::name.get_view_name">
  <querytext>
        select name from contact_view_names where attribute_id = :attribute_id and locale = :locale
  </querytext>
</fullquery>


<fullquery name="contacts::attribute::value::save.attribute_value_save">
  <querytext>
        select contact__attribute_value_save (
					:party_id,
					:attribute_id,
					:option_map_id,
					:address_id,
					:number_id,
					:time,
					:value,
					:deleted_p,
					now(),
					:creation_user,
					:creation_ip
					)
  </querytext>
</fullquery>


<fullquery name="contacts::postal_address::new.postal_address_new">
  <querytext>
        select postal_address__new (
				:additional_text,
				null,
				:country_code,
				:delivery_address,
				:municipality,
				null,
				:postal_code,
				:postal_type,
				:region,
				:creation_user,
				:creation_ip,
				null
				)
  </querytext>
</fullquery>


<fullquery name="contacts::postal_address::get.select_address_info">
  <querytext>
        select * from postal_addresses where address_id = :address_id
  </querytext>
</fullquery>


<fullquery name="contacts::telecom_number::new.telecom_number_new">
  <querytext>
        select telecom_number__new (
                             :area_city_code,
                             :best_contact_time,
                             :extension,
                             :itu_id,
                             :location,
                             :national_number,
                             null,
                             null,
                             null,
                             :sms_enabled_p,
                             :subscriber_number,
                             :creation_user,
                             :creation_ip,
                             null
                             )
  </querytext>
</fullquery>


<fullquery name="contacts::telecom_number::get.select_telecom_number_info">
  <querytext>
        select * from telecom_numbers where number_id = :number_id
  </querytext>
</fullquery>


</queryset>
