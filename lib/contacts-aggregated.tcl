set required_param_list [list attr_id search_id]
set optional_param_list [list base_url]
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

# Get the attribute name and the options for that attribute
set attr_name [attribute::pretty_name -attribute_id $attr_id]

# Get the search_clasue used in the advanced search
set search_clause [contact::search_clause -and \
		      -search_id $search_id \
		      -query "" \
		       -party_id "parties.party_id" \
		      -revision_id "revision_id"]

template::list::create  \
    -name "contacts" \
    -multirow contacts \
    -row_pretty_plural "" \
    -actions "" \
    -bulk_actions "" \
    -elements {
	option {
	    label "<b>$attr_name</b>"
	}
	result {
	    display_template {
		@contacts.result@
	    }
	}
    }

db_multirow -extend { result } contacts get_attribute_options { } {
    # We get the value_id here and not in the options query since
    # the value_id is only present when one attribute is associated
    # to one option, and we want to see every option.

    set value_id [db_string get_value_id { } -default 0]
    set result [db_string get_results " " -default 0]
}



set select_options [list]

foreach option [contacts::attribute::options_attribute] {
    lappend select_options [list [lang::util::localize [lindex $option 0]] [lindex $option 1]]
}

ad_form -name aggregate -form {
    {search_id:integer(hidden)
	{value $search_id}
    }
    {aggregate_attribute_id:integer(select)
	{label "[_ contacts.Aggregate_by]" }
	{value $attr_id}
	{options $select_options}
    }
}


