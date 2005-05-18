# /packages/mbryzek-subsite/www/admin/rel-types/index.tcl

ad_page_contract {

    Shows list of all defined relationship types, excluding the parent
    type "relationship"

    @author mbryzek@arsdigita.com
    @creation-date Sun Dec 10 17:10:56 2000
    @cvs-id $Id$

} {
} -properties {
    context:onevalue
    rel_types:multirow
}

set title "Relationship types"
set context [list $title]

set package_id [ad_conn package_id]

# Select out all relationship types, excluding the parent type names 'relationship'
# Count up the number of relations that exists for each type.
db_multirow -extend { primary_type_pretty secondary_type_pretty } rel_types get_rels {

select CASE WHEN primary_object_type = 'party' THEN '1' WHEN primary_object_type = 'person' THEN '2' ELSE '3' END as sort_one,
       CASE WHEN secondary_object_type = 'party' THEN '2' WHEN secondary_object_type = 'person' THEN '3' ELSE '4' END as sort_two,
       acs_rel_type__role_pretty_name(primary_role) as primary_role_pretty,
       acs_rel_type__role_pretty_name(secondary_role) as secondary_role_pretty,
       *
  from contact_rel_types
order by sort_one, sort_two, primary_role_pretty

} {
    switch $primary_object_type {
        party           { set primary_type_pretty "Person or Organization" }
        organization    { set primary_type_pretty "Organization" }
        person          { set primary_type_pretty "Person" }
    }
    switch $secondary_object_type {
        party           { set secondary_type_pretty "Person or Organization" }
        organization    { set secondary_type_pretty "Organization" }
        person          { set secondary_type_pretty "Person" }
    }

}
ad_return_template
