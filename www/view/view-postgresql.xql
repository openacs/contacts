<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>



<fullquery name="select_views">
  <querytext>

    select view_id
      from contact_views
     where contact_object_type = :object_type
       and acs_permission__permission_p(privilege_object_id,:user_id,privilege_required)
     order by sort_order

  </querytext>
</fullquery>

</queryset>
