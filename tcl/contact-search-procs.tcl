ad_library {

  Support procs for the contacts package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

}

namespace eval contact:: {}
namespace eval contact::search:: {}
namespace eval contact::search::condition:: {}


ad_proc -public contact::search::new {
    {-search_id ""}
    {-title ""}
    {-owner_id ""}
    {-all_or_any}
    {-object_type}
    {-deleted_p "f"}
} {
    create a contact search
} {
    if { [exists_and_not_null owner_id] } {
        set owner_id [ad_conn user_id]
    }
    set var_list [list \
                      [list search_id $search_id] \
                      [list title $title] \
                      [list owner_id $owner_id] \
                      [list all_or_any $all_or_any] \
                      [list object_type $object_type] \
                      ]

    return [package_instantiate_object -var_list $var_list contact_search]
}

ad_proc -public contact::search::update {
    {-search_id ""}
    {-title ""}
    {-owner_id ""}
    {-all_or_any}
} {
    create a contact search
} {
    if { [contact::search::exists_p -search_id $search_id] } {
        db_dml update_search {
            update contact_searches
               set title = :title,
                   owner_id = :owner_id,
                   all_or_any = :all_or_any
             where search_id = :search_id
        }
    }
}

ad_proc -public contact::search::delete {
    {-search_id ""}
} {
    create a contact search
} {
    return [db_0or1row delete_it { update contact_searches set deleted_p = 't' where search_id = :search_id }]
}

ad_proc -public contact::search::exists_p {
    {-search_id ""}
} {
    create a contact search
} {
    if { [db_0or1row exists_p { select 1 from contact_searches where search_id = :search_id }] } {
        return 1
    } else {
        return 0
    }
}

ad_proc -public contact::search::owner_id {
    {-search_id ""}
} {
    create a contact search
} {
    return [db_string get_owner_id { select owner_id from contact_searches where search_id = :search_id } -default {}]
}

ad_proc -public contact::search::log {
    {-search_id}
    {-user_id ""}
} {
    log a search
} {
    if { ![exists_and_not_null user_id] } {
        set user_id [ad_conn user_id]
    }
    db_1row log_search {}
}

ad_proc -public contact::search::results_count {
    {-search_id}
    {-query ""}
} {
    Get the total number of results from a search. Cached.
} {
    return [util_memoize [list ::contact::search::results_count_not_cached -search_id $search_id -query $query]]
}


ad_proc -public contact::search::results_count_not_cached {
    {-search_id}
    {-query ""}
} {
    Get the total number of results from a search
} {
    return [db_string select_results_count {}]
}




ad_proc -public contact::search_clause {
    {-and:boolean}
    {-search_id}
    {-query ""}
    {-party_id "party_id"} 
    {-revision_id "revision_id"}
} {
    Get the search clause for a search_id

    @param and Set this flag if you want the result to start with an 'and' if the list of where clauses returned is non-empty.
} {
    set query [string trim $query]
    set search_clauses [list]
    set where_clause [contact::search::where_clause -search_id $search_id -party_id $party_id -revision_id $revision_id]

    if { [exists_and_not_null where_clause] } {
        lappend search_clauses $where_clause
    }
    if { [exists_and_not_null query] } {
        lappend search_clauses [contact::search::query_clause -query $query -party_id $party_id]
    }

    set result {}
    if { [llength $search_clauses] > 0 } {
        if { $and_p } {
            append result "and "
        }
        if { [llength $search_clauses] > 1 } {
            append result "( [join $search_clauses "\n and "] )"
        } else {
            append result [join $search_clauses "\n and "]
        }
    }
    return $result
}

ad_proc -public contact::search::query_clause {
    {-and:boolean}
    {-query ""}
    {-party_id "party_id"}
} {
    create a contact search query. If the query supplied is an integer
    it searches for the party_id otherwise the search is for contacts
    that match all 

    @param and Set this flag if you want the result to start with an 'and' if the list of where clauses returned is non-empty.
} {
    set query [string trim $query]
    set query_clauses [list]

    if { [string is integer $query] } {
        lappend query_clauses "$party_id = $query"
    } elseif { [exists_and_not_null query] } {
        foreach term $query {
            lappend query_clauses "upper(contact__name($party_id)) like upper('%${term}%')"
        }
    }

    set result {}
    if { [llength $query_clauses] > 0 } {
        if { $and_p } {
            append result "and "
        }
        if { [llength $query_clauses] > 1 } {
            append result "( [join $query_clauses "\n and "] )"
        } else {
            append result [join $query_clauses "\n and "]
        }
    }
    return $result
}

ad_proc -public contact::search::condition::new {
    {-search_id}
    {-type}
    {-var_list}
} {
    create a contact search
} {
    if { [string is false [contact::search::condition::exists_p -search_id $search_id -type $type -var_list $var_list]] } {
        db_dml insert_condition {
            insert into contact_search_conditions
            ( condition_id, search_id, type, var_list )
            values 
            ( (select acs_object_id_seq.nextval), :search_id, :type, :var_list )
        }
    }
}


ad_proc -public contact::search::condition::delete {
    {-condition_id}
} {
    create a contact search
} {
    db_dml insert_condition {
        delete from contact_search_conditions where condition_id = :condition_id
    }
}

ad_proc -public contact::search::condition::exists_p {
    {-search_id}
    {-type}
    {-var_list}
} {
} {
    if { [db_0or1row exists_p { select 1 from contact_search_conditions where search_id = :search_id and type = :type and var_list = :var_list }] } {
        return 1
    } else {
        return 0
    }
}




ad_proc -public contact::search::where_clause {
    {-search_id}
    {-and:boolean}
    {-party_id}
    {-revision_id}
} {
} {
    if { $and_p } {
        return [util_memoize [list ::contact::search::where_clause_not_cached \
                                  -search_id $search_id \
                                  -and \
                                  -party_id $party_id \
                                  -revision_id $revision_id]]
    } else {
        return [util_memoize [list ::contact::search::where_clause_not_cached \
                                  -search_id $search_id \
                                  -party_id $party_id \
                                  -revision_id $revision_id]]
    }
}

ad_proc -public contact::search::where_clause_not_cached {
    {-search_id}
    {-and:boolean}
    {-party_id}
    {-revision_id}
} {
} {
    db_0or1row get_search_info {}
    set where_clauses [list]

    if { [exists_and_not_null all_or_any] } {
        if { $all_or_any == "any" } {
            set operator "or"
        } else {
            set operator "and"
        }
        if { $object_type == "person" } {
            lappend where_clauses "$party_id in ( select person_id from persons )"
        } elseif { $object_type == "organization" } {
            lappend where_clauses "$party_id in ( select organization_id from organizations )"
        }
        db_foreach select_queries {} {
            lappend where_clauses [contact::search::translate -type $type -var_list $var_list -to code -revision_id $revision_id -party_id $party_id]
        }
    } else {
        set operator "and"
    }

    set result {}
    if { [llength $where_clauses] > 0 } {
        if { $and_p } {
            append result "and "
        }
        if { [llength $where_clauses] > 1 } {
            append result "( [join $where_clauses "\n $operator "] )"
        } else {
            append result [join $where_clauses "\n $operator "]
        }
    }
    return $result
}


ad_proc -public contact::search::translate {
    {-type}
    {-var_list}
    {-to "code"}
    {-party_id}
    {-revision_id}
} {
    returns the group_id for which this group is a component, if none then it return null
} {
    set output_code ""
    set output_pretty ""
    switch $type {
        attribute {
            set attribute_id [lindex $var_list 0]
            if { $to == "pretty" } {
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
                            if { $to == "pretty" } {
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
                                    set output_pretty "[_ contacts.lt_attribute_pretty_coun_2]"
                                    set output_code "$revision_id in (\n\select aav${attribute_id}.object_id\n  from ams_attribute_values aav${attribute_id}, postal_addresses pa${attribute_id}\n where aav${attribute_id}.attribute_id = '${attribute_id}' and aav${attribute_id}.value_id = pa${attribute_id}.address_id and pa${attribute_id}.country_code = '$value' )"
                                }
                                country_is_not {
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
        }
        contact {
            set operand [lindex $var_list 0]
            set interval "[lindex $var_list 1] [lindex $var_list 2]"
            switch $operand {
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
        }
        group {
            set operand [lindex $var_list 0]
            set group_id [lindex $var_list 1]
            if { $to == "pretty" } {
                set group_pretty [lang::util::localize [db_string select_group_name { select group_name from groups where group_id = :group_id }]]
            } else {
                set group_pretty ""
            }
            switch $operand {
                in {
                    set output_pretty "[_ contacts.lt_The_contact_is_in_the]"
                    set output_code "$party_id in ( select member_id from group_distinct_member_map where group_id = '$group_id')"
                }
                not_in {
                    set output_pretty "[_ contacts.lt_The_contact_is_NOT_in]"
                    set output_code "$party_id not in ( select member_id from group_distinct_member_map where group_id = '$group_id')"
                }
            }
        }
        tasks {
            switch $to {
                pretty {
                    set output $var_list
                }
                code {
                    set output $var_list
                }
            }
        }
    }
    if { ![exists_and_not_null output_pretty] || ![exists_and_not_null output_code] } {
        if { [exists_and_not_null error_message] } {
            error "[_ contacts.lt_The_query_type_var_li]"
        } else {
            error "[_ contacts.lt_The_query_type_var_li_1]"
        }
    } else {
        switch $to {
            code { return $output_code }
            pretty { return $output_pretty }
        }
    }
}


