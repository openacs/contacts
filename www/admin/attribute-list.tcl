ad_page_contract {

} {
    search_id:notnull
}


set search_for [db_string get_search_for { } -default ""]

set search_for_clause ""

# Get the var list of the search if type equals group
# so we can retrieve the default attributes of the group
# also.
set var_list [db_string get_var_list { } -default ""]

# We get the default attributes of persons, organizations or both and of the group
# if there is a condition for the gorup in the search (when var_list not null)
switch $search_for {
    person {
	if { ![empty_string_p $var_list] } {
	    # Default attributes for the group and persons
	    set group_id [lindex [split $var_list " "] 1]
	    set search_for_clause "and (l.list_name like '%__-2' or l.list_name like '%__$group_id') "
	} else {
	    # Default attributes for person only
	    set search_for_clause "and l.list_name like '%__-2' "
	}
	append search_for_clause "and l.object_type = 'person'"
    }
    organization {
	if { ![empty_string_p $var_list] } {
	    # Default attributes for the group and organizations
	    set group_id [lindex [split $var_list " "] 1]
	    set search_for_clause "and (l.list_name like '%__-2' or l.list_name like '%__$group_id') "
	} else {
	    # Default attributes for organization
	    set search_for_clause "and l.list_name like '%__-2' "
	}
	append search_for_clause "and l.object_type = 'organization'"
    }
    party {
	if { ![empty_string_p $var_list] } {
	    # Default attributes for the group, persons and organizations
	    set group_id [lindex [split $var_list " "] 1]
	    set search_for_clause "and (l.list_name like '%__-2' or l.list_name like '%__$group_id') "
	}
    }
}


set bulk_actions [list "[_ contacts.Set_default]" set-default "[_ contacts.Set_default]" \
		      "[_ contacts.Remove_default]" remove-default "[_ contacts.Remove_default]"]

template::list::create \
    -name ams_options \
    -multirow ams_options \
    -key attribute_id \
    -bulk_action_method post \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars { search_id } \
    -elements {
	pretty_name {
	    label "Attribute Name"
	}
	default {
	    label ""
	}
    }
    

db_multirow -extend { default } ams_options get_ams_options { } {
    set default ""
    set default_p [db_string get_default_p { } -default "0"]
    if { $default_p } {
	set default "Default"
    }
}

