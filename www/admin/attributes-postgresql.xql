<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>



<fullquery name="get_attributes">
  <querytext>
    select ca.widget_id,
           ca.attribute_id,
           ca.attribute,
           can.name,
           can.help_text,
           ca.depreciated_p,
           cw.description as widget_description
      from contact_attributes ca left join contact_attribute_names can on (can.attribute_id = ca.attribute_id),
           contact_widgets cw
     where cw.widget_id = ca.widget_id
       and can.locale = :locale
  [list::filter_where_clauses -and -name "entries"]
  [template::list::orderby_clause -orderby -name "entries"]
  </querytext>
</fullquery>

</queryset>
