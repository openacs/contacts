<?xml version="1.0"?>
<queryset>

<fullquery name="public_searches">
      <querytext>
    select acs_objects.title,
           contact_searches.search_id
      from contact_searches,
           acs_objects
     where contact_searches.owner_id = :package_id
       and contact_searches.search_id = acs_objects.object_id
       and acs_objects.title is not null
       and not contact_searches.deleted_p
     order by lower(acs_objects.title)
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
