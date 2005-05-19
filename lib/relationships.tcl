#    @author Matthew Geddert openacs@geddert.com
#    @creation-date 2005-05-09
#    @cvs-id $Id$

if { [string is false [contact::exists_p -party_id $party_id]] } {
    error "The party_id specified does not exist"
}


db_multirow -extend {contact_url} relationships get_relationships { 
select rel_id, other_name, other_party_id, role, role_singular, role_plural
from 
(
    select rel_id,
           CASE WHEN object_id_one = :party_id THEN contact__name(object_id_two) ELSE contact__name(object_id_one) END as other_name,
           CASE WHEN object_id_one = :party_id THEN object_id_two ELSE object_id_one END as other_party_id,
           CASE WHEN object_id_one = :party_id THEN role_two ELSE role_one END as role,
           CASE WHEN object_id_one = :party_id THEN acs_rel_type__role_pretty_name(role_two) ELSE acs_rel_type__role_pretty_name(role_one) END as role_singular,
           CASE WHEN object_id_one = :party_id THEN acs_rel_type__role_pretty_plural(role_two) ELSE acs_rel_type__role_pretty_name(role_two) END as role_plural
      from acs_rels,
           acs_rel_types
     where acs_rels.rel_type = acs_rel_types.rel_type
       and ( object_id_one = :party_id or object_id_two = :party_id )
       and acs_rels.rel_type in ( select object_type from acs_object_types where supertype = 'contact_rel')
) rels_temp
order by upper(role_singular), upper(other_name)
} {
    set contact_url [contact::url -party_id $other_party_id]
}
