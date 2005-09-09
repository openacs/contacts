set required_param_list [list]
set optional_param_list [list base_url extend_p extend_values]
set default_param_list  [list orderby format query page page_size package_id search_id group_id ]
set optional_unset_list [list]

# default values for default params
set _orderby "first_names,asc"
set _format "normal"
set _page_size "25"
set _tasks_interval "7"
set admin_p 0

foreach required_param $required_param_list {
    set $required_param [ns_queryget $default_param]
    if { ![exists_and_not_null required_param] } {
	return -code error "$required_param is a required parameter."
    }
}

foreach optional_param $optional_param_list {
    if { ![exists_and_not_null ${optional_param}] } {
	set $optional_param ""
    }
}

foreach default_param $default_param_list {
    set $default_param [ns_queryget $default_param]
    if { ![exists_and_not_null ${default_param}] && [exists_and_not_null "_${default_param}"] } {
	set $default_param [set _${default_param}]
    }
}

# If we do not have a search_id, limit the list to only users in the default group.

if {[exists_and_not_null search_id]} {
    set group_where_clause "" 
    # Also we can extend this search.
    # Is to allow extend the list by any extend_options defined in contact_extend_options
    set available_options [contact::extend::get_options -ignore_extends $extend_values -search_id $search_id]
    ad_form -name extend -form {
	{extend_option:text(select),optional
	    {label "[_ contacts.Available_Options]" }
	    {options {{" - - - - - - -" ""} $available_options}}
	}
	{search_id:text(hidden)
	    {value "$search_id"}
	}
	{extend_values:text(hidden)
	    {value "$extend_values"}
	}
    } -on_submit {
	# We clear the list when no value is submited, otherwise
	# we acumulate the extend values.
	if { [empty_string_p $extend_option] } {
	    set extend_values [list]
	} else {
	    lappend extend_values [list $extend_option] 
	}
	ad_returnredirect [export_vars -base "?" {search_id extend_values}]
    }
} else {
    set group_where_clause "and group_distinct_member_map.group_id = [contacts::default_group]"
}

set group_by_group_id ""
if { ![exists_and_not_null group_id] } {
    set where_group_id " = [contacts::default_group]"
} else {
    if {[llength $group_id] > 1} {
	set where_group_id " IN ('[join $group_id "','"]')"
	set group_by_group_id "group by parties.party_id , parties.email"
    } else {
	set where_group_id " = :group_id"
    }
}


set package_id [apm_package_id_from_key contacts]


switch $orderby {
    "first_names,asc" {
        set name_label "[_ contacts.Sort_by]: [_ contacts.First_Names] | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {last_name,asc}}}]\">[_ contacts.Last_Name]</a> | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {organization,asc}}}]\">[_ contacts.Organization]</a>"
    }
    "last_name,asc" {
        set name_label "[_ contacts.Sort_by] <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {first_names,asc}}}]\">[_ contacts.First_Names]</a> | [_ contacts.Last_Name] | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {organization,asc}}}]\">[_ contacts.Organization]</a>"
    }
    "organization,asc" {
        set name_label "[_ contacts.Sort_by] <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {first_names,asc}}}]\">[_ contacts.First_Names]</a>  | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {last_name,asc}}}]\">[_ contacts.Last_Name]</a> | [_ contacts.Organization]"
    }
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

template::multirow create bulk_acts pretty link detailed
template::multirow append bulk_acts "[_ contacts.Add_to_Group]" "${base_url}group-parties-add" "[_ contacts.Add_to_group]"
template::multirow append bulk_acts "[_ contacts.Remove_From_Group]" "${base_url}group-parties-remove" "[_ contacts.lt_Remove_from_this_Grou]"
template::multirow append bulk_acts "[_ contacts.Mail_Merge]" "${base_url}message" "[_ contacts.lt_E-mail_or_Mail_the_se]"
if { [permission::permission_p -object_id $package_id -privilege "admin"] } {
    set admin_p 1
    template::multirow append bulk_acts "[_ contacts.Bulk_Update]" "${base_url}bulk-update" "[_ contacts.lt_Bulk_update_the_seclected_C]"
}
callback contacts::bulk_actions -multirow "bulk_acts"

set bulk_actions [list]
template::multirow foreach bulk_acts {
    lappend bulk_actions $pretty $link $detailed
}

set return_url "[ad_conn url]?[ad_conn query]"

# Delete file is not there, taking out the code to display the delete button
# if { [permission::permission_p -object_id $package_id -privilege "delete"] } {
#    lappend bulk_actions "[_ contacts.Delete]" "${base_url}delete" "[_ contacts.lt_Delete_the_selected_C]"
# }

set elements [list \
		  contact [list \
			       label \
			       {<span style=\"float: right; font-weight: normal; font-size: smaller\">$name_label</a>} \
			       display_template \
			       { 
				   <a href="@contacts.contact_url@">@contacts.name@</a> 
				   <span class="contact-editlink">
				   \[<a href="${base_url}contact-edit?party_id=@contacts.party_id@">[_ contacts.Edit]</a>\]
				   </span>
				   <if @contacts.email@ not nil or @contacts.url@ not nil>
				       <span class="contact-attributes">
				       <if @contacts.email@ not nil>
                                           <a href="@contacts.contact_url@message">@contacts.email@</a>
		                       </if>
		                       <if @contacts.url@ not nil>
                                            <if @contacts.email@ not nil>
                                                 ,
                                            </if>
                                            <a href="@contacts.url@">@contacts.url@</a>
 		                       </if>
				       </span>
                        	   </if>
			       }] \
		  contact_id [list display_col party_id] \
		  first_names [list display_col first_names] \
		  last_name [list display_col last_name] \
		  organization [list display_col organization] \
		  email [list display_col email]]

set row_list [list \
		  checkbox {} \
		  contact {}]

if { [exists_and_not_null search_id] } {
    # We get all the default values for that are mapped to this search_id
    set default_values [db_list_of_lists get_default_extends { }]
    set extend_values [concat $default_values $extend_values]
}

# For each extend value we add the element to the list and to the query
set extend_query ""
foreach value $extend_values {
    set extend_info [lindex [contact::extend::option_info -extend_id $value] 0]
    set name        [lindex $extend_info 0]
    set pretty_name [lindex $extend_info 1]
    set sub_query   [lindex $extend_info 2]
    lappend elements $name [list label "$pretty_name" display_col $name]
    lappend row_list $name [list]
    append extend_query "( $sub_query ) as $name,"
}
set actions [list]
if { $admin_p && [exists_and_not_null search_id] } {
    set actions [list "[_ contacts.Set_default_extend]" "admin/ext-search-options?search_id=$search_id" "[_ contacts.Set_default_extend]" ]
}
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
    -bulk_action_export_vars { search_id return_url } \
    -elements $elements \
    -filters {
	search_id {}
	page_size {}
	tasks_interval {}
        query {}
    } -orderby {
        first_names {
            label "[_ contacts.First_Name]"
            orderby_asc  "lower(first_names) asc"
            orderby_desc "lower(first_names) asc"
        }
        last_name {
            label "[_ contacts.Last_Name]"
            orderby_asc  "lower(last_name) asc"
            orderby_desc "lower(last_name) asc"
        }
        organization {
            label "[_ contacts.Last_Name]"
            orderby_asc  "lower(organizations.name) asc"
            orderby_desc "lower(organizations.name) asc"
        }

        default_value first_names,asc
    } -formats {
	normal {
	    label "[_ contacts.Table]"
	    layout table
	    row {
		$row_list
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

db_multirow -extend {contact_url name} -unclobber contacts contacts_select " " {
    set contact_url [contact::url -party_id $party_id]
    set name [contact::name -party_id $party_id]
}

if { [exists_and_not_null query] && [template::multirow size contacts] == 1 } {
    # Redirecting the user directly to the one resulted contact
    ad_returnredirect [contact::url -party_id [template::multirow get contacts 1 party_id]]
    ad_script_abort
}


list::write_output -name contacts

