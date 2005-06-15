ad_page_contract {
    List and manage contacts
} {
    {orderby "first_names,asc"}
    {format "normal"}
    {search_id:integer ""}
    {query ""}
    {page:optional}
    {page_size:integer ""}
}


if { $orderby == "first_names,asc" } {
    set name_order 0
    set name_label "[_ contacts.Sort_by]: [_ contacts.First_Names] | <a href=\"[export_vars -base . -url {format search_id query page page_size {orderby {last_name,asc}}}]\">[_ contacts.Last_Name]</a>"
} else {
    set name_order 1
    set name_label "[_ contacts.Sort_by] <a href=\"[export_vars -base . -url {format search_id query page page_size {orderby {first_names,asc}}}]\">[_ contacts.First_Names]</a> | [_ contacts.Last_Name]"
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
        lappend page_size_list "<a href=\"[export_vars -base . -url {format search_id query page orderby {page_size $page_s}}]\">$page_s</a>"
    }
}
append name_label [join $page_size_list " | "]


append name_label "&nbsp;&nbsp;&nbsp;[_ contacts.Get]: <a href=\"[export_vars -base . -url {{format csv} search_id query page orderby page_size}]\">[_ contacts.CSV]</a>"


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
    -actions "" \
    -bulk_actions $bulk_actions \
    -bulk_action_method post \
    -bulk_action_export_vars { search_id } \
    -elements {
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
