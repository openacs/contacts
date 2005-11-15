<?xml version="1.0"?>
<queryset>

<fullquery name="contacts_pagination">
    <querytext>
	select 
		distinct parties.party_id, $sort_item
  	from 
		parties
	$left_join
      	left join cr_items on (parties.party_id = cr_items.item_id) 
      	left join cr_revisions on (cr_items.latest_revision =
      	cr_revisions.revision_id ), group_distinct_member_map
 	where 
	parties.party_id = group_distinct_member_map.member_id
   	$group_where_clause
	[contact::search_clause -and -search_id $search_id -query $query -party_id "parties.party_id" -revision_id "revision_id"]
	[template::list::orderby_clause -orderby -name "contacts"]
      </querytext>
</fullquery>

<fullquery name="contacts_select">      
      <querytext>
select  $extend_query
	organizations.name,
      first_names, last_name,
       parties.party_id,
       parties.email,
       parties.url
  from parties 
      left join persons on (parties.party_id = persons.person_id)
      left join organizations on (parties.party_id = organizations.organization_id)
 where 1 = 1
[template::list::page_where_clause -and -name "contacts" -key "party_id"]
$group_by_group_id
[template::list::orderby_clause -orderby -name "contacts"]
      </querytext>
</fullquery>

<fullquery name="get_default_extends">
    <querytext>
	select 
		csem.extend_id 
	from 
		contact_search_extend_map csem,
		contact_extend_options ceo
	where 
		ceo.extend_id = csem.extend_id
		and ceo.aggregated_p = 'f'
		and csem.search_id = :search_id 
    </querytext>
</fullquery>

<fullquery name="get_object_type">
    <querytext>
	select 
		object_type 
	from 
		contact_searches 
	where 
		search_id = :search_id
    </querytext>
</fullquery>

</queryset>
