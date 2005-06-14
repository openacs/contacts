<?xml version="1.0"?>
<queryset>

<fullquery name="contacts_pagination">
      <querytext>
select parties.party_id
  from parties left join cr_items on (parties.party_id = cr_items.item_id) left join cr_revisions on (cr_items.latest_revision = cr_revisions.revision_id ) , group_distinct_member_map
 where parties.party_id = group_distinct_member_map.member_id
   and group_distinct_member_map.group_id = '-2'
[contact::search_clause -and -search_id $search_id -query $query -party_id "parties.party_id" -revision_id "revision_id"]
[template::list::orderby_clause -orderby -name "contacts"]
      </querytext>
</fullquery>

<fullquery name="contacts_select">      
      <querytext>
select contact__name(parties.party_id),
       parties.party_id,
       cr_revisions.revision_id,
       contact__name(parties.party_id,:name_order) as name,
       parties.email,
       ( select first_names from persons where person_id = party_id ) as first_names,
       ( select last_name from persons where person_id = party_id ) as last_name,
       ( select name from organizations where organization_id = party_id ) as organization
  from parties left join cr_items on (parties.party_id = cr_items.item_id) left join cr_revisions on (cr_items.latest_revision = cr_revisions.revision_id ) , group_distinct_member_map
 where parties.party_id = group_distinct_member_map.member_id
   and group_distinct_member_map.group_id = '-2'
[template::list::page_where_clause -and -name "contacts" -key "party_id"]
[template::list::orderby_clause -orderby -name "contacts"]
      </querytext>
</fullquery>

</queryset>
