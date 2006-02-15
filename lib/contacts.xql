<?xml version="1.0"?>
<queryset>

<fullquery name="contacts_pagination">
    <querytext>
	select 
		distinct parties.party_id, $sort_item
  	from 
		$last_modified_join parties
	$left_join
      	left join cr_items on (parties.party_id = cr_items.item_id) 
      	left join cr_revisions on (cr_items.latest_revision = cr_revisions.revision_id ),
        group_distinct_member_map
 	where
	parties.party_id = group_distinct_member_map.member_id
        and group_distinct_member_map.group_id in ('[join [contacts::default_groups] "','"]')
   	$last_modified_clause
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
  from $last_modified_join parties
      left join persons on (parties.party_id = persons.person_id)
      left join organizations on (parties.party_id = organizations.organization_id)
 where 1 = 1
$last_modified_clause
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

<fullquery name="employees_select">
    <querytext>
	select distinct
	$extend_query
	rel.object_id_one as party_id,
	rel.object_id_two as employee_id
  	from 
	acs_rels rel,
	parties p
 	where 
	rel.rel_type = 'contact_rels_employment'
	and rel.object_id_one = p.party_id
	[template::list::page_where_clause -and -name "contacts" -key "party_id"]
    </querytext>
</fullquery>

<fullquery name="employees_pagination">
    <querytext>
	select 
	rel.object_id_one as party_id,
	rel.object_id_two as employee_id
  	from 
	acs_rels rel, persons p
 	where 
	rel.rel_type = 'contact_rels_employment'
	and person_id = object_id_one
	order by last_name
    </querytext>
</fullquery>

<fullquery name="get_search_object_type">
    <querytext>
	select 
		object_type 
	from 
		contact_searches 
	where 
		search_id = :search_id
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

<fullquery name="get_condition_type">
    <querytext>
	select 
		type 
	from
		contact_search_conditions
	where 
		search_id = :search_id
    </querytext>
</fullquery>

</queryset>
