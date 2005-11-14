set required_param_list [list attr_id search_id]
set optional_param_list [list base_url extend_id]
set optional_unset_list [list]

foreach required_param $required_param_list {
    if { ![info exist $required_param] } {
	ad_return_complaint 1 "Parameter $required_param is required"
    }
}

foreach optional_param $optional_param_list {
    if { ![exists_and_not_null ${optional_param}] } {
	set $optional_param ""
    }
}

foreach unset_param $optional_unset_list {
    if { ![exists_and_not_null ${optional_param}] } {
	unset $unset_param
    }
}

# Get the search message
set message [contact::search_pretty -search_id $search_id]

switch '$attr_id' {
    '-1' {
	# Search for the country in home_address 
	# or company_addres
	set attr_name "[_ contacts.Country]"
	set query_name get_countries_options
	set result_query get_countries_results
	set attribute_p 0
    } 
    '-2' {
	# Search for Relationship's
	set attr_name "[_ contacts.Relationship]"
	set query_name get_relationship_options
	set result_query get_relationship_results
	set attribute_p 0
    }
    default {
	# Get the attribute name and the options for that attribute
	set attr_name [attribute::pretty_name -attribute_id $attr_id]
	set query_name get_attribute_options
	set result_query get_results
	set attribute_p 1
    }
}


# Get the search_clasue used in the advanced search
set search_clause [contact::search_clause -and \
		       -search_id $search_id \
		       -query "" \
		       -party_id "parties.party_id" \
		       -revision_id "revision_id"]

set extend_pretty_name ""
if { [exists_and_not_null extend_id] } {
    set extend_info [db_list_of_lists get_extend_name { }]
    set extend_pretty_name [lindex [lindex $extend_info 0] 0]
    set extend_var_name    [lindex [lindex $extend_info 0] 1]
    set extend_subquery    [lindex [lindex $extend_info 0] 2]
    set elements [list \
		      option [list \
				  label "<b>$attr_name</b>"] \
		      result [list \
				  display_template {
				      @contacts.result@
				  }] \
		      $extend_var_name [list \
					    label "<b>$extend_pretty_name</b>" \
					    display_template {
						"Query Result TODO"
					    }]]
} else {
    set elements [list \
		      option [list \
				  label "<b>$attr_name</b>"] \
		      result [list \
				  display_template {
				      @contacts.result@
				  }
			     ]]
}


template::list::create  \
    -name "contacts" \
    -multirow contacts \
    -row_pretty_plural "" \
    -actions "" \
    -bulk_actions "" \
    -elements $elements

db_multirow -extend { result } contacts $query_name " " {
    # We get the value_id here and not in the options query since
    # the value_id is only present when one attribute is associated
    # to one option, and we want to see every option.
    set option_string [lang::util::localize $option]
    if { [string equal "Contact Rel " [string range $option_string 0 11]] } {
	set option [string range $option_string 12 [string length $option_string]]
    }
    if { $attribute_p } {
	set value_id [db_string get_value_id { } -default 0]
    }
    set result "[db_string $result_query " " -default 0]"
}



set select_options [list]

foreach option [contacts::attribute::options_attribute] {
    lappend select_options [list [lang::util::localize [lindex $option 0]] [lindex $option 1]]
}

ad_form -name aggregate -has_submit "1" -form {
    {search_id:integer(hidden)
	{value $search_id}
    }
    {aggregate_extend_id:text(hidden)
	{value $extend_id}
    }
    {aggregate_attribute_id:integer(select)
	{label "[_ contacts.Aggregate_by]" }
	{value $attr_id}
	{options $select_options}
	{html { onChange document.aggregate.submit();}}
    }
}

set extend_options [db_list_of_lists get_extend_options { }]

if { [string equal [llength $extend_options] 0] } {
    set extend_id ""
}

set extend_options [linsert $extend_options 0 [list "- - - - - - " ""]]

ad_form -name extend -has_submit "1" -form {
    {search_id:integer(hidden)
	{value $search_id}
    }
    {aggregate_attribute_id:integer(hidden)
	{value $attr_id}
    }
    {aggregate_extend_id:text(select)
	{label "[_ contacts.Extend_result_list_by]" }
	{options $extend_options}
	{html { onChange document.extend.submit();}}
	{value $extend_id}
    }
}

