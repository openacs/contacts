<?xml version="1.0"?>
<queryset>

<fullquery name="contacts::view::create.select_last_sort_order_value">
  <querytext>
        select sort_order 
	from contact_views 
	where contact_object_type = :contact_object_type 
	order by sort_order desc limit 1
  </querytext>
</fullquery>


<fullquery name="contacts::view::create.create_contact_view">
  <querytext>
        select contact__view_create(
				null,
				:src,
				:privilege_required,
				:privilege_object_id,
				:contact_object_type,
				:package_id,
				:sort_order,
				now(),
				:creation_user,
				:creation_ip,
				:context_id) as view_id
  </querytext>
</fullquery>


<fullquery name="contacts::view::name.save_view_name">
  <querytext>
        select contact__view_name_save(
				:view_id,
				:locale,
				:name
				)
  </querytext>
</fullquery>


<fullquery name="contacts::view::init.views_exist_p">
  <querytext>
        select '1' from contact_views limit 1
  </querytext>
</fullquery>


<fullquery name="contacts::view::init.get_package_id">
  <querytext>
        select package_id from apm_packages where package_key = 'contacts'
  </querytext>
</fullquery>


<fullquery name="contacts::view::exists_p.exists_p_select">
  <querytext>
        select 1 from contact_views where view_id = :view_id and contact_object_type = :object_type
  </querytext>
</fullquery>


<fullquery name="contacts::view::get.get_view_info">
  <querytext>
        select *
        from contact_views
        where view_id = :view_id
  </querytext>
</fullquery>


<fullquery name="contacts::view::get::name.get_view_name">
  <querytext>
        select name from contact_view_names where view_id = :view_id and locale = :locale
  </querytext>
</fullquery>

<fullquery name="contacts::view::get::first_view_id.get_first_view_id">
  <querytext>
        select view_id from contact_views where contact_object_type = :object_type order by sort_order limit 1 
  </querytext>
</fullquery>

</queryset>
