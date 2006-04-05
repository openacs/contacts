<?xml version="1.0"?>
<queryset>

<fullquery name="contacts_pagination">
    <querytext>
	select 
		distinct p.party_id, $sort_item
  	from 
		parties p
	$left_join, cr_items ci, cr_revisions cr,
        group_distinct_member_map
 	where
	p.party_id = group_distinct_member_map.member_id
	and ci.item_id = p.party_id and ci.latest_revision = cr.revision_id
        and group_distinct_member_map.group_id in ('[join [contacts::default_groups] "','"]')
	[contact::search_clause -and -search_id $search_id -query $query -party_id "p.party_id" -revision_id "revision_id"]
	[template::list::orderby_clause -orderby -name "contacts"]
      </querytext>
</fullquery>

<fullquery name="organization_pagination">
    <querytext>
	select 
	organizations.organization_id as party_id
  	from organizations, cr_items ci, cr_revisions cr,
        group_distinct_member_map
 	where
	organizations.organization_id = group_distinct_member_map.member_id
        and group_distinct_member_map.group_id in ('[join [contacts::default_groups] "','"]')
	and ci.item_id = organizations.organization_id and ci.latest_revision = cr.revision_id
	[contact::search_clause -and -search_id $search_id -query $query -party_id "organizations.organization_id" -revision_id "revision_id"]
	[template::list::orderby_clause -orderby -name "contacts"]
      </querytext>
</fullquery>

<fullquery name="person_pagination">
    <querytext>
	select 
	persons.person_id as party_id
  	from persons, cr_items ci, cr_revisions cr,
        group_distinct_member_map
 	where
	persons.person_id = group_distinct_member_map.member_id
        and group_distinct_member_map.group_id in ('[join [contacts::default_groups] "','"]')
	and ci.item_id = persons.person_id and ci.latest_revision = cr.revision_id
	[contact::search_clause -and -search_id $search_id -query $query -party_id "persons.person_id" -revision_id "revision_id"]
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
       parties.url,
       to_char(cr.publish_date, :date_format) as publish_date
  from parties
      left join persons on (parties.party_id = persons.person_id)
      left join organizations on (parties.party_id = organizations.organization_id), cr_items ci, cr_revisions cr
 where  ci.item_id = party_id and ci.latest_revision = cr.revision_id
[template::list::page_where_clause -and -name "contacts" -key "party_id"]
$group_by_group_id
[template::list::orderby_clause -orderby -name "contacts"]
      </querytext>
</fullquery>

<fullquery name="report_contacts_select">
    <querytext>
        select distinct parties.party_id
          from parties,
               cr_items
         where parties.party_id = cr_items.item_id
           and parties.party_id in ( select group_approved_member_map.member_id
                                       from group_approved_member_map
                                      where group_approved_member_map.group_id in ([template::util::tcl_to_sql_list [contacts::default_group]]) )
        [contact::search_clause -and -search_id $search_id -query $query -party_id "parties.party_id" -revision_id "cr_items.live_revision"]
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
