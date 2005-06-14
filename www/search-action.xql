<?xml version="1.0"?>
<queryset>

<fullquery name="select_search_info">
      <querytext>
      select title,
             owner_id as old_owner_id,
             all_or_any,
             object_type
        from contact_searches
       where search_id = :search_id
      </querytext>
</fullquery>

<fullquery name="update_owner">
      <querytext>
      update contact_searches
         set owner_id = :owner_id
       where search_id = :search_id
      </querytext>
</fullquery>

<fullquery name="select_similar_titles">
      <querytext>
      select title
        from contact_searches
       where owner_id = :owner_id
         and upper(title) like upper('${title}%')
      </querytext>
</fullquery>

<fullquery name="select_search_conditions">
      <querytext>
      select type,
             var_list
        from contact_search_conditions
       where search_id = :search_id
      </querytext>
</fullquery>

</queryset>
