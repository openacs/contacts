<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>


<fullquery name="get_latest_sort_order">
  <querytext>
        select sort_order from contact_attribute_object_map order by sort_order desc limit 1 
  </querytext>
</fullquery>


<fullquery name="map_attribute">
  <querytext>
        select contact__attribute_object_map_save(:object_id,:attribute_id,:sort_order,'f',null)
  </querytext>
</fullquery>


</queryset>
