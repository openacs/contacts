<?xml version="1.0"?>
<queryset>

<fullquery name="get_relationships">
      <querytext>
select rel_id, other_name, other_party_id, role_singular, role_plural, rel_type
  from ( select CASE WHEN object_id_one = :party_id THEN contact__name(object_id_two,'t') ELSE contact__name(object_id_one,'t') END as other_name,
		CASE WHEN object_id_one = :party_id THEN object_id_two ELSE object_id_one END as other_party_id,
                CASE WHEN object_id_one = :party_id THEN role_two ELSE role_one END as role,
                CASE WHEN object_id_one = :party_id THEN acs_rel_type__role_pretty_name(role_two) ELSE acs_rel_type__role_pretty_name(role_one) END as role_singular,
                CASE WHEN object_id_one = :party_id THEN acs_rel_type__role_pretty_plural(role_two) ELSE acs_rel_type__role_pretty_name(role_two) END as role_plural,
                acs_rels.rel_id, acs_rels.rel_type
           from acs_rels,
                acs_rel_types
          where acs_rels.rel_type = acs_rel_types.rel_type
            and ( object_id_one = :party_id or object_id_two = :party_id )
            and acs_rels.rel_type in ( select object_type from acs_object_types where supertype = 'contact_rel')
       ) rels_temp
 order by upper(role_singular) asc, upper(other_name)
      </querytext>
</fullquery>

</queryset>
