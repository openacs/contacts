<?xml version="1.0"?>
<queryset>

<fullquery name="contacts_pagination">
    <querytext>
	select 
		parties.party_id
  	from 
		parties
      	left join persons on (parties.party_id = persons.person_id)
      	left join organizations on (parties.party_id =
      	organizations.organization_id)
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
		extend_id 
	from 
		contact_search_extend_map 
	where 
		search_id = :search_id 
    </querytext>
</fullquery>

<fullquery name="get_ams_options">
    <querytext>
	select 
		lam.attribute_id 
	from 
		ams_list_attribute_map lam,
		ams_lists l
	where 
		lam.list_id = l.list_id
		and l.list_name like '%-2'
		$attribute_values_query
    </querytext>
</fullquery>

<fullquery name="get_ams_pretty_name">
    <querytext>
	select
		a.pretty_name
	from
	    	ams_attributes a
	where
	    	a.attribute_id = :attribute
    </querytext>
</fullquery>

<fullquery name="get_ams_info">
    <querytext>
	select
		a.attribute_name as name,
		a.pretty_name
	from
	    	ams_attributes a
	where
	    	a.attribute_id = :attribute
    </querytext>
</fullquery>

<fullquery name="get_attr_object_id">
    <querytext>
	select 
	    	av.object_id
	from 
	   	ams_attribute_values av,
	    	acs_objects o,
	    	parties p
	where 
	    	av.object_id = o.object_id
	    	and o.context_id = p.party_id
	    	and p.party_id = :party_id
	    	and attribute_id = :attribute_id
    </querytext>
</fullquery>
</queryset>
