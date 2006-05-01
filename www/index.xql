<?xml version="1.0"?>
<queryset>

<fullquery name="public_searches">
      <querytext>
    select title,
           search_id
      from contact_searches
     where owner_id = :package_id
       and title is not null
       and not deleted_p
     order by lower(title)
      </querytext>
</fullquery>

<fullquery name="my_recent_searches">
      <querytext>
    select ao.title as recent_title,
           cs.search_id as recent_search_id
      from contact_searches cs, contact_search_log csl, acs_objects ao
     where csl.user_id = :user_id
       and cs.search_id = csl.search_id
       and cs.search_id = ao.object_id
       and ao.title is not null
       and cs.owner_id != :package_id
       and not cs.deleted_p
     order by csl.last_search desc
     limit 10
      </querytext>
</fullquery>

</queryset>
