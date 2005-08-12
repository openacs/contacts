<?xml version="1.0"?>
<queryset>

<fullquery name="contacts_pagination">
      <querytext>
select parties.party_id, organizations.name,
      first_names, last_name
  from parties
      left join persons on (parties.party_id = persons.person_id)
      left join organizations on (parties.party_id = organizations.organization_id), group_distinct_member_map, cr_items, cr_revisions
 where parties.party_id = group_distinct_member_map.member_id
   and parties.party_id = cr_items.item_id
   and cr_items.latest_revision = cr_revisions.revision_id
   and group_distinct_member_map.group_id $where_group_id
[contact::search_clause -and -search_id $search_id -query $query -party_id "parties.party_id" -revision_id "revision_id"]
[template::list::orderby_clause -orderby -name "contacts"]
      </querytext>
</fullquery>

<fullquery name="contacts_select">      
      <querytext>
select organizations.name,
      first_names, last_name,
       parties.party_id,
       parties.email,
       parties.url
  from parties 
      left join persons on (parties.party_id = persons.person_id)
      left join organizations on (parties.party_id = organizations.organization_id), group_distinct_member_map
 where parties.party_id = group_distinct_member_map.member_id
   and group_distinct_member_map.group_id $where_group_id
[template::list::page_where_clause -and -name "contacts" -key "party_id"]
$group_by_group_id
[template::list::orderby_clause -orderby -name "contacts"]
      </querytext>
</fullquery>

</queryset>
