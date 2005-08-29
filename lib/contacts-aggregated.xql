<?xml version="1.0"?>
<queryset>

<fullquery name="get_attribute_options">
    <querytext>
	select 
                ot.option_id,
		ot.option 
	from 
		ams_option_types ot
	where 
		ot.attribute_id = :attr_id
    </querytext>
</fullquery>

<fullquery name="get_value_id">
    <querytext>
	select 
		value_id 
	from
		ams_options 
	where 
		option_id = :option_id
    </querytext>
</fullquery>

<fullquery name="get_results">
    <querytext>
    select 
         count(parties.party_id)
    from 
         parties
    where parties.party_id in (
          select 	
		parties.party_id
	  from 
                parties
                left join organizations on (parties.party_id = organizations.organization_id)
                left join cr_items on (parties.party_id = cr_items.item_id)
                left join cr_revisions on (cr_items.latest_revision = cr_revisions.revision_id ), 
                group_distinct_member_map
                where parties.party_id = group_distinct_member_map.member_id
                $search_clause
          ) 
          and parties.party_id in (
          select
               distinct
               p.party_id
          from
              ams_attribute_values a,
              cr_items i,
              parties p
          where
              a.object_id = i.latest_revision and
              i.item_id = p.party_id
              and a.value_id = $value_id )
    </querytext>
</fullquery>


</queryset>
