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
    {orderby "role,asc"}
} -validate {
    contact_one_exists -requires {party_id} {
	if { ![contact::exists_p -party_id $party_id] } {
	    ad_complain "[_ contacts.lt_The_first_contact_spe]"
	}
    }
    contact_two_exists -requires {party_two} {
	if { ![contact::exists_p -party_id $party_two] } {
	    ad_complain "[_ contacts.lt_The_second_contact_sp]"
	}
    }

}

set contact_type [contact::type -party_id $party_id]
set contact_name [contact::name -party_id $party_id]
set contact_url  [contact::url  -party_id $party_id]






set pretty_plural_list_name "contacts"
if { [exists_and_not_null role_two] } {
    set valid_object_types [db_list get_valid_object_types {}]
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
            set pretty_plural_list_name "[_ contacts.organizations]"
        } elseif { $person_valid_p } {
            set rel_type "membership_rel"
            set pretty_plural_list_name "[_ contacts.people]"
        } else {
            error "[_ contacts.lt_neither_person_nor_or]"
        }
    }
}












set name_order 0
set member_state "approved"
set format "normal"

set admin_p [ad_permission_p [ad_conn package_id] admin]
#set default_group_id [contacts::default_group_id]
set title "Contacts"
set context {}
set package_url [ad_conn package_url]

if { [exists_and_not_null query] } {

    set primary_party $party_id
    
    template::list::create \
	-html {width 100%} \
	-name "contacts" \
	-multirow "contacts" \
	-row_pretty_plural "$pretty_plural_list_name found in search, please try again or add a new contact" \
	-checkbox_name checkbox \
	-selected_format ${format} \
	-orderby_name "order_search" \
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
		label "[_ contacts.First_Name]"
		orderby_asc  "lower(contact__name(party_id,'f')) asc"
		orderby_desc "lower(contact__name(party_id,'f')) asc"
	    }
	    last_name {
		label "[_ contacts.Last_Name]"
		orderby_asc  "lower(contact__name(party_id,'t')) asc"
		orderby_desc "lower(contact__name(party_id,'t')) asc"
	    }
	    default_value first_names,asc
	} -formats {
	    normal {
		label "[_ contacts.Table]"
		layout table
		row {
		    contact {}
		}
	    }
	}

    set search_id ""
    set original_party_id $party_id
    db_multirow -extend {map_url} -unclobber contacts contacts_select {} {
	set map_url [export_vars -base "${package_url}relationship-add" -url {{party_one $original_party_id} {party_two $party_id} {role_two $role_two}}]
    }
    

}

set rel_options [list [list "[_ contacts.--select_one--]" ""]]

set rel_options [db_list_of_lists get_rels {}]

set rel_options "{{-Select One-} {}} $rel_options"




db_foreach get_rels {} {
	set pretty_name [lang::util::localize $pretty_name]
	lappend rel_options [list $pretty_name $role]
    }


ad_form -name "search" -method "GET" -export {party_id} -form {
    {role_two:text(select) {label "[_ contacts.Add]"} {options $rel_options}}
    {query:text(text) {label ""} {html {size 24}}}
    {search:text(submit) {label "[_ contacts.Search]"}}
} -on_request {
} -edit_request {
} -on_refresh {
} -on_submit {
} -after_submit {
}

template::list::create \
    -html {width 100%} \
    -name "relationships" \
    -multirow "relationships" \
    -row_pretty_plural "[_ contacts.relationships]" \
    -selected_format "normal" \
    -elements {
        role {
            label "[_ contacts.Role]"
            display_col role_singular
        }
        other_name {
            label "[_ contacts.Contact]"
            display_col other_name
            link_url_eval $contact_url
        }
        details {
            label "[_ contacts.Details]"
            display_col details;noquote
        }
        actions {
            label "[_ contacts.Actions]"
            display_template {
                <a href="@relationships.rel_delete_url@" class="button">[_ contacts.Delete]</a></if>
                <if @relationships.rel_add_edit_url@ not nil><a href="@relationships.rel_add_edit_url@" class="button">[_ contacts.Edit_Details]</a></if>
            }
        }
    } -filters {
        party_id {}
    } -orderby {
        other_name {
            label "[_ contacts.Contact]"
            orderby_asc  "CASE WHEN object_id_one = :party_id THEN upper(contact__name(object_id_two)) ELSE upper(contact__name(object_id_one)) END asc, upper(role_singular) asc"
            orderby_desc "CASE WHEN object_id_one = :party_id THEN upper(contact__name(object_id_two)) ELSE upper(contact__name(object_id_one)) END desc, upper(role_singular) asc"
        }
        role {
            label "[_ contacts.Role]"
            orderby_asc  "upper(role_singular) asc, CASE WHEN object_id_one = :party_id THEN upper(contact__name(object_id_two)) ELSE upper(contact__name(object_id_one)) END asc"
            orderby_desc "upper(role_singular) desc, CASE WHEN object_id_one = :party_id THEN upper(contact__name(object_id_two)) ELSE upper(contact__name(object_id_one)) END asc"
        }
        default_value role,asc
    } -formats {
	normal {
	    label "[_ contacts.Table]"
	    layout table
	    row {
                role {}
                other_name {}
                details {}
                actions {}
	    }
	}
    }


set package_id [ad_conn package_id]
set return_url "[ad_conn package_url]${party_id}/relationships"
db_multirow -unclobber -extend {contact_url rel_add_edit_url rel_delete_url details} relationships get_relationships "" {
    set contact_url [contact::url -party_id $other_party_id]
    set details ""
    if { [ams::list::exists_p -package_key "contacts" -object_type ${rel_type} -list_name ${package_id}] } {
        set rel_add_edit_url [export_vars -base "${package_url}relationship-ae" -url {rel_type object_id_one object_id_two party_id}]
        set details_list [ams::values -package_key "contacts" -object_type $rel_type -list_name $package_id -object_id $rel_id -format "text"]
        if { [llength $details_list] > 0 } {
            append details "<dl class=\"attribute-values\">\n"
            foreach {section attribute_name pretty_name value} $details_list {
                append details "<dt class=\"attribute-name\">${pretty_name}:</dt>\n"
                append details "<dd class=\"attribute-value\">${value}</dd>\n"
            }
            append details "</dl>\n"
        }
    }
    set rel_delete_url [export_vars -base "${package_url}relationship-delete" -url {rel_id party_id return_url}]
}
