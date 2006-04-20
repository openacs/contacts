ad_page_contract {

    @author Matthew Geddert (openacs@geddert.com)
    @creation-date 2006-03-12
    @cvs-id $Id$

} {
    {party_id:integer,multiple ""}
    {party_ids ""}
    {return_url}
    {role_one ""}
    {role_two ""}
    {remove_role_one:optional}
    {switch_roles_p 0}
}

set title [_ contacts.Add_Relationship]
set context [list $title]
set names [list]
set contact_type [list]
if { ![exists_and_not_null party_ids] } {
    set party_ids $party_id
}
set organizations [list]
set organization_ids [list]
set people [list]
set person_ids [list]
foreach party $party_ids {
    contact::require_visiblity -party_id $party
    if { [contact::type -party_id $party] eq "organization" } {
	lappend organizations [contact::link -party_id $party]
	lappend organization_ids $party
    } else {
	lappend people [contact::link -party_id $party]
	lappend person_ids $party
    }
}

if { [llength $organization_ids] > 0 && [llength $person_ids] > 0 } {
    ad_complain "babab"
} elseif { [llength $person_ids] > 0 } {
    set contact_type "person"
} elseif { [llength $organization_ids] > 0 } {
    set contact_type "organization"
}
set organizations [join $organizations ", "]
set people [join $people ", "]


set object_types [list "party" $contact_type]
set rel_two_options [db_list_of_lists get_rels {}]
set rel_two_options [ams::util::localize_and_sort_list_of_lists -list $rel_two_options]
set rel_two_options [concat [list [list "" ""]] [lang::util::localize $rel_two_options]]

if { $role_two ne "" && $role_one ne "" } {
    # we verify that the role still exists
    # if not we set role_one to zero
    # this also gets values needed by the validation block
    if { ![db_0or1row get_rel_info {}] } {
	set role_one ""
    }
}
if { $role_two ne "" } {
    set role_one_options [lang::util::localize [ams::util::localize_and_sort_list_of_lists -list [db_list_of_lists get_rel_types {}]]]
    if { [llength $role_one_options] == "0" } {
	ad_return_error "[_ contacts.Error]" "[_ contacts.lt_There_was_a_problem_w]"
    } elseif { [llength $role_one_options] == "1" } {
	set role_one [lindex [lindex $role_one_options 0] 1]
	set role_one_pretty [lindex [lindex $role_one_options 0] 0]
    } else {
	set role_one_options [concat [list [list "" ""]] $role_one_options]
	set role_one ""
    }
}


ad_form -name "add_edit" -method "GET" -export {party_ids return_url switch_roles_p} -form {
    {remove_role_one:boolean(checkbox),optional
	{label ""}
	{options {{"[_ contacts.lt_Remove_others_of_this_role_from_these_contacts]" 1}}}
    }
    {people:text(inform) {label "[_ contacts.lt_Add_relationship_to_these_people]"}}
    {organizations:text(inform) {label "[_ contacts.lt_Add_relationship_to_these_orgs]"}}
}

if { $role_two ne "" && $role_one eq "" } {
    ad_form -extend -name "add_edit" -form {
	{role_one:text(select)
	    {label "[_ contacts.Role_for_these_contacts]"}
	    {options $role_one_options}
	}
    }
} elseif { $role_two ne "" && $role_one ne "" } {
    ad_form -extend -name "add_edit" -form {
	{role_one:text(hidden)
	    {label ""}
	    {value "$role_one"}
	}
	{role_one_pretty:text(inform)
	    {label "[_ contacts.Role_for_these_contacts]"}
	}
    }
    # value has to be set this way to override on refreshes
    template::element::set_value add_edit role_one $role_one
    template::element::set_value add_edit role_one_pretty $role_one_pretty
    ## [lang::util::localize [db_string get_role_one_pretty {}]]
} else {
    ad_form -extend -name "add_edit" -form {
	{role_one:text(hidden),optional}
	{role_one_pretty:text(inform)
	    {label "[_ contacts.Role_for_these_contacts]"}
	    {value "[_ contacts.dependent_on_role_of_related_contact]"}
	}
    }
}

ad_form -extend -name "add_edit" -form {
    {role_two:text(select)
	{label "[_ contacts.Role_of_related_contact]"}
	{options $rel_two_options}
	{section "[_ contacts.Related_contact]"}
    }
    {object_id_two:contact_search(contact_search) {label "[_ contacts.Related_contact]"}}
    {remove_role_two:boolean(checkbox),optional
	{label ""}
	{options {{"[_ contacts.lt_Remove_others_of_this_role_from_this_related_contact]" 1}}}
    }
    {add:text(submit) {label "[_ contacts.Add_Relationship]"}}
} -on_request {
} -edit_request {
} -on_refresh {
} -validate {
} -on_submit {

    db_transaction {
	if { ![db_0or1row get_rel_info {}] } {
	    break
	}
	set object_type_two [contact::type -party_id $object_id_two]
	if { $object_type_two eq "organization" && [lsearch [list person party] $secondary_object_type] >= 0 } {
	    template::element::set_error add_edit object_id_two [_ contacts.The_selected_relationship_requires_related_person]
	}
	if { $object_type_two ne "organization" && [lsearch [list organization party] $secondary_object_type] >= 0 } { 
	    template::element::set_error add_edit object_id_two [_ contacts.The_selected_relationship_requires_related_org]
	}
	if { ![template::form::is_valid add_edit] } {
	    break
	}
	if { $remove_role_two eq "1" } {
	    set party_id $object_id_two
	    db_list delete_all_rels {}
	}
	set context_id {}
	set creation_user [ad_conn user_id]
	set creation_ip [ad_conn peeraddr]
	foreach object_id_one $party_ids {
	    if { $remove_role_one eq "1" } {
		set party_id $object_id_one
		db_list delete_all_rels {}
	    }
	    set existing_rel_id [db_string rel_exists_p {} -default {}]
	    if { [empty_string_p $existing_rel_id] } {
		set rel_id {}
		if {$switch_roles_p} {
		    set rel_id [db_exec_plsql create_backward_rel {}]
		} else {
		    set rel_id [db_exec_plsql create_forward_rel {}]
		}
		db_dml insert_contact_rel {}
	    }
	    contact::flush -party_id $object_id_one
	}
	contact::flush -party_id $object_id_two
    }

} -after_submit {
    ad_returnredirect $return_url
}


if { [template::element::get_value add_edit organizations] eq "" } {
    template::element::set_properties add_edit organizations widget hidden
}
if { [template::element::get_value add_edit people] eq "" } {
    template::element::set_properties add_edit people widget hidden
}

ad_return_template
