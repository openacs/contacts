<?xml version="1.0"?>
<queryset>

<fullquery name="select_owner_options">
      <querytext>
      select CASE WHEN owner_id = :user_id
                  THEN '\#contacts.My_Searches\#'
                  ELSE contact__name(owner_id) END,
             owner_id
        from ( select distinct owner_id
                 from contact_searches
                where ( title is not null or owner_id = :user_id )
                  and owner_id in ( select party_id from parties )) distinct_owners
        order by CASE WHEN owner_id = :user_id THEN '0000000000000000000' ELSE upper(contact__name(owner_id)) END
      </querytext>
</fullquery>

<fullquery name="select_searches">
      <querytext>
(    select search_id, title, upper(title) as order_title, all_or_any, object_type
       from contact_searches
      where owner_id = :owner_id
        and title is not null
        and not deleted_p
) union (
     select search_id, 'Search \#' || to_char(search_id,'FM9999999999999999999') || ' on ' || to_char(creation_date,'Mon FMDD') as title, 'zzzzzzzzzzz' as order_title, all_or_any, contact_searches.object_type
       from contact_searches, acs_objects
      where owner_id = :owner_id
        and search_id = object_id
        and contact_searches.title is null
        and not deleted_p
      limit 10
)
      order by order_title
      </querytext>
</fullquery>

<fullquery name="get_saved_p">
    <querytext>
	select
		aggregated_attribute
	from
		contact_searches
	where
		search_id = :search_id
		and aggregated_attribute is not null
    </querytext>
</fullquery>

</queryset>
