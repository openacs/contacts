<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>



<fullquery name="answer_optional">
  <querytext>
        update contact_attribute_object_map set required_p = 'f' where object_id = :object_id and attribute_id = :attribute_id
  </querytext>
</fullquery>

</queryset>
