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
    {add_person:optional}
    {add_organization:optional}
    {clear_query:optional}
}

if { [exists_and_not_null add_person] } {
    ad_returnredirect "add/person"
    ad_script_abort
} elseif { [exists_and_not_null add_organization] } {
    ad_returnredirect "add/organization"
    ad_script_abort
}
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

if { [parameter::get -boolean -parameter "ForceSearchBeforeAdd" -default "0"] } {
    if { [exists_and_not_null query] && $group_id == "-2" } {
	append form_elements {
	    {add_person:text(submit) {label {[_ contacts.Add_Person]}} {value "1"}}
	    {add_organization:text(submit) {label {[_ contacts.Add_Organization]}} {value "1"}}
	}
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
