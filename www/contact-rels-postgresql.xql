<?xml version="1.0"?>
<queryset>

<fullquery name="get_valid_object_types">
      <querytext>
select primary_object_type
  from contact_rel_types
 where primary_role = :role_two 
      </querytext>
</fullquery>

<fullquery name="get_rels">
      <querytext>
select acs_rel_type__role_pretty_name(primary_role),
       primary_role
  from contact_rel_types
 where secondary_object_type in ( :contact_type, 'party' )
 group by primary_role
 order by upper(acs_rel_type__role_pretty_name(primary_role))
      </querytext>
</fullquery>

<fullquery name="get_relationships">
      <querytext>
select rel_id, other_name, other_party_id, role_singular, rel_type, object_id_one, object_id_two
from 
(
    select CASE WHEN object_id_one = :party_id THEN contact__name(object_id_two) ELSE contact__name(object_id_one) END as other_name,
           CASE WHEN object_id_one = :party_id THEN object_id_two ELSE object_id_one END as other_party_id,
           CASE WHEN object_id_one = :party_id THEN role_two ELSE role_one END as role,
           CASE WHEN object_id_one = :party_id THEN acs_rel_type__role_pretty_name(role_two) ELSE acs_rel_type__role_pretty_name(role_one) END as role_singular,
           CASE WHEN object_id_one = :party_id THEN acs_rel_type__role_pretty_plural(role_two) ELSE acs_rel_type__role_pretty_name(role_two) END as role_plural,
           role_one, role_two,
           acs_rels.rel_id, acs_rels.rel_type, object_id_one, object_id_two
      from acs_rels,
           acs_rel_types
     where acs_rels.rel_type = acs_rel_types.rel_type
       and ( object_id_one = :party_id or object_id_two = :party_id )
       and acs_rels.rel_type in ( select object_type from acs_object_types where supertype = 'contact_rel')
) rels_temp
[template::list::orderby_clause -orderby -name "relationships"]
      </querytext>
</fullquery>

</queryset>
