<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>



<fullquery name="depreciate_attribute">
  <querytext>
        update contact_attributes set depreciated_p = 't' where attribute_id = :attribute_id
  </querytext>
</fullquery>



</queryset>
