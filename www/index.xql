<?xml version="1.0"?>
<queryset>

<partialquery name="get_contact_info">
  <querytext>
select contacts.*, sort_$sortby as contact_name
  from contacts
 where party_id is not null
       [template::list::filter_where_clauses -and -name entries]
       [template::list::orderby_clause -orderby -name entries]
       limit $num_rows offset $start_row
  </querytext>
</partialquery>


</queryset>


