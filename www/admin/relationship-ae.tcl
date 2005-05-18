# /packages/mbryzek-subsite/www/admin/rel-type/new.tcl

ad_page_contract {

    Form to create a new relationship type

    @author mbryzek@arsdigita.com
    @creation-date Sun Nov 12 18:27:08 2000
    @cvs-id $Id$

} {
    rel_type:optional
    {return_url "relationships"}
} -properties {
} -validate {
    type_exists -requires {rel_type} {
	if { ![db_0or1row get_it { select 1 from contact_rel_types where rel_type = :rel_type}] } {
	    ad_complain "The contact specified does not exist"
	}
    }
}
set title "Add relationship type"
set context [list [list "[ad_conn package_url]admin/relationships" "Relationship types"] $title]

set object_types_list {
    {{Person or Organization} party}
    {{Person} person}
    {{Organization} organization}
}


set roles_list {{{--select one--} {}}}
append roles_list " [db_list_of_lists select_roles {
    select r.pretty_name, r.role
      from acs_rel_roles r
     order by lower(r.role)
}]"

ad_form -name "rel_type" \
    -form {
        {return_url:text(hidden),optional}
        {object_type_one:text(select) {label "Contact Type One"} {options $object_types_list}}
        {role_one:text(select) {label "Role One"} {options $roles_list}}
        {object_type_two:text(select) {label "Contact Type Two"} {options $object_types_list}}
        {role_two:text(select) {label "Role Two"} {options $roles_list}}
    } -on_request {
#        if { [exists_and_not_null rel_type] } {
#            db_1row get_them { select * from acs_rel_types where rel_type=:rel_type }
#        }
    } -on_submit {

        foreach role $roles_list {
            if { [lindex $role 1] == $role_one } { set role_one_pretty [lindex $role 0] }
            if { [lindex $role 1] == $role_two } { set role_two_pretty [lindex $role 0] }
        }
        set pretty_name "Contact Rel $role_one_pretty (${object_type_one}) -> $role_two_pretty (${object_type_two})"
        set pretty_plural "Contact Rels $role_one_pretty (${object_type_one}) -> $role_two_pretty (${object_type_two})"
        set rel_type [util_text_to_url -text "Contact Rels $role_one $role_two" \
                      -replacement "_" \
                      -existing_urls [db_list get_roles { select object_type from acs_object_types }]]


        set next_object_id [db_string getid { select acs_object_id_seq.nextval }]
        set table_name "contact_rel_${next_object_id}"
        set package_name "contact_rel__${next_object_id}"

        db_1row create_rel {
            select acs_rel_type__create_type (
                                              :rel_type,
                                              :pretty_name,
                                              :pretty_plural,
                                              'contact_rel',
                                              :table_name,
                                              'rel_id',
                                              :package_name,
                                              :object_type_one,
                                              :role_one,
                                              0,
                                              NULL,
                                              :object_type_two,
                                              :role_two,
                                              0,
                                              NULL
                                              )
        }

    
    } -after_submit {
    ad_returnredirect $return_url
    ad_script_abort

}

ad_return_template
