<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="template::data::transform::contact_search.search_persons">      
      <querytext>
	select CASE WHEN parties.email is not null THEN contact__name(persons.person_id) || ' &lt;' || parties.email || '&gt;' ELSE contact__name(persons.person_id) END || to_char(persons.person_id,' #FM999999999999999999999999'), persons.person_id
          from persons, parties, group_distinct_member_map
         where persons.person_id = parties.party_id
           and persons.person_id = group_distinct_member_map.member_id
           and group_distinct_member_map.group_id  = [contacts::default_group -package_id $package_id]
           and persons.person_id in ( select member_id from group_distinct_member_map where group_id = '11428599')
      [contact::search::query_clause -and -query $query -party_id "persons.person_id"]
         order by lower(contact__name(persons.person_id,'f')) asc
	 limit 51
      </querytext>
</fullquery>

<fullquery name="template::data::transform::contact_search.search_orgs">
      <querytext>
	select contact__name(organizations.organization_id) || to_char(organizations.organization_id,' #FM999999999999999999999999'), organizations.organization_id
          from organizations, parties, group_distinct_member_map
         where organizations.organization_id = parties.party_id
           and organizations.organization_id = group_distinct_member_map.member_id
           and group_distinct_member_map.group_id  = [contacts::default_group -package_id $package_id]
           and organizations.organization_id in ( select member_id from group_distinct_member_map where group_id = '11428599')
      [contact::search::query_clause -and -query $query -party_id "organizations.organization_id"]
         order by lower(contact__name(organizations.organization_id,'f')) asc
         limit 51
      </querytext>
</fullquery>

</queryset>
