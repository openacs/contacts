ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {party_id:integer,notnull}
    {party_two:optional}
    {role_two ""}
    {buttonsearch:optional}
    {buttonme:optional}
    {query ""}
} -validate {
    contact_one_exists -requires {party_id} {
	if { ![contact::exists_p -party_id $party_id] } {
	    ad_complain "The first contact specified does not exist"
	}
    }
    contact_two_exists -requires {party_two} {
	if { ![contact::exists_p -party_id $party_two] } {
	    ad_complain "The second contact specified does not exist"
	}
    }

}

set contact_type [contact::type -party_id $party_id]
set contact_name [contact::name -party_id $party_id]
set contact_url  [contact::url  -party_id $party_id]






set pretty_plural_list_name "contacts"
# create rel_type if the role requires a certain object_type
if { [exists_and_not_null role_two] } {
    set valid_object_types [db_list valid_object_types { select primary_object_type from contact_rel_types where primary_role = :role_two }]
    set person_valid_p 0
    set org_valid_p 0
    foreach type $valid_object_types {
        switch $type {
            party {
                set person_valid_p 1
                set org_valid_p 1
            }
            person {
                set person_valid_p 1
            }
            organization {
                set org_valid_p 1
            }
        }
    }
    if { $org_valid_p && $person_valid_p } {
        # we do nothing
    } else {
        if { $org_valid_p } {
            set rel_type "organization_rel"
            set pretty_plural_list_name "organizations"
        } elseif { $person_valid_p } {
            set rel_type "membership_rel"
            set pretty_plural_list_name "people"
        } else {
            error "neither person nor org type is valid, what happened admin?"
        }
    }
}











if { [exists_and_not_null orderby] } {
    if { $orderby == "first_names,asc" } {
	set name_order 0
    } else {
	set name_order 1
    }
} else {
    set name_order 0
}

set member_state "approved"
set format "normal"

set admin_p [ad_permission_p [ad_conn package_id] admin]
#set default_group_id [contacts::default_group_id]
set title "Contacts"
set context {}



set search_clause [list]
lappend search_clause "and party_id in ( select member_id from group_distinct_member_map where group_id = '-2' )"
if { [exists_and_not_null rel_type] } {
    set rel_valid_p 0
    set group_id "-2"
    db_foreach dbqd.contacts.www.index.get_rels {} {
	if { $rel_type == $relation_type } {
	    set rel_valid_p 1
	}
    }
    if { $rel_valid_p } {
	lappend search_clause "and party_id in ( select member_id from group_member_map where rel_type = '$rel_type' )"
    } else {
	set rel_type ""
    }
}

if { [exists_and_not_null query] } {
    set search [string trim $query]
    foreach term $query {
	if { [string is integer $query] } {
	    lappend search_clause "and party_id = $term"
	} else {
	    lappend search_clause "and upper(contact__name(party_id)) like upper('%${term}%')"
	}
    }
}

set search_clause [join $search_clause "\n"]
#ad_return_error "Error" $search_clause


set primary_party $party_id

template::list::create \
    -html {width 100%} \
    -name "contacts" \
    -multirow "contacts" \
    -row_pretty_plural "$pretty_plural_list_name found in search, please try again or add a new contact" \
    -checkbox_name checkbox \
    -selected_format ${format} \
    -key party_id \
    -elements {
        type {
	    label {}
	    display_template {
		<img src="/resources/contacts/Group16.gif" height="16" width="16" border="0"></img>
	    }
	}
        contact {
	    label {}
            display_template {
		<a href="<%=[contact::url -party_id ""]%>@contacts.party_id@">@contacts.name@</a> <span style="padding-left: 1em; font-size: 80%;">\[<a href="@contacts.map_url@">Select</a>\]</span>
                <span style="clear:both; display: block; margin-left: 10px; font-size: 80%;">@contacts.email@</sapn>
	    }
        }
        contact_id {
            display_col party_id
	}
        first_names {
	    display_col first_names
	}
        last_name {
	    display_col last_name
	}
        organization {
	    display_col organization
	}
        email {
	    display_col email
	}
    } -filters {
    } -orderby {
        first_names {
            label "First Name"
            orderby_asc  "lower(contact__name(party_id,'f')) asc"
            orderby_desc "lower(contact__name(party_id,'f')) asc"
        }
        last_name {
            label "Last Name"
            orderby_asc  "lower(contact__name(party_id,'t')) asc"
            orderby_desc "lower(contact__name(party_id,'t')) asc"
        }
        default_value first_names,asc
    } -formats {
	normal {
	    label "Table"
	    layout table
	    row {
		contact {}
	    }
	}
    }

#ns_log notice [db_map contacts_select]
set original_party_id $party_id

#ad_return_error "ERROR" [db_map dbqd.contacts.www.index.contacts_select]
db_multirow -extend {map_url} -unclobber contacts dbqd.contacts.www.index.contacts_select {} {
    set map_url [export_vars -base "relationship-add" -url {{party_one $original_party_id} {party_two $party_id} {role_two $role_two}}]
}





set rel_options [db_list_of_lists get_rels {
    select acs_rel_type__role_pretty_name(primary_role),
           primary_role
      from contact_rel_types
     where secondary_object_type in ( :contact_type, 'party' )
     order by upper(acs_rel_type__role_pretty_name(primary_role))
}]

set rel_options "{{-Select One-} {}} $rel_options"






ad_form -name "search" -method "GET" -export {party_id} -form {
    {role_two:text(select) {label "Add: "} {options $rel_options}}
    {query:text(text) {label ""} {html {size 24}}}
    {search:text(submit) {label "Search"}}
} -on_request {
} -edit_request {
} -on_refresh {
} -on_submit {
} -after_submit {
}
