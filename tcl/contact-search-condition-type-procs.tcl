ad_library {

    Contact search condition type procs

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2005-07-18
    @cvs-id $Id$

}

namespace eval contacts:: {}
namespace eval contacts::search:: {}
namespace eval contacts::search::condition_type:: {}

ad_proc -public contacts::search::condition_type {
    -type:required
    -request:required
    {-var_list ""}
    {-form_name ""}
    {-party_id "party_id"}
    {-revision_id "revision_id"}
    {-object_type "party"}
    {-prefix "condition"}
} {
    This proc defers its responses to all other <a href="/api-doc/proc-search?show_deprecated_p=0&query_string=contacts::search::condition_type::&source_weight=0&param_weight=3&name_weight=5&doc_weight=2&show_private_p=1&search_type=All+matches">contacts::search::condition_type::${type}</a> procs.

    @param type type <a href="/api-doc/proc-search?show_deprecated_p=0&query_string=contacts::search::condition_type::&source_weight=0&param_weight=3&name_weight=5&doc_weight=2&show_private_p=1&search_type=All+matches">contacts::search::condition_type::${type}</a> we defer to
    @param request
    must be one of the following:
    <ul>
    <li><strong>ad_form_widgets</strong> - returns element(s) string(s) suitable for inclusion in the form section of <a href="/api-doc/proc-view?proc=ad_form">ad_form</a></li>
    <li><strong>ad_form_completed_p</strong> - returns 1 if we no longer need to add widgets to the form</li>
    </ul>
    @param form_name The name of the template_form or ad_form being used
} {

    if { [contacts::search::condition_type_exists_p -type $type] } {
        switch $request {
            ad_form_widgets {
	    }
            form_var_list {
            }
	    sql {
	    }
	    pretty {
	    }
	    type_name {
	    }
	}
	return [contacts::search::condition_type::${type} -request $request -form_name $form_name -var_list $var_list -party_id $party_id -revision_id $revision_id -object_type $object_type -prefix $prefix]
    } else {
	# the widget requested did not exist
	ns_log Debug "Contacts: the contacts search condition type \"${type}\" was requested and the associated ::contacts::search::condition_type::${type} procedure does not exist"
    }
}

ad_proc -private contacts::search::condition_types {
} {
    Return all widget procs. Each list element is a list of the first then pretty_name then the widget
} {
    set condition_types [list]
    set all_procs [::info procs "::contacts::search::condition_type::*"]
    foreach condition_type $all_procs {
	if { [string is false [regsub {__arg_parser} $condition_type {} condition_type]] } {
	    regsub {::contacts::search::condition_type::} $condition_type {} condition_type
	    lappend condition_types [list [contacts::search::condition_type -type $condition_type -request "type_name"] $condition_type]
	}
    }
    return [::ams::util::localize_and_sort_list_of_lists -list $condition_types]
}

ad_proc -private contacts::search::condition_type_exists_p {
    {-type}
} {
    Return 1 if it exists and 0 if not
} {
    return [string is false [empty_string_p [info procs "::contacts::search::condition_type::${type}"]]]
}



ad_proc -private contacts::search::condition_type::attribute {
    -request:required
    {-var_list ""}
    {-form_name ""}
    {-party_id ""}
    {-revision_id ""}
    {-object_type ""}
    {-prefix ""}
} {
    Return all widget procs. Each list element is a list of the first then pretty_name then the widget
} {
    switch $request {
        ad_form_widgets {
            set attribute_id [ns_queryget ${prefix}attribute_id]

            if { [exists_and_not_null attribute_id] } {
                ams::attribute::get -attribute_id $attribute_id -array "attr_info"
                set value_method [ams::widget -widget $attr_info(widget) -request "value_method"]
                set attrprefix "${prefix}$attr_info(attribute_name)__"
                set operand [ns_queryget "${attrprefix}operand"]
                # we must use the operand in the var prefix because
                # this will rest the vars if somebody changes the operand
                set var1 "${attrprefix}${operand}__var1"
                set var2 "${attrprefix}${operand}__var2"
                set ${var1} [ns_queryget ${var1}]
                if { [template::element::exists $form_name $var1] } {
                    if { [template::element::get_property $form_name $var1 widget] == "date" } {
                        set ${var1} [join \
                                         [template::util::date::get_property linear_date_no_time \
                                              [template::element::get_value $form_name $var1] \
                                             ] \
                                         "-"]
                    }
                }
                set ${var2} [ns_queryget ${var2}]
                set var_elements [list] 

                switch $value_method {
                    ams_value__options {
                        set operand_options [list \
                                                 [list "[_ contacts.is_-]" "selected"] \
                                                 [list "[_ contacts.is_not_-]" "not_selected"] \
                                            ]
                       
			if { $operand == "selected" || $operand == "not_selected" } {
			    set option_options [ams::widget_options -attribute_id $attribute_id]
			    lappend var_elements [list ${var1}:text(select) [list label {}] [list options $option_options]]
			}
                    }
                    ams_value__telecom_number {
                        set operand_options [list \
                                                 [list "[_ contacts.area_code_is_-]" "area_code_equals"] \
                                                 [list "[_ contacts.area_code_is_not_-]" "not_area_code_equals"] \
                                                 [list "[_ contacts.country_code_is_-]" "country_code_equals"] \
                                                 [list "[_ contacts.lt_country_code_is_not_-]" "not_country_code_equals"] \
                                                ]
			if { [exists_and_not_null operand] } {
			    lappend var_elements [list ${var1}:integer(text) [list label {}] [list html [list size 3 maxlength 3]]]
			}
                    }
                    ams_value__text {
                        set operand_options [list \
                                                 [list "[_ contacts.contains_-]" "contains"] \
                                                 [list "[_ contacts.does_not_contain_-]" "not_contains"] \
                                                ]
			if { [exists_and_not_null operand] } {
			    lappend var_elements [list ${var1}:text(text) [list label {}]]
			}
                    }
                    ams_value__postal_address {
                        set operand_options [list \
                                                 [list "[_ contacts.country_is_-]" "country_is"] \
                                                 [list "[_ contacts.country_is_not_-]" "country_is_not"] \
                                                 [list "[_ contacts.stateprovince_is_-]" "state_is"] \
                                                 [list "[_ contacts.lt_stateprovince_is_not_]" "state_is_not"] \
                                                 [list "[_ contacts.lt_zippostal_starts_with]" "zip_is"] \
                                                 [list "[_ contacts.lt_zippostal_does_not_st]" "zip_is_not"] \
                                                ]

                        if { $operand == "state_is" || $operand == "state_is_not" } {
                            lappend var_elements [list ${var1}:text(text) [list label {}] [list html [list size 2 maxlength 2]]]
                        } elseif { $operand == "country_is" || $operand == "country_is_not" } {
                            set country_options [template::util::address::country_options]
                            lappend var_elements [list ${var1}:text(select) [list label {}] [list options $country_options]]
                        } elseif { $operand == "zip_is" || $operand == "zip_is_not" } {
                            lappend var_elements [list ${var1}:text(text) [list label {}] [list html [list size 7 maxlength 7]]]
                        }
                    }
                    ams_value__number {
                        set operand_options [list \
                                                 [list "[_ contacts.is_-]" "is"] \
                                                 [list "[_ contacts.is_greater_than_-]" "greater_than"] \
                                                 [list "[_ contacts.is_less_than_-]" "less_than"] \
                                                ]
			if { [exists_and_not_null operand] } {
			    lappend var_elements [list ${var1}:integer(text) [list label {}] [list html [list size 4 maxlength 20]]]
			}
                    }
                    ams_value__time {
                        set operand_options [list \
                                                 [list "[_ contacts.is_less_than_-]" "less_than"] \
                                                 [list "[_ contacts.is_more_than_-]" "more_than"] \
                                                 [list "[_ contacts.is_after_-]" "after"] \
                                                 [list "[_ contacts.is_before_-]" "before"] \
                                                ]
                        if { $operand == "more_than" || $operand == "less_than" } {
                            set interval_options [list \
                                                      [list years years] \
                                                      [list months months] \
                                                      [list days days] \
                                                     ]
                            lappend var_elements [list \
                                                       ${var1}:integer(text) \
                                                       [list label {}] \
                                                       [list html [list size 2 maxlength 3]] \
                                                      ]
                            lappend var_elements [list \
                                                       ${var2}:text(select) \
                                                       [list label {}] \
                                                       [list options $interval_options] \
                                                       [list after_html [list ago]] \
                                                      ]
                        } elseif { [exists_and_not_null operand] } {
                            lappend var_elements [list ${var1}:date(date) [list label {}]]
                        }
                    }
                }
            }
            
            set form_elements [list]

            
            set attribute_options [db_list_of_lists get_attributes {
                select pretty_name, attribute_id
                from ams_attributes	
                where object_type in ('organization','party','person','user') 
                and ams_attribute_id is not null
            }]
            set sorted_options [ams::util::localize_and_sort_list_of_lists -list $attribute_options]
            set attribute_options [list [list "" ""]]
            foreach op $sorted_options {
                lappend attribute_options [list "[lindex $op 0] ->" "[lindex $op 1]"]
            }
            lappend form_elements [list \
                                       ${prefix}attribute_id:text(select),optional \
                                       [list label {}] \
                                       [list options $attribute_options] \
                                       [list html [list onChange "javascript:acs_FormRefresh('$form_name')"]] \
                                       [list value $attribute_id] \
                                      ]
            
            if { [exists_and_not_null attribute_id] } {
                # now we add operand options that are available to anybody
                lappend operand_options [list "[_ contacts.is_set]" "set"] [list "[_ contacts.is_not_set]" "not_set"]

                lappend form_elements [list \
                                           ${attrprefix}operand:text(select),optional \
                                           [list label {}] \
                                           [list options [concat $operand_options]] \
                                           [list html [list onChange "javascript:acs_FormRefresh('$form_name')"]] \
                                          ]

                if { $operand != "set" && $operand != "not_set" } {
                    # there could be variable elements so we add them here
                    set form_elements [concat $form_elements $var_elements]
                }
            }
            return $form_elements
        }
        form_var_list {
            set attribute_id [ns_queryget ${prefix}attribute_id]
            if { [exists_and_not_null attribute_id] } {
                ams::attribute::get -attribute_id $attribute_id -array "attr_info"
                set value_method [ams::widget -widget $attr_info(widget) -request "value_method"]
                set prefix "${prefix}$attr_info(attribute_name)__"
                set operand [ns_queryget "${prefix}operand"]

                if { $operand == "set" || $operand == "not_set" } {
                    return [list $attribute_id $operand]
                } elseif { [exists_and_not_null operand] } {
                    set var1 "${prefix}${operand}__var1"
                    set var2 "${prefix}${operand}__var2"
                    set ${var1} [ns_queryget ${var1}]
                    if { [template::element::exists $form_name $var1] } {
                        if { [template::element::get_property $form_name $var1 widget] == "date" } {
                            set ${var1} [join \
                                             [template::util::date::get_property linear_date_no_time \
                                                  [template::element::get_value $form_name $var1] \
                                                 ] \
                                             "-"]
                        }
                    }
                    set ${var2} [ns_queryget ${var2}]
                    if { [exists_and_not_null ${var1}] } {
                        set results [list $attribute_id $operand]
                        lappend results [set ${var1}]
                        if { [exists_and_not_null ${var2}] } {
                            lappend results [set ${var2}]
                        }
                        return $results
                    } else {
                        return {}
                    }
                } else {
                    return {}
                }
            }
        }
        sql - pretty {
            set attribute_id [lindex $var_list 0]
            if { $request == "pretty" } {
                set attribute_pretty [attribute::pretty_name -attribute_id $attribute_id]
            } else {
                set attribute_pretty "[_ contacts.irrelevant]"
            }

            set operand [lindex $var_list 1]
            set value [string tolower [lindex $var_list 2]]

            switch $operand {
                set {
                    set output_pretty "[_ contacts.lt_attribute_pretty_is_s]"
                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' )"
                }
                not_set {
                    set output_pretty "[_ contacts.lt_attribute_pretty_is_n]"
                    set output_code "$revision_id not in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' )"
                }
                default {
                    ams::attribute::get -attribute_id $attribute_id -array "attr_info"
                    set value_method [ams::widget -widget $attr_info(widget) -request "value_method"]

                    switch $value_method {
                        ams_value__options {
                            if { $request == "pretty" } {
                                set option_pretty [ams::option::name -option_id $value]
                            } else {
                                set option_pretty ""
                            }

                            switch $operand {
                                selected {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_is_s_1]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_options ao${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav${attribute_id}.value_id = ao${attribute_id}.value_id and ao${attribute_id}.option_id = '$value' )"
                                }
                                not_selected {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_is_n_1]"
                                    set output_code "$revision_id not in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_options ao${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav${attribute_id}.value_id = ao${attribute_id}.value_id and ao${attribute_id}.option_id = '$value' )"
                                }
                            }
                        }
                        ams_value__telecom_number {
                            switch $operand {
                                area_code_equals {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_area]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, telecom_numbers tn${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav.${attribute_id}.value_id = tn${attribute_id}.number_id and tn${attribute_id}.area_city_code = '$value' )"
                                }
                                not_area_code_equals {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_area_1]"
                                    set output_code "$revision_id not in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, telecom_numbers tn${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav.${attribute_id}.value_id = tn${attribute_id}.number_id and tn${attribute_id}.area_city_code = '$value' )"
                                }
                                country_code_equals {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_coun]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, telecom_numbers tn${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav.${attribute_id}.value_id = tn${attribute_id}.number_id and tn${attribute_id}.country_code = '$value' )"
                                }
                                not_country_code_equals {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_coun_1]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, telecom_numbers tn${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav.${attribute_id}.value_id = tn${attribute_id}.number_id and tn${attribute_id}.area_city_code = '$value' )"
                                }
                            }
                        }
                        ams_value__text {
                            switch $operand  {
                                contains {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_cont]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_texts at${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}'\n   and aav${attribute_id}.value_id = at${attribute_id}.value_id\n   and lower(at${attribute_id}.text) like ('\%$value\%')\n)"
                                }
                                not_contains {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_does]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_texts at${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}'\n   and aav${attribute_id}.value_id = at${attribute_id}.value_id\n   and lower(at${attribute_id}.text) not like ('\%$value\%')\n)"
                                }
                            }
                        }
                        ams_value__postal_address {
                            set value [string toupper $value]
                            switch $operand {
                                country_is {
				    set country_pretty [_ ref-countries.$value]
                                    set output_pretty "[_ contacts.lt_attribute_pretty_coun_2]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, postal_addresses pa${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav${attribute_id}.value_id = pa${attribute_id}.address_id and pa${attribute_id}.country_code = '$value' )"
                                }
                                country_is_not {
				    set country_pretty [_ ref-countries.$value]
                                    set output_pretty "[_ contacts.lt_attribute_pretty_coun_3]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, postal_addresses pa${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav${attribute_id}.value_id = pa${attribute_id}.address_id and pa${attribute_id}.country_code = '$value' )"
                                }
                                state_is {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_stat]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, postal_addresses pa${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav${attribute_id}.value_id = pa${attribute_id}.address_id and pa${attribute_id}.region = '$value' )"
                                }
                                state_is_not {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_stat_1]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, postal_addresses pa${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav${attribute_id}.value_id = pa${attribute_id}.address_id and pa${attribute_id}.region = '$value' )"
                                }
                                zip_is {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_zipp]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, postal_addresses pa${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav${attribute_id}.value_id = pa${attribute_id}.address_id and pa${attribute_id}.postal_code like ('$value\%') )"
                                }
                                zip_is_not {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_zipp_1]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, postal_addresses pa${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav${attribute_id}.value_id = pa${attribute_id}.address_id and pa${attribute_id}.postal_code like ('$value\%') )"
                                }
                            }
                        }
                        ams_value__number {
                            switch $operand {
                                is {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_is_s_2]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_numbers an${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}'\n   and aav${attribute_id}.value_id = an${attribute_id}.value_id\n   and an${attribute_id}.number = '$value' )"
                                }
                                greater_than {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_is_g]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_numbers an${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}'\n   and aav${attribute_id}.value_id = an${attribute_id}.value_id\n   and an${attribute_id}.number > '$value' )"
                                }
                                less_than {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_is_l]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_numbers an${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}'\n   and aav${attribute_id}.value_id = an${attribute_id}.value_id\n   and an${attribute_id}.number < '$value' )"
                                }
                            }
                        }
                        ams_value__time {
                            set interval "$value [string tolower [lindex $var_list 3]]"
                            switch $operand {
                                less_than {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_is_l_1]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_times at${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}'\n   and aav${attribute_id}.value_id = at${attribute_id}.value_id\n   and at${attribute_id}.time > ( now() - '$interval'::interval ) )"
                                }
                                more_than {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_is_l_1]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_times at${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}'\n   and aav${attribute_id}.value_id = at${attribute_id}.value_id\n   and at${attribute_id}.time < ( now() - '$interval'::interval ) )"
                                }
                                after {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_is_a]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_times at${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}'\n   and aav${attribute_id}.value_id = at${attribute_id}.value_id\n   and at${attribute_id}.time > '$value'::timestamptz )"
                                }
                                before {
                                    set output_pretty "[_ contacts.lt_attribute_pretty_is_b]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, ams_times at${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}'\n   and aav${attribute_id}.value_id = at${attribute_id}.value_id\n   and at${attribute_id}.time < '$value'::timestamptz )"
                                }
                            }
                        }
                    }
                }
            }
            if { $request == "pretty" } {
                return $output_pretty
            } else {
                return $output_code
            }
        }
        type_name {
            return [_ contacts.Attribute]
        }
    }
}
















ad_proc -private contacts::search::condition_type::contact {
    -request:required
    {-var_list ""}
    {-form_name ""}
    {-party_id ""}
    {-revision_id ""}
    {-prefix "contact"}
    {-object_type ""}
} {
    Return all widget procs. Each list element is a list of the first then pretty_name then the widget
} {
    set operand [ns_queryget "${prefix}operand"]
    set var1 "${prefix}${operand}var1"
    set var2 "${prefix}${operand}var2"
    set ${var1} [ns_queryget ${var1}]
    set ${var2} [ns_queryget ${var2}]

    switch $request {
        ad_form_widgets {

            set form_elements [list]
            set contact_options [list \
                                     [list "[_ contacts.in_the_search] ->" "in_search"] \
                                     [list "[_ contacts.not_in_the_search] ->" "not_in_search"] \
                                     [list "[_ contacts.lt_updated_in_the_last_-]" "update"] \
                                     [list "[_ contacts.lt_not_updated_in_the_la]" "not_update"] \
                                     [list "[_ contacts.lt_commented_on_in_last_]" "comment"] \
                                     [list "[_ contacts.lt_not_commented_on_in_l]" "not_comment"] \
                                     [list "[_ contacts.lt_created_in_the_last_-]" "created"] \
                                     [list "[_ contacts.lt_not_created_in_the_la]" "not_created"] \
                                    ]
            if { $object_type == "person" } {
                lappend contact_options [list "[_ contacts.has_logged_in]" "login"]
                lappend contact_options [list "[_ contacts.has_never_logged_in]" "not_login"]
                lappend contact_options [list "[_ contacts.lt_has_logged_in_within_]" "login_time"]
                lappend contact_options [list "[_ contacts.lt_has_not_logged_in_wit]" "not_login_time"]
            }
            lappend form_elements [list \
                                       ${prefix}operand:text(select) \
                                       [list label {}] \
                                       [list options $contact_options] \
                                       [list html [list onChange "javascript:acs_FormRefresh('$form_name')"]] \
                                      ]

            # login and not_login do not need special elements
            if { [lsearch [list in_search not_in_search] ${operand}] >= 0 || ${operand} == "" } {
                set user_id [ad_conn user_id]
                set search_options [db_list_of_lists get_my_searches {
                        select title,
                               search_id
                          from contact_searches
                         where owner_id = :user_id
                           and title is not null
                           and not deleted_p
                         order by lower(title)
                    }]
                set search_options [concat [list [list "" ""]] $search_options]
                lappend form_elements [list \
                                           ${var1}:integer(select) \
                                           [list label {}] \
                                           [list options $search_options] \
                                          ]
            } else {
                set interval_options [list \
                                          [list days days] \
                                          [list months months] \
                                          [list years years] \
                                         ]
                lappend form_elements [list ${var1}:integer(text) [list label {}] [list html [list size 3 maxlength 4]]]
                lappend form_elements [list ${var2}:text(select) [list label {}] [list options $interval_options]]
            }
            return $form_elements
        }
        form_var_list {
            if { [exists_and_not_null operand] } {
                switch ${operand} {
                    login - not_login {
                        return [set ${operand}]
                    }
                    in_search - not_in_search {
                        if { [exists_and_not_null ${var1}] } {
                            return [list ${operand} [set ${var1}]]
                        }
                    }
                    default {
                        if { [exists_and_not_null ${var1}] && [exists_and_not_null ${var2}] } {
                            return [list ${operand} [set ${var1}] [set ${var2}]]
                        }
                    }
                }
            }
        }
        sql - pretty {
            set operand [lindex $var_list 0]
            set interval "[lindex $var_list 1] [lindex $var_list 2]"
            switch $operand {
                in_search {
                    set search_id [lindex $var_list 1]
                    set search_link "<a href=\"[export_vars -base {./} -url {search_id}]\">[contact::search::title -search_id $search_id]</a>"
                    set output_pretty "[_ contacts.lt_Contact_in_the_search_search_link]"
                    set output_code   [contact::party_id_in_sub_search_clause -search_id $search_id]
                }
                not_in_search {
                    set search_id [lindex $var_list 1]
                    set search_link "<a href=\"[export_vars -base {./} -url {search_id}]\">[contact::search::title -search_id $search_id]</a>"
                    set output_pretty "[_ contacts.lt_Contact_not_in_the_search_search_link]"
                    set output_code   [contact::party_id_in_sub_search_clause -search_id $search_id -not]
                }
                update {
                    set output_pretty "[_ contacts.lt_Contact_updated_in_th]"
                    set output_code   "CASE WHEN ( select creation_date from acs_objects where object_id = $revision_id ) > ( now() - '$interval'::interval ) THEN 't'::boolean ELSE 'f'::boolean END"
                }
                not_update {
                    set output_pretty "[_ contacts.lt_Contact_not_updated_i]"
                    set output_code   "CASE WHEN ( select creation_date from acs_objects where object_id = $revision_id ) > ( now() - '$interval'::interval ) THEN 'f'::boolean ELSE 't'::boolean END"
                }
                comment {
                    set output_pretty "[_ contacts.lt_Contact_commented_on_]"
                    set output_code   "CASE WHEN (select creation_date from acs_objects where object_id in ( select comment_id from general_comments where object_id = $party_id ) order by creation_date desc limit 1 ) > ( now() - '$interval'::interval ) THEN 't'::boolean ELSE 'f'::boolean END"
                }
                not_comment {
                    set output_pretty "[_ contacts.lt_Contact_not_commented]"
                    set output_code   "CASE WHEN (select creation_date from acs_objects where object_id in ( select comment_id from general_comments where object_id = $party_id ) order by creation_date desc limit 1 ) > ( now() - '$interval'::interval ) THEN 'f'::boolean ELSE 't'::boolean END"
                }
                created {
                    set output_pretty "[_ contacts.lt_Contact_created_in_th]"
                    set output_code   "CASE WHEN ( select acs_objects.creation_date from acs_objects where acs_objects.object_id = $party_id ) > ( now() - '$interval'::interval ) THEN 't'::boolean ELSE 'f'::boolean END"
                }
                not_created {
                    set output_pretty "[_ contacts.lt_Contact_not_created_i]"
                    set output_code   "CASE WHEN ( select acs_objects.creation_date from acs_objects where acs_objects.object_id = $party_id ) > ( now() - '$interval'::interval ) THEN 'f'::boolean ELSE 't'::boolean END"
                }
                login {
                    set output_pretty "[_ contacts.lt_Contact_has_logged_in]"
                    set output_code   "CASE WHEN ( select n_sessions from users where user_id = $party_id ) > 1 or ( select last_visit from users where user_id = $party_id ) is not null THEN 't'::boolean ELSE 'f'::boolean END"
                }
                not_login {
                    set output_pretty "[_ contacts.lt_Contact_has_never_log]"
                    set output_code   "CASE WHEN ( select n_sessions from users where user_id = $party_id ) > 1 or ( select last_visit from users where user_id = $party_id ) is not null THEN 'f'::boolean ELSE 't'::boolean END"
                }
                login_time {
                    set output_pretty "[_ contacts.lt_Contact_has_logged_in_1]"
                    set output_code   "CASE WHEN ( select last_visit from users where user_id = $party_id ) > ( now() - '$interval'::interval ) THEN 't'::boolean ELSE 'f'::boolean END"
                }
                not_login_time {
                    set output_pretty "[_ contacts.lt_Contact_has_not_logge]"
                    set output_code   "CASE WHEN ( select last_visit from users where user_id = $party_id ) > ( now() - '$interval'::interval ) THEN 'f'::boolean ELSE 't'::boolean END"
                }
            }
            if { $request == "pretty" } {
                return $output_pretty
            } else {
                return $output_code
            }
        }
        type_name {
            return [_ contacts.Contact]
        }
    }
}





ad_proc -private contacts::search::condition_type::group {
    -request:required
    {-var_list ""}
    {-form_name ""}
    {-party_id ""}
    {-revision_id ""}
    {-prefix "contact"}
    {-object_type ""}
} {
    Return all widget procs. Each list element is a list of the first then pretty_name then the widget
} {
    set prefix "contact"
    set operand  [ns_queryget "${prefix}operand"]
    set group_id [ns_queryget "${prefix}group_id"]

    switch $request {
        ad_form_widgets {
            set form_elements [list]
            set operand_options [list \
                                     [list "[_ contacts.contact_is_in_-]" "in"] \
                                     [list "[_ contacts.contact_is_not_in_-]" "not_in"] \
                                    ]

            set group_options [contact::groups -expand "all" -privilege_required "read"]
            lappend form_elements [list ${prefix}operand:text(select) [list label {}] [list options $operand_options] [list value $operand]]
            lappend form_elements [list ${prefix}group_id:integer(select) [list label {}] [list options $group_options] [list value $group_id]]
            return $form_elements
        }
        form_var_list {
            if { [exists_and_not_null operand] && [exists_and_not_null group_id] } {
                return [list $operand $group_id]
            } else {
                return {}
            }
        }
        sql - pretty {
            set operand [lindex $var_list 0]
            set group_id [lindex $var_list 1]
            if { $request == "pretty" } {
                set group_pretty [lang::util::localize [db_string select_group_name { select group_name from groups where group_id = :group_id }]]
            } else {
                set group_pretty ""
            }
            switch $operand {
                in {
                    set output_pretty "[_ contacts.lt_The_contact_is_in_the]"
                    set output_code "group_distinct_member_map.group_id = '$group_id'"
                }
                not_in {
                    set output_pretty "[_ contacts.lt_The_contact_is_NOT_in]"
                    set output_code "$party_id not in ( select member_id from group_distinct_member_map where group_id = '$group_id')"
                }
            }
            if { $request == "pretty" } {
                return $output_pretty
            } else {
                return $output_code
            }
        }
        type_name {
            return [_ contacts.Group]
        }
    }
}



ad_proc -private contacts::search::condition_type::relationship {
    -request:required
    {-var_list ""}
    {-form_name ""}
    {-party_id ""}
    {-revision_id ""}
    {-prefix "contact"}
    {-object_type ""}
} {
    Return all widget procs. Each list element is a list of the first then pretty_name then the widget
} {
    set role      [ns_queryget "${prefix}role"]
    set operand   [ns_queryget "${prefix}operand"]
    set times     [ns_queryget "${prefix}${role}times"]
    set search_id [ns_queryget "${prefix}${role}search_id"]

    if { ![exists_and_not_null object_type] } {
	set object_type "party"
    }
    switch $request {
        ad_form_widgets {
            set form_elements [list]

	    set rel_options [db_list_of_lists get_rels {
select acs_rel_type__role_pretty_name(primary_role) as pretty_name,
       primary_role as role
  from contact_rel_types
 where secondary_object_type in ( :object_type, 'party' )
 group by primary_role
 order by upper(acs_rel_type__role_pretty_name(primary_role))
	    }]
	    set rel_options [ams::util::localize_and_sort_list_of_lists -list $rel_options]
	    set rel_options [concat [list [list "" ""]] $rel_options]
            lappend form_elements [list \
                                       ${prefix}role:text(select) \
                                       [list label [_ contacts.with]] \
                                       [list options $rel_options] \
                                      ]

            set operand_options [list \
                                     [list "[_ contacts.exists]" "exists"] \
                                     [list "[_ contacts.does_not_exists]" "not_exists"] \
                                     [list "[_ contacts.in_the_search] ->" "in_search"] \
                                     [list "[_ contacts.not_in_the_search] ->" "not_in_search"] \
                                    ]
#                                     [list "[_ contacts.exists_at_least] ->" "min_number"] \
#                                     [list "[_ contacts.exists_at_most] ->" "max_number"] \

            lappend form_elements [list \
                                       ${prefix}operand:text(select),optional \
                                       [list label {}] \
                                       [list options $operand_options] \
                                       [list html [list onChange "javascript:acs_FormRefresh('$form_name')"]] \
                                      ]

            # login and not_login do not need special elements
	    switch $operand {
		min_number - max_number {
		    lappend form_elements [list ${prefix}${role}times:integer(text) [list label {}] [list html [list size 2 maxlength 4]] [list after_html [_ contacts.Times]]]
		}
		in_search - not_in_search {
		    set user_id [ad_conn user_id]
		    set search_options [db_list_of_lists get_my_searches {
                        select title,
			search_id
			from contact_searches
			where owner_id = :user_id
			and title is not null
			and not deleted_p
			order by lower(title)
                    }]
		    set search_options [concat [list [list "" ""]] $search_options]
		    lappend form_elements [list \
					       ${prefix}${role}search_id:integer(select) \
					       [list label {}] \
					       [list options $search_options] \
					      ]
		}
            }
            return $form_elements
        }
        form_var_list {
            if { [exists_and_not_null role] && [exists_and_not_null operand] } {
		set results [list $role $operand]
		switch $operand {
		    min_number - max_number {
			if { [exists_and_not_null times] } {
			    lappend results $times
			} else {
			    set not_complete_p 1
			}
		    }
		    in_search - not_in_search {
			if { [exists_and_not_null search_id] } {
			    lappend results $search_id
			} else {
			    set not_complete_p 1
			}
		    }
		}
		if { ![exists_and_not_null not_complete_p] } {
		    return $results
		}
            }
	    return {}
        }
        sql - pretty {
            set role [lindex $var_list 0]
	    set union "
(
( select object_id_one as party_id
    from acs_rels where rel_type in ( select rel_type
                                        from acs_rel_types
                                       where rel_type in ( select object_type
                                                             from acs_object_types
                                                            where supertype = 'contact_rel' )
                                         and role_two = '$role' ) )
union
( select object_id_two as party_id
    from acs_rels where rel_type in ( select rel_type
                                        from acs_rel_types
                                       where rel_type in ( select object_type
                                                             from acs_object_types
                                                            where supertype = 'contact_rel' )
                                         and role_one = '$role' ) )
)
"
	    set union_reverse "
(
( select object_id_two as party_id
    from acs_rels where rel_type in ( select rel_type
                                        from acs_rel_types
                                       where rel_type in ( select object_type
                                                             from acs_object_types
                                                            where supertype = 'contact_rel' )
                                         and role_two = '$role' ) )
union
( select object_id_one as party_id
    from acs_rels where rel_type in ( select rel_type
                                        from acs_rel_types
                                       where rel_type in ( select object_type
                                                             from acs_object_types
                                                            where supertype = 'contact_rel' )
                                         and role_one = '$role' ) )
)
"


	    set operand [lindex $var_list 1]
	    switch $operand {
		min_number - max_number { set times [lindex $var_list 2] }
		in_search - not_in_search { set search_id [lindex $var_list 2] }
	    }
	    if { $request == "pretty" } {
		if { [exists_and_not_null times] } {
		    if { $times != 1 } {
			set role [lang::util::localize [db_string get_pretty_role { select pretty_plural from acs_rel_roles where role = :role } -default {}]]
		    } else {
		      set role [lang::util::localize [db_string get_pretty_role { select pretty_name from acs_rel_roles where role = :role } -default {}]]
                    }
		} else {
		      set role [lang::util::localize [db_string get_pretty_role { select pretty_name from acs_rel_roles where role = :role } -default {}]]
                }
	    } else {
                set role ""
            }
            switch $operand {
		exists {
		    set output_pretty [_ contacts.lt_role_exists]
		    set output_code "party_id in $union"
		}
		not_exists {
		    set output_pretty [_ contacts.lt_role_not_exists]
		    set output_code "party_id not in $union"
		}
		max_number {
		    set output_pretty [_ contacts.lt_At_most_times_role_are_related]
		    set output_code "party_id in 
( select party_id from
(
select count(party_id) as rel_count, party_id from
$union_reverse rels
group by party_id
) rel_count_and_id
where rel_count <= $times )"
		}
		min_number {
		    set output_pretty [_ contacts.lt_At_least_times_role_are_related]
		    set output_code "party_id in 
( select party_id from
(
select count(party_id) as rel_count, party_id from
$union_reverse rels
group by party_id
) rel_count_and_id
where rel_count >= $times )"
		}
                in_search {
                    set search_link "<a href=\"[export_vars -base {./} -url {search_id}]\">[contact::search::title -search_id $search_id]</a>"
                    set output_pretty [_ contacts.lt_role_in_the_search_search_link]
  		    set output_code "party_id in 
( select party_id from
(
select distinct party_id from
$union_reverse rels
) rel_count_and_id
where [contact::party_id_in_sub_search_clause -search_id $search_id] )"
                }
                not_in_search {
                    set search_link "<a href=\"[export_vars -base {./} -url {search_id}]\">[contact::search::title -search_id $search_id]</a>"
                    set output_pretty [_ contacts.lt_role_not_in_the_search_search_link]
  		    set output_code "party_id in 
( select party_id from
(
select distinct party_id from
$union_reverse rels
) rel_count_and_id
where [contact::party_id_in_sub_search_clause -search_id $search_id -not] )"
                }
            }
            if { $request == "pretty" } {
                return $output_pretty
            } else {
                return $output_code
            }
        }
        type_name {
            return [_ contacts.Relationship]
        }
    }
}





