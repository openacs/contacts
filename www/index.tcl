ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {rel_type:optional}
    {orderby "first_names,asc"}
    {format "normal"}
    {query_id:integer ""}
    {query ""}
    {page:optional}
    {page_size:integer "25"}
    {tasks_interval:integer "7"}
}


set title "[_ contacts.Contacts]"
set context {}

if { [exists_and_not_null query_id] } {
    if { [contact::search::exists_p -search_id $query_id] } {
        set search_id $query_id
        set query_type "search"
    } else {
        set group_id $query_id
        set query_type "group"
    }
} else {
#    set group_id [application_group::group_id_from_package_id -package_id [ad_conn subsite_id]]
    set group_id [contacts::default_group]
    set query_id $group_id
    set query_type "group"
    if { ![exists_and_not_null group_id] } {
        ad_return_error "[_ contacts.Not_Configured]" "[_ contacts.lt_Your_administrator_mu]"
    }
}


if { $orderby == "first_names,asc" } {
    set name_order 0
    set name_label "[_ contacts.Sort_by] [_ contacts.First_Names] | <a href=\"[export_vars -base . -url {rel_type format query_id query page page_size {orderby {last_name,asc}}}]\">[_ contacts.Last_Name]</a>"
} else {
    set name_order 1
    set name_label "[_ contacts.Sort_by] <a href=\"[export_vars -base . -url {rel_type format query_id query page page_size {orderby {first_names,asc}}}]\">[_ contacts.First_Names]</a> | [_ contacts.Last_Name]"
}
append name_label " &nbsp;&nbsp; [_ contacts.Show]"
set first_p 1
foreach page_s [list 25 50 100 500] {
    if { [string is false $first_p] } {
        append name_label " | "
    }
    if { $page_size == $page_s } {
        append name_label $page_s
    } else {
        append name_label "<a href=\"[export_vars -base . -url {rel_type format query_id query page orderby {page_size $page_s}}]\">$page_s</a>"
    }
    set first_p 0
}
append name_label "&nbsp;&nbsp;&nbsp;Get: <a href=\"[export_vars -base . -url {rel_type {format csv} query_id query page orderby page_size}]\">CSV</a>"

set tasks_url [export_vars -base "/tasks/query" -url {query_id query rel_type}]


# SEARCH CLAUSE

set search_clause [list]

if { $query_type == "group" } {
    if { $group_id != "-2" } {
        lappend search_clause "and party_id in ( select member_id from group_distinct_member_map where group_id = '$group_id' )"
    }
    if { [exists_and_not_null rel_type] } {
        set rel_valid_p 0
        db_foreach get_rels {} {
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
} elseif { $query_type == "search" } {
    lappend search_clause [contact::search::where_clause -and -search_id $search_id -party_id "parties.party_id" -revision_id "revision_id"]
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


# LIST CODE

#set actions [list \
#		  "Add Person" "contact-add?object_type=person" "Add a Person" \
#		  "Add Organization" "contact-add?object_type=organization" "Add an Organization" \
#		  "Advanced Search" "search" "Advanced Search" \
#		  "Settings" "settings" "Modify Settings" \
#		  "Admin" "admin" "Administration"]
set actions ""
set bulk_actions [list \
		  "[_ contacts.Add_to_Group]" "group-parties-add" "[_ contacts.Add_to_group]" \
		  "[_ contacts.Remove_From_Group]" "group-parties-remove" "[_ contacts.lt_Remove_from_this_Grou]" \
		  "[_ contacts.Delete]" "delete" "[_ contacts.lt_Delete_the_selected_C]" \
		  "[_ contacts.Mail_Merge]" "message" "[_ contacts.lt_E-mail_or_Mail_the_se]" \
		  ]

template::list::create \
    -html {width 100%} \
    -name "contacts" \
    -multirow "contacts" \
    -row_pretty_plural "[_ contacts.contacts]" \
    -checkbox_name checkbox \
    -selected_format ${format} \
    -key party_id \
    -page_size $page_size \
    -page_flush_p t \
    -page_query_name contacts_pagination \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -bulk_action_method post \
    -bulk_action_export_vars { group_id } \
    -elements {
        rownum {
	    label {}
	    display_col rownum
	}
        type {
	    label {}
	    display_template {
		<img src="/resources/contacts/Group16.gif" height="16" width="16" border="0"></img>
	    }
	}
        contact {
	    label "<span style=\"float: right; font-weight: normal; font-size: smaller\">$name_label</a>"
            display_template {
		<a href="<%=[contact::url -party_id ""]%>@contacts.party_id@">@contacts.name@</a> <span style="padding-left: 1em; font-size: 80%;">\[<a href="contact-edit?party_id=@contacts.party_id@">[_ contacts.Edit]</a>\]</span>
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
	rel_type {}
	query_id {}
	page_size {}
	tasks_interval {}
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
 		checkbox {}
		contact {}
	    }
	}
	tasks {
	    label "[_ contacts.Table]"
	    layout table
	    row {
 		checkbox {}
		contact {}
	    }
	}
	csv {
	    label "[_ contacts.CSV]"
	    output csv
            page_size 0
            row {
		contact_id {}
                first_names {}
                last_name {}
                organization {}
                email {}
	    }
	}
    }

# At least with openacs 5.1.5 list paginator does not use limit and offset commands.
# this will likely be fixed in a future version, but until that is done we do not
# need the overhead of the search clause in the multirow since the pagination proc
# returns a list of valid party_ids the meet the search clause parameters. This
# should increase the speed with which this query can be run
db_multirow -unclobber contacts contacts_select {}

set contacts_total_count [contact::search::results_count -search_id $query_id -query $query]

if { [exists_and_not_null query] && [template::multirow size contacts] == 1 } {
    if { $query_type == "group" } {
        set query_name [db_string get_it { select group_name from groups where group_id = :group_id }]
    } else {
        set query_name [db_string get_it { select title from contact_searches where search_id = :search_id }]
    }

    ad_returnredirect -message "in '$query_name' only this contact matched your query of '$query'" [contact::url -party_id [template::multirow get contacts 1 party_id]]
    ad_script_abort
}




if { $query_type == "group" } {

    # roles
    set rel_options [list]
    lappend rel_options [list "[_ contacts.All]" "" ""]
    db_foreach get_rels {} {
        if { $relation_type == "membership_rel" } { 
            set pretty_plural "[_ contacts.People]"
        }
        lappend rel_options [list \
                                 [lang::util::localize $pretty_plural] \
                                 ${relation_type} \
                                 ${member_count}]
    }

}


set owner_id [ad_conn user_id]
set group_options [list [list "[_ contacts.lt_--_Groups_-----------]" ""]]
append group_options  " [contact::groups -expand "all"]"
lappend group_options   [list "" ""]
lappend group_options   [list "[_ contacts.lt_--_My_Searches_------]" ""]
append group_options  " [db_list_of_lists get_my_searches {}]"




append form_elements {
    {query_id:integer(select),optional {label ""} {options $group_options} {html {onChange "javascript:acs_FormRefresh('search')"}}}
}


if { [exists_and_not_null rel_options] && $query_type == "group" } {
    append form_elements {
        {rel_type:text(select),optional {label ""} {options $rel_options} {html {onChange "javascript:acs_FormRefresh('search')"}}}
    }
}

append form_elements {
    {query:text(text),optional {label ""} {html {size 20 maxlength 255}}}
    {save:text(submit) {label {[_ contacts.Go]}} {value "go"}}
}
#     {format:text(select),optional {label "&nbsp;&nbsp;&nbsp;[_ contacts.Output]"} {options {{Default normal} {CSV csv}}} {html {onChange "javascript:acs_FormRefresh('search')"}}}

switch $format {
    normal {
	append form_elements {
	    {tasks_interval:integer(hidden),optional}
	}
	if { $contacts_total_count > 0 } {
	    append form_elements {
		{results_count:integer(inform),optional {label "&nbsp;&nbsp;<span style=\"font-size: smaller;\">[_ contacts.Results]</span> $contacts_total_count"}}
	    }
	}

    }
    tasks {
	append form_elements {
	    {tasks_interval:integer(text),optional {label "&nbsp;&nbsp;<span style=\"font-size: smaller;\">[_ contacts.View_next]</span>"} {after_html "<span style=\"font-size: smaller;\">[_ contacts.days]</span>"} {html {size 2 maxlength 3 onChange "javascript:acs_FormRefresh('search')"}}}
	}
    }
    csv {
	# This spits out the CSV if we happen to be in CSV layout
	list::write_output -name contacts
	ad_script_abort
    }
    default {
    }
}


ad_form -name "search" -method "GET" -export {orderby page_size page format} -form $form_elements \
    -on_request {
    } -edit_request {
    } -on_refresh {
    } -on_submit {
    } -after_submit {
    }

# Make the Navigation bar context sensitive

set person_add_url [export_vars -base "contact-add" -url {{object_type "person"} group_id}]
set organization_add_url [export_vars -base "contact-add" -url {{object_type "organization"} group_id}]