<?xml version="1.0"?>
<queryset>

<fullquery name="select_searches">
      <querytext>
(    select search_id, title, upper(title) as order_title, all_or_any, object_type, owner_id
       from contact_searches
      where 
        title is not null
        and not deleted_p
) union (
     select search_id, 'Search \#' || to_char(search_id,'FM9999999999999999999') || ' on ' || to_char(creation_date,'Mon FMDD') as title, 'zzzzzzzzzzz' as order_title, all_or_any, contact_searches.object_type, owner_id
       from contact_searches, acs_objects
      where
	search_id = object_id
        and contact_searches.title is null
        and not deleted_p
      limit 10
)
      order by order_title
      </querytext>
</fullquery>

</queryset>
