<?xml version="1.0"?>
<queryset>

<fullquery name="contact::search::log.log_search">
  <querytext>
    select contact_search__log(:search_id,:user_id)
  </querytext>
</fullquery>

<fullquery name="contact::search::title.select_title">
  <querytext>
    select title
      from acs_objects
     where object_id = :search_id
  </querytext>
</fullquery>

<fullquery name="contact::search::get.select_search_info">
  <querytext>
    select contact_searches.*, acs_objects.title, acs_objects.package_id
      from contact_searches, acs_objects
     where contact_searches.search_id = :search_id
       and contact_searches.search_id = acs_objects.object_id
  </querytext>
</fullquery>


<fullquery name="contact::search_pretty_not_cached.select_conditions">
  <querytext>
    select type,
           var_list
      from contact_search_conditions
     where search_id = :search_id
  </querytext>
</fullquery>

<fullquery name="contact::search::results_count_not_cached.select_results_count">
  <querytext>
    select count(distinct party_id)
      from parties left join cr_items on (parties.party_id = cr_items.item_id) left join cr_revisions on (cr_items.latest_revision = cr_revisions.revision_id ) , group_distinct_member_map
     where parties.party_id = group_distinct_member_map.member_id
       and group_distinct_member_map.group_id in ('[join [contacts::default_groups] "','"]')
    [contact::search_clause -and -search_id $search_id -query $query -party_id "parties.party_id" -revision_id "revision_id"]
  </querytext>
</fullquery>

<fullquery name="contact::search::results_count_not_cached.get_condition_type">
  <querytext>
	select
                distinct type
        from
                contact_search_conditions
        where
                search_id = :search_id
  </querytext>
</fullquery>

<fullquery name="contact::search::results_count_not_cached.select_employees_results_count">
  <querytext>
        select
                count(object_id_one)
        from
                acs_rels
        where
                rel_type = 'contact_rels_employment'
  </querytext>
</fullquery>

<fullquery name="contact::search::where_clause_not_cached.get_search_info">
  <querytext>
    select title,
           owner_id,
           all_or_any,
           object_type
      from contact_searches
     where search_id = :search_id
  </querytext>
</fullquery>

<fullquery name="contact::search::where_clause_not_cached.select_queries">
  <querytext>
    select type,
           var_list
      from contact_search_conditions
     where search_id = :search_id
  </querytext>
</fullquery>

</queryset>
