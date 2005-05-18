# /packages/mbryzek-subsite/www/admin/rel-types/role-new.tcl

ad_page_contract {

    Form to create a new role

    @author mbryzek@arsdigita.com
    @creation-date Mon Dec 11 10:52:35 2000
    @cvs-id $Id$

} {
    { role:trim "" }
    { pretty_name "" }
    { pretty_plural "" }
    { return_url "roles" }
} -properties {
    context:onevalue
    
}

set context [list [list "relationships" "Relationship types"] [list "roles" "Roles"] "Create role"]

template::form create role_form

template::element create role_form return_url \
	-optional \
	-value $return_url \
	-datatype text \
	-widget hidden

template::element create role_form pretty_name \
	-label "Role Singular" \
	-datatype text \
	-html {maxlength 100}

template::element create role_form pretty_plural \
	-label "Role Plural" \
	-datatype text \
	-html {maxlength 100}

if { [template::form is_valid role_form] } {
    set role [util_text_to_url -text $pretty_name -replacement "_" -existing_urls [db_list get_roles { select role from acs_rel_roles }]]
    if { [db_string role_exists_with_same_names_p {
	select count(r.role) from acs_rel_roles r where r.pretty_name = :pretty_name or r.pretty_plural = :pretty_plural
    }] } {
	ad_return_complaint 1 "<li> The role you entered \"$pretty_name\" or the plural \"$pretty_plural\" already exists."
	return
    }

    db_transaction {
	db_exec_plsql create_role {
	    select acs_rel_type__create_role(:role, :pretty_name, :pretty_plural)
	}
    }
    ad_returnredirect $return_url
    ad_script_abort
}
