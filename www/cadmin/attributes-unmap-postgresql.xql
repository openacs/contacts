<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>


<fullquery name="get_latest_sort_order">
  <querytext>
        select sort_order from contact_attribute_object_map order by sort_order desc limit 1 
  </querytext>
</fullquery>


<fullquery name="unmap_attribute">
  <querytext>
        delete from contact_attribute_object_map where object_id = :object_id and attribute_id = :attribute_id
  </querytext>
</fullquery>


</queryset>
