set required_param_list [list]
set optional_param_list [list base_url extend_p extend_values attr_val_name]
set default_param_list  [list orderby format query page page_size package_id search_id group_id]
set optional_unset_list [list]

# default values for default params
set _orderby "first_names,asc"
set _format "normal"
set _page_size "25"
set _tasks_interval "7"
set admin_p 0

if { [string is false [exists_and_not_null package_id]] } {
    set package_id [ad_conn package_id]
}

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

# This is for showing the employee_id and employeer relationship
set type_list [db_list get_condition_type { }] 

if { ![string equal [lsearch -exact $type_list "employees"] "-1"] } {
    set page_query_name "employees_pagination"
} else {
    set page_query_name "contacts_pagination"
}

# If we do not have a search_id, limit the list to only users in the default group.
if {[exists_and_not_null search_id]} {
    # Also we can extend this search.
    # Is to allow extend the list by any extend_options defined in contact_extend_options
    set extend_options [contact::extend::get_options \
				    -ignore_extends $extend_values \
				    -search_id $search_id -aggregated_p "f"]
    if { [llength $extend_options] == 0 } {
	set hide_form_p 1
    }

    set available_options [concat \
			       [list [list "- - - - - - - -" ""]] \
			       $extend_options \
			       ]

    ad_form -name extend -form {
	{extend_option:text(select),optional
	    {label "[_ contacts.Available_Options]" }
	    {options {$available_options}}
	}
	{search_id:text(hidden)
	    {value "$search_id"}
	}
	{extend_values:text(hidden)
	    {value "$extend_values"}
	}
	{attr_val_name:text(hidden)
	    {value "$attr_val_name"}
	}
    } -on_submit {
	# We clear the list when no value is submited, otherwise
	# we acumulate the extend values.
	if { [empty_string_p $extend_option] } {
	    set extend_values [list]
	} else {
	    lappend extend_values [list $extend_option] 
	}
	ad_returnredirect [export_vars -base "?" {search_id extend_values attr_val_name}]
    }
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


set last_modified_join ""
set last_modified_clause ""

switch $orderby {
    "first_names,asc" {
        set name_label "[_ contacts.Sort_by]: [_ contacts.First_Names] | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size attr_val_name {orderby {last_name,asc}}}]\">[_ contacts.Last_Name]</a> | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size attr_val_name {orderby {organization,asc}}}]\">[_ contacts.Organization]</a> | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size attr_val_name {orderby {last_modified,desc}}}]\">[_ contacts.Last_Modified]</a>"
	set left_join "left join persons on (parties.party_id = persons.person_id)"
	set sort_item "lower(first_names), lower(last_name)"
    }
    "last_name,asc" {
        set name_label "[_ contacts.Sort_by] <a href=\"[export_vars -base $base_url -url {format search_id query page page_size attr_val_name {orderby {first_names,asc}}}]\">[_ contacts.First_Names]</a> | [_ contacts.Last_Name] | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {organization,asc}}}]\">[_ contacts.Organization]</a> | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {last_modified,desc}}}]\">[_ contacts.Last_Modified]</a>"
	set left_join "left join persons on (parties.party_id = persons.person_id)"
	set sort_item "lower(last_name), lower(first_names)"
    }
    "organization,asc" {
        set name_label "[_ contacts.Sort_by] <a href=\"[export_vars -base $base_url -url {format search_id query page page_size attr_val_name {orderby {first_names,asc}}}]\">[_ contacts.First_Names]</a>  | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {last_name,asc}}}]\">[_ contacts.Last_Name]</a> | [_ contacts.Organization] | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {last_modified,desc}}}]\">[_ contacts.Last_Modified]</a>"
	set left_join "left join organizations on (parties.party_id = organizations.organization_id)"
	set sort_item "lower(organizations.name)"
    }
    "last_modified,desc" {
        set name_label "[_ contacts.Sort_by] <a href=\"[export_vars -base $base_url -url {format search_id query page page_size attr_val_name {orderby {first_names,asc}}}]\">[_ contacts.First_Names]</a>  | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {last_name,asc}}}]\">[_ contacts.Last_Name]</a> | <a href=\"[export_vars -base $base_url -url {format search_id query page page_size {orderby {organization,asc}}}]\">[_ contacts.Organization]</a> | [_ contacts.Last_Modified]"
	set left_join "left join organizations on (parties.party_id = organizations.organization_id)"
	set sort_item "acs_objects.last_modified"
	set last_modified_join "acs_objects, "
	set last_modified_clause "and parties.party_id = acs_objects.object_id"
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
        lappend page_size_list "<a href=\"[export_vars -base $base_url -url {format search_id query page orderby attr_val_name {page_size $page_s}}]\">$page_s</a>"
    }
}
append name_label [join $page_size_list " | "]

if { [string is true [parameter::get -parameter "DisableCSV" -default "0"]] } {
    set format normal
} else {
    append name_label "&nbsp;&nbsp;&nbsp;[_ contacts.Get]: <a href=\"[export_vars -base $base_url -url {{format csv} search_id query page orderby attr_val_name page_size}]\">[_ contacts.CSV]</a>"
}

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
				   <a href="@contacts.contact_url@">@contacts.name;noquote@</a>@contacts.orga_info;noquote@
				   <span class="contact-editlink">
				   \[<a href="${base_url}contact-edit?party_id=@contacts.party_id@">[_ contacts.Edit]</a>\]
				   </span>
				   <if @contacts.email@ not nil or @contacts.url@ not nil>
				       <span class="contact-attributes">
				       <if @contacts.email@ not nil>
                                           <a href="@contacts.message_url@">@contacts.email@</a>
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

if { $format == "csv" } {
    set row_list [list \
		      contact_id {} \
		      first_names {} \
		      last_name {} \
		      email {} \
		      ]
    
} else {
    set row_list [list \
		  checkbox {} \
		  contact {}]
}
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
    lappend elements $name [list label "$pretty_name" display_template "@contacts.${name};noquote@"]
    lappend row_list $name [list]
    append extend_query "( $sub_query ) as $name,"
}


# We are going to extend the list also by the attributes specified in the
# parameters, if there is any. Only when attr_val_name is empty and exists a 
# search_id, otherwise we would have duplicates since when attr_val_name is 
# present then the default attributes specified on the parameter already come 
# in this list.

if { ![exists_and_not_null attr_val_name] && [exists_and_not_null search_id] } {

    set object_type [db_string get_object_type { }]
    switch $object_type {
	person { 
	    set default_attr_extend [parameter::get -parameter "DefaultPersonAttributeExtension"]
	}
	organization { 
	    set default_attr_extend [parameter::get -parameter "DefaultOrganizationAttributeExtension"]
	}
	party { 
	    set default_attr_extend [parameter::get -parameter "DefaultPersonOrganAttributeExtension"]
	}
    }
    
    # We are going to take all the blank spaces and split the list by ";"
    regsub -all " " $default_attr_extend "" default_attr_extend
    set default_attr_extend [split $default_attr_extend ";"]

    foreach attr $default_attr_extend {
	set attr_id [attribute::id -object_type "person" -attribute_name "$attr"]
        if { [empty_string_p $attr_id] } {
	    # Is not a person attribute is an organization attribute
            set attr_id [attribute::id -object_type "organization" -attribute_name "$attr"]
        }
	lappend attr_val_name [list $attr_id $attr]
    }
}


# This is for the attributes
set extend_attr [list]
foreach attribute $attr_val_name {
    set attr_id   [lindex $attribute 0]
    lappend row_list $attr_id [list]
    lappend elements $attr_id [list label [attribute::pretty_name -attribute_id $attr_id] display_template "@contacts.${attr_id};noquote@"]
    lappend extend_attr $attr_id
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
    -page_query_name $page_query_name \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -bulk_action_method post \
    -bulk_action_export_vars { search_id return_url } \
    -elements $elements \
    -filters {
        attr_val_name {}
	search_id {}
	page_size {}
	extend_values {}
	attribute_values {}
	tasks_interval {}
        query {}
    } -orderby {
        first_names {
            label "[_ contacts.First_Name]"
            orderby_asc  "lower(first_names) asc, lower(last_name) asc"
            orderby_desc "lower(first_names) desc, lower(last_name) desc"
        }
        last_name {
            label "[_ contacts.Last_Name]"
            orderby_asc  "lower(last_name) asc, lower(first_names) asc"
            orderby_desc "lower(last_name) desc, lower(first_names) desc"
        }
        organization {
            label "[_ contacts.Organization]"
            orderby_asc  "lower(organizations.name) asc"
            orderby_desc "lower(organizations.name) desc"
        }
        last_modified {
            label "[_ contacts.Last_Modified]"
            orderby_asc  "acs_objects.last_modified asc"
            orderby_desc "acs_objects.last_modified desc"
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
            page_size 64000
            row {
		$row_list
	    }
	}
    }

set extend_list "$extend_attr contact_url message_url name orga_info"

if { ![string equal [lsearch -exact $type_list "employees"] "-1"] } {
    # We use this multirow since is going to retrive the attribute values
    # for the employee and the employer

    db_multirow -extend $extend_list -unclobber contacts employees_select " " {
	set contact_url [contact::url -party_id $party_id]
	set message_url [export_vars -base "$contact_url/message" {{message_type "email"}}]
	set name "[contact::name -party_id $party_id]"

	foreach attribute $attr_val_name {
	    set attr_id   [lindex $attribute 0]
	    set attr_name [lindex $attribute 1]
	    set contact_party_revision [contact::live_revision -party_id $party_id]
	    set $attr_id  [ams::value \
			       -object_id $contact_party_revision \
			       -attribute_id $attr_id \
			       -attribute_name "$attr_name"]
	    
	    if { ![exists_and_not_null $attr_id] } {
		set contact_party_revision [contact::live_revision -party_id $employee_id]
		set $attr_id  [ams::value \
				   -object_id $contact_party_revision \
				   -attribute_id $attr_id \
				   -attribute_name "$attr_name"]
	    }
	}
	
	set display_employers_p [parameter::get \
				     -parameter DisplayEmployersP \
				     -package_id $package_id \
				     -default "0"]
	
	if {$display_employers_p && [person::person_p -party_id $party_id]} {
	    # We want to display the names of the organization behind the employees name
	    set organizations [contact::util::get_employers -employee_id $party_id]
	    if {[llength $organizations] > 0} {
		set orga_info {}
		foreach organization $organizations {
		    set organization_url [contact::url -party_id [lindex $organization 0]]
		    set organization_name [lindex $organization 1]
		    lappend orga_info "<a href=\"$organization_url\">$organization_name</a>"
		}
		
		if {![empty_string_p $orga_info]} {
		    set orga_info " - ([join $orga_info ", "])"
		}
	    }
	}
	
    }


} else {

    db_multirow -extend $extend_list -unclobber contacts contacts_select " " {
	set contact_url [contact::url -party_id $party_id]
	set message_url [export_vars -base "$contact_url/message" {{message_type "email"}}]
	set name "[contact::name -party_id $party_id]"
	foreach attribute $attr_val_name {
	    set attr_id   [lindex $attribute 0]
	    set attr_name [lindex $attribute 1]
	    set contact_party_revision [contact::live_revision -party_id $party_id]
	    set $attr_id  [ams::value \
			       -object_id $contact_party_revision \
			       -attribute_id $attr_id \
			       -attribute_name "$attr_name"]
	}
	
	set display_employers_p [parameter::get \
				     -parameter DisplayEmployersP \
				     -package_id $package_id \
				     -default "0"]
	
	if {$display_employers_p && [person::person_p -party_id $party_id]} {
	    # We want to display the names of the organization behind the employees name
	    set organizations [contact::util::get_employers -employee_id $party_id]
	    if {[llength $organizations] > 0} {
		set orga_info {}
		foreach organization $organizations {
		    set organization_url [contact::url -party_id [lindex $organization 0]]
		    set organization_name [lindex $organization 1]
		    lappend orga_info "<a href=\"$organization_url\">$organization_name</a>"
		}
		
		if {![empty_string_p $orga_info]} {
		    set orga_info " - ([join $orga_info ", "])"
		}
	    }
	}
	
    }
    
}


if { [exists_and_not_null query] && [template::multirow size contacts] == 1 } {
    # Redirecting the user directly to the one resulted contact
    ad_returnredirect [contact::url -party_id [template::multirow get contacts 1 party_id]]
    ad_script_abort
}


list::write_output -name contacts

