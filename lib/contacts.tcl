set required_param_list [list]
set optional_param_list [list]
set default_param_list  [list orderby format query page page_size package_id search_id group_id ]
set optional_unset_list [list]

# default values for default params
set _orderby "first_names,asc"
set _format "normal"
set _page_size "25"
set _tasks_interval "7"

foreach required_param $required_param_list {
    set $required_param [ns_queryget $default_param]
    if { ![exists_and_not_null required_param] } {
	return -code error "$required_param is a required parameter."
    }
}

foreach optional_param $optional_param_list {
    set "${optional_param}_temp" [ns_queryget $optional_param]
    if { [exists_and_not_null ${optional_param}_temp] } {
	set $optional_param "${optional_param}_temp"
    }
}

foreach default_param $default_param_list {
    set $default_param [ns_queryget $default_param]
    if { ![exists_and_not_null ${default_param}] && [exists_and_not_null "_${default_param}"] } {
	set $default_param [set _${default_param}]
    }
}

set group_by_group_id ""
if { ![exists_and_not_null group_id] } {
    set where_group_id " = -2"
} else {
    if {[llength $group_id] > 1} {
	set where_group_id " IN ('[join $group_id "','"]')"
	set group_by_group_id "group by parties.party_id , cr_revisions.revision_id, parties.email"
    } else {
	set where_group_id " = :group_id"
    }
}


set package_id [apm_package_id_from_key contacts]
set base_url "[site_node::get_url_from_object_id -object_id $package_id]"


if { $orderby == "first_names,asc" } {
    set name_order 0
    set name_label "[_ contacts.Sort_by]: [_ contacts.First_Names] | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {last_name,asc}}}]\">[_ contacts.Last_Name]</a>"
} else {
    set name_order 1
    set name_label "[_ contacts.Sort_by] <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {first_names,asc}}}]\">[_ contacts.First_Names]</a> | [_ contacts.Last_Name]"
}

append name_label " &nbsp;&nbsp; [_ contacts.Show]: "


set valid_page_sizes [list 25 50 100 500]
if { ![exists_and_not_null page_size] || [lsearch $valid_page_sizes $page_size] < 0 } {
    set page_size [parameter::get -parameter "DefaultPageSize" -default "50"]
}
foreach page_s $valid_page_sizes {
    if { $page_size == $page_s } {
        lappend page_size_list $page_s
    } else {
        lappend page_size_list "<a href=\"[export_vars -base $base_url -url {format search_id query page orderby {page_size $page_s}}]\">$page_s</a>"
    }
}
append name_label [join $page_size_list " | "]


append name_label "&nbsp;&nbsp;&nbsp;[_ contacts.Get]: <a href=\"[export_vars -base $base_url -url {{format csv} search_id query page orderby page_size}]\">[_ contacts.CSV]</a>"


set bulk_actions [list \
		  "[_ contacts.Add_to_Group]" "${base_url}group-parties-add" "[_ contacts.Add_to_group]" \
		  "[_ contacts.Remove_From_Group]" "${base_url}group-parties-remove" "[_ contacts.lt_Remove_from_this_Grou]" \
		  "[_ contacts.Mail_Merge]" "${base_url}message" "[_ contacts.lt_E-mail_or_Mail_the_se]" \
		  ]

if { [permission::permission_p -object_id $package_id -privilege "admin"] } {
    lappend bulk_actions "[_ contacts.Bulk_Update]" "${base_url}bulk-update" "[_ contacts.lt_Bulk_update_the_seclected_C]"
}

# Delete file is not there, taking out the code to display the delete button
# if { [permission::permission_p -object_id $package_id -privilege "delete"] } {
#    lappend bulk_actions "[_ contacts.Delete]" "${base_url}delete" "[_ contacts.lt_Delete_the_selected_C]"
# }
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
    -actions "" \
    -bulk_actions $bulk_actions \
    -bulk_action_method post \
    -bulk_action_export_vars { search_id } \
    -elements {
        contact {
	    label "<span style=\"float: right; font-weight: normal; font-size: smaller\">$name_label</a>"
            display_template {
		<a href="<%=[contact::url -party_id ""]%>@contacts.party_id@">@contacts.name@</a> <span style="padding-left: 1em; font-size: 80%;">\[<a href="${base_url}contact-edit?party_id=@contacts.party_id@">[_ contacts.Edit]</a>\]</span>
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
	search_id {}
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

db_multirow -unclobber contacts contacts_select {} 

if { [exists_and_not_null query] && [template::multirow size contacts] == 1 } {
#    ad_returnredirect -message "in '$query_name' only this contact matched your query of '$query'" [contact::url -party_id [template::multirow get contacts 1 party_id]]

    ad_returnredirect [contact::url -party_id [template::multirow get contacts 1 party_id]]
    ad_script_abort
}


list::write_output -name contacts
