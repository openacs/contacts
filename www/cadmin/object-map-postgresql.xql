<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>



<fullquery name="get_object_name">
  <querytext>
        select acs_object__name(:object_id) as object_name
  </querytext>
</fullquery>


<fullquery name="get_mapped_courses">
  <querytext>
    select ca.attribute_id,
           ca.attribute,
           can.name,
           can.help_text,
           caom.required_p,
           caom.sort_order,
           cw.description as widget_description
      from contact_attribute_object_map caom,
           contact_attributes ca left join contact_attribute_names can on (can.attribute_id = ca.attribute_id),
           contact_widgets cw
     where caom.attribute_id = ca.attribute_id
       and cw.widget_id = ca.widget_id
       and can.locale = :locale
       and not ca.depreciated_p
       and caom.object_id = :object_id
     order by caom.sort_order asc
  </querytext>
</fullquery>


<fullquery name="get_unmapped_courses">
  <querytext>

    select ca.attribute_id,
           ca.attribute,
           can.name,
           can.help_text,
           cw.description as widget_description
      from contact_attributes ca left join contact_attribute_names can on (can.attribute_id = ca.attribute_id),
           contact_widgets cw
     where cw.widget_id = ca.widget_id
       and can.locale = :locale
       and not ca.depreciated_p
       and ca.attribute_id not in ( select attribute_id from contact_attribute_object_map where object_id = :object_id)
     order by upper(can.name) asc

  </querytext>
</fullquery>


</queryset>
