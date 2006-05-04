<?xml version="1.0"?>
<queryset>

<fullquery name="get_relationships">
      <querytext>
select rel_id, other_name, other_party_id, role_singular, rel_type, creation_date
  from ( select CASE WHEN object_id_one = :party_id THEN contact__name(object_id_two,'t') ELSE contact__name(object_id_one,'t') END as other_name,
		CASE WHEN object_id_one = :party_id THEN object_id_two ELSE object_id_one END as other_party_id,
                CASE WHEN object_id_one = :party_id THEN role_two ELSE role_one END as role,
                CASE WHEN object_id_one = :party_id THEN acs_rel_type__role_pretty_name(role_two) ELSE acs_rel_type__role_pretty_name(role_one) END as role_singular,
                acs_rels.rel_id, acs_rels.rel_type
           from acs_rels,
                acs_rel_types
          where acs_rels.rel_type = acs_rel_types.rel_type
	    and acs_objects.object_id = acs_rels.rel_id
            and ( object_id_one = :party_id or object_id_two = :party_id )
            and acs_rels.rel_type in ( select object_type from acs_object_types where supertype = 'contact_rel')
       ) rels_temp, acs_objects, group_distinct_member_map
	where rels_temp.rel_id = acs_objects.object_id
          and rels_temp.other_party_id = group_distinct_member_map.member_id
          and group_distinct_member_map.group_id in ([template::util::tcl_to_sql_list [contacts::default_groups]])
 order by upper(role_singular) asc, $sort_order
      </querytext>
</fullquery>

</queryset>
