ad_page_contract {
    List and manage contacts.
 
    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {search_id:integer,optional}
    {type ""}
    {save ""}
    {add ""}
    {next ""}
    {clear ""}
    {delete ""}
    {search ""}
    {object_type ""}
    {all_or_any ""}
    {title ""}
    {owner_id ""}
    {aggregate_attribute_id ""}
    {aggregate ""}
    {attribute_values ""}
    {attribute_option ""}
    {attribute_names ""}
    {attr_val_name ""}
} -validate {
    valid_object_type -requires {object_type} {
        if { [lsearch [list party person organization] $object_type] < 0 } {
            ad_complain "[_ contacts.You_have_specified_an_invalid_object_type]"
        }
    }
    valid_search_id -requires {search_id} {
	db_0or1row condition_exists_p {
                                        select owner_id
                                          from contact_searches
                                         where search_id = :search_id
                                      }
        if { [exists_and_not_null owner_id] } {
	    set valid_owner_ids [list]
	    lappend valid_owner_ids [ad_conn user_id]
	    if { [permission::permission_p -object_id [ad_conn package_id] -privilege "admin"] } {
		lappend valid_owner_ids [ad_conn package_id]
	    }
	    if { [lsearch $valid_owner_ids $owner_id] < 0 } {
		if { [contact::exists_p -party_id $owner_id] } {
		    ad_complain "[_ contacts.lt_You_do_not_have_permission_to_edit_other_peo]"
		} else {
		    ad_complain "[_ contacts.lt_You_do_not_have_permission_to_edit_this_search]"
		}
	    }
	}
    }
}



if { [exists_and_not_null aggregate] } {
    ad_returnredirect "[export_vars -base ./ -url {search_id aggregate_attribute_id}]"
}

set page_title "[_ contacts.Advanced_Search]"
set context [list $page_title]

if { [exists_and_not_null clear] } {
    ad_returnredirect "search"
}

if { [exists_and_not_null delete] } {
    ad_returnredirect [export_vars -base search-action -url {search_id {action delete}}]
}

if { [exists_and_not_null search] } {
    ad_returnredirect ".?search_id=$search_id"
}


set search_exists_p 0
# set query_pretty [list]
if { [exists_and_not_null search_id] } {
    if { [contact::search::exists_p -search_id $search_id] } {
        db_1row get_em { select title, owner_id, all_or_any, object_type from contact_searches where search_id = :search_id }
        set search_exists_p 1
    }
}


if { $search_exists_p } {
    # Figure out if the search was over a person, organization or both
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
	    append search_for_clause "and object_type = 'person'"
	    
	    # We are going to take the default attributes from the parameter
	    set default_extend_attributes [parameter::get -parameter "DefaultPersonAttributeExtension"]
	    
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
	    append search_for_clause "and object_type = 'organization'"

	    # We are going to take the default attributes from the parameter
	    set default_extend_attributes [parameter::get -parameter "DefaultOrganizationAttributeExtension"]
	}
	party {
	    if { ![empty_string_p $var_list] } {
		# Default attributes for the group, persons and organizations
		set group_id [lindex [split $var_list " "] 1]
		set search_for_clause "and (l.list_name like '%__-2' or l.list_name like '%__$group_id') "
	    }

	    # We are going to take the default attributes from the parameter
	    set default_extend_attributes [parameter::get -parameter "DefaultPersonOrganAttributeExtension"]
	}
    }
	
    set show_default_names ""
    set show_names ""
    # We add the default attributes, first we take out all spaces
    # and then split by ";"
    regsub -all " " $default_extend_attributes "" default_extend_attributes
    set default_extend_attributes [split $default_extend_attributes ";"]

    foreach attr $default_extend_attributes {
	# Now we get the attribute_id
	set attr_id [attribute::id -object_type "person" -attribute_name "$attr"]
	if { [empty_string_p $attr_id] } {
	    set attr_id [attribute::id -object_type "organization" -attribute_name "$attr"]
	}

	# We need to check if the attribute is not already present
	# in the list, otherwise we could have duplicated.
	lappend attribute_values $attr_id
	lappend default_names "[_ acs-translations.ams_attribute_${attr_id}_pretty_name]"
	
	if { [string equal [lsearch -exact $attr_val_name "[list $attr_id $attr]"] "-1"] } {
	    lappend attr_val_name [list $attr_id $attr]
	}
    }

    # To extend the reult list using default attributes
    if { [exists_and_not_null default_names] } {
	set show_default_names "[join $default_names ", "], "
    }

    # To extend the reult list using the selected attributes
    if { [exists_and_not_null attribute_names] } {
	set show_names [join $attribute_names ", "]
    }

    # Now we are going to create the select options
    set attribute_values_query ""
    if { [exists_and_not_null attribute_values] } {
	set attribute_values_query "and lam.attribute_id not in ([template::util::tcl_to_sql_list $attribute_values])"
    }
    set attribute_options [db_list_of_lists get_ams_options " "]
    set ams_options [list [list "- - - - - - - - - -" ""]]
    foreach attribute $attribute_options {
	set attribute_name [lang::util::localize [db_string get_ams_pretty_name { }]]
	lappend ams_options [list $attribute_name $attribute]
	}
    
    ad_form -name extend_attributes -has_submit 1 -form {
	{attribute_option:text(select),optional
	    {label "[_ contacts.Extend_result_list_by]:"}
	    {options { $ams_options }}
	    {html { onChange "document.extend_attributes.submit();" }}
	}
	{search_id:text(hidden)
	    {value "$search_id"}
	}
	{attribute_values:text(hidden)
	    {value "$attribute_values"}
	}
	{attribute_names:text(hidden)
	    {value "$attribute_names"}
	}
	{attr_val_name:text(hidden)
	    {value "$attr_val_name"}
	}
    } -on_submit {
	# We clear the list when no value is submited, otherwise
        # we acumulate the extend values.
        if { [empty_string_p $attribute_option] } {
            set attribute_values [list]
	    set attribute_names [list]
	    set attr_val_name [list]
        } else {
	    set attribute $attribute_option
	    ams::attribute::get -attribute_id $attribute -array attr_info
	    set name $attr_info(attribute_name)
	    lappend attribute_names "[_ acs-translations.ams_attribute_${attribute}_pretty_name]"
            lappend attribute_values $attribute
	    lappend attr_val_name [list $attribute $name]
        }
        ad_returnredirect [export_vars -base "search" {search_id attribute_values attribute_names attr_val_name}]
    }
}


set object_type_pretty_name(party)        [_ contacts.People_or_Organizations]
set object_type_pretty_name(person)       [_ contacts.People]
set object_type_pretty_name(organization) [_ contacts.Organizations]

if { ![exists_and_not_null owner_id] } {
    set owner_id [ad_conn user_id]
}


# FORM HEADER
set form_elements {
    {search_id:key}
    {owner_id:integer(hidden)}
}

if { [exists_and_not_null object_type] } {
    set object_type_pretty $object_type_pretty_name($object_type)
    append form_elements {
        {object_type:text(hidden) {value $object_type}}
        {object_type_pretty:text(inform) {label {[_ contacts.Search_for]}} {value "<strong>$object_type_pretty</strong>"} {after_html "[_ contacts.which_match]"}}
        {all_or_any:text(select),optional {label ""} {options {{[_ contacts.All] all} {[_ contacts.Any] any}}} {after_html "[_ contacts.lt_of_the_following_cond]"}}
    }
} else {
    set object_type_options [list]
    foreach object_type_temp [list party person organization] {
        lappend object_type_options [list $object_type_pretty_name($object_type_temp) $object_type_temp]
    }
    append form_elements {
        {object_type:text(select) {label {\#contacts.Search_for\#}} {options $object_type_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
    }
}



if { $search_exists_p } {
    set conditions [list]
    db_foreach selectqueries {
        select condition_id, type as query_type, var_list as query_var_list from contact_search_conditions where search_id = :search_id
    } {
        lappend conditions "[contacts::search::condition_type -type $query_type -request pretty -var_list $query_var_list] <a href=\"[export_vars -base search-condition-delete -url {condition_id}]\"><img src=\"/resources/acs-subsite/Delete16.gif\" width=\"16\" height=\"16\" border=\"0\"></a>"
    }
    if { [llength $conditions] > 0 } {
	set query_pretty "<ul><li>[join $conditions {</li><li>}]</li></ul>"
    } else {
	set query_pretty ""
    }
    lappend form_elements [list query:text(hidden),optional]
    lappend form_elements [list query_pretty:text(inform),optional [list label {}] [list value $query_pretty]]
}


if { [exists_and_not_null object_type] } {

    # QUERY TYPE
    set type_options [contacts::search::condition_types]

    append form_elements {
        {type:text(select),optional {label {}} {options $type_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
    }
}


# get condition types widgets
set form_elements [concat \
                       $form_elements \
                       [contacts::search::condition_type -type $type -request ad_form_widgets -form_name advanced_search -object_type $object_type] \
                      ]

lappend form_elements  [list next:text(submit) [list label [_ acs-kernel.common_OK]] [list value "ok"]]

if { $search_exists_p } {
    set results_count [contact::search::results_count -search_id $search_id]
    append form_elements {
        {title:text(text),optional {label "<br><br>[_ contacts.save_this_search_]"} {html {size 40 maxlength 255}}}
        {save:text(submit) {label "[_ contacts.Save]"} {value "save"}}
        {search:text(submit) {label "[_ contacts.Search]"} {value "search"}}
        {clear:text(submit) {label "[_ contacts.Clear]"} {value "clear"}}
        {delete:text(submit) {label "[_ contacts.Delete]"} {value "delete"} \
	     {after_html "<br>[_ contacts.Aggregate_by]:<br>"}
	}
    }

    append form_elements [contacts::search::condition_type::attribute \
			      -request ad_form_widgets \
			      -prefix "aggregate_" \
			      -without_arrow_p "t" \
			      -only_multiple_p "t"]

    append form_elements {
	{aggregate:text(submit) {label "[_ contacts.Aggregate]"} {value "aggregate"}}
        {results_count_widget:text(inform) {label "&nbsp;&nbsp;<span style=\"font-size: smaller;\">[_ contacts.Results]</span>"} {value {<a href="[export_vars -base ./ -url {search_id}]">$results_count</a>}}}
    }
}

ad_form -name "advanced_search" -method "GET" -form $form_elements \
    -on_request {
    } -edit_request {
    } -on_refresh {
    } -on_submit {
        if { [contact::search::exists_p -search_id $search_id] } {
            contact::search::update -search_id $search_id -title $title -owner_id $owner_id -all_or_any $all_or_any
        }
        set form_var_list [contacts::search::condition_type -type $type -request form_var_list -form_name advanced_search]
        if { $form_var_list != "" } {
            if { [string is false [contact::search::exists_p -search_id $search_id]] } {
                set search_id [contact::search::new -search_id $search_id -title $title -owner_id $owner_id -all_or_any $all_or_any -object_type $object_type]
            }
            contact::search::condition::new -search_id $search_id -type $type -var_list $form_var_list
        }
    } -after_submit {
        if { $form_var_list != "" || [exists_and_not_null save] } {
            set export_list [list search_id]
            if { ![contact::search::exists_p -search_id $search_id] } {
                lappend export_list object_type all_or_any
            } else {
		contact::search::flush -search_id $search_id
	    }
            ad_returnredirect [export_vars -base "search" -url [list $export_list]]
            ad_script_abort
	}
    }


