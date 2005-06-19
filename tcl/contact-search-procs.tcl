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
                      [list deleted_p $deleted_p] \
                      ]

    return [package_instantiate_object -var_list $var_list contact_search]
}

ad_proc -public contact::search::title {
    {-search_id ""}
} {
} {
    return [db_string select_title {} -default {}]
}

ad_proc -public contact::search::get {
    -search_id:required
    -array:required
} {
    Get the info on an ams_attribute
} {
    upvar 1 $array row
    db_1row select_search_info {} -column_array row
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
    db_dml delete_it { update contact_searches set deleted_p = 't' where search_id = :search_id }
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

ad_proc -private contact::party_id_in_sub_search_clause {
    {-search_id}
    {-party_id "party_id"}
    {-not:boolean}
} {
} {
    set query "
    select parties.party_id
      from parties left join cr_items on (parties.party_id = cr_items.item_id) left join cr_revisions on (cr_items.latest_revision = cr_revisions.revision_id ),
           group_distinct_member_map
     where parties.party_id = group_distinct_member_map.member_id
       and group_distinct_member_map.group_id = '-2'
    [contact::search_clause -and -search_id $search_id -query "" -party_id "parties.party_id" -revision_id "revision_id"]
    "
    if { [exists_and_not_null query] } {
        set result ${party_id}
        if { $not_p } {
            append result " not"
        }
        append result " in ( $query )"
    } else {
        set result ""
    } 
    return $result
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


ad_proc -public contact::search_pretty {
    {-search_id}
    {-format "text/html"}
} {
    Get the search in human readable format. Cached
} {
    return [util_memoize [list ::contact::search_pretty_not_cached -search_id $search_id -format $format]]
}


ad_proc -public contact::search_pretty_not_cached {
    {-search_id}
    {-format "text/html"}
} {
    Get the search in human readable format
} {
    set conditions [list]
    db_foreach selectqueries {
        select type, var_list from contact_search_conditions where search_id = :search_id
    } {
        lappend conditions [contacts::search::condition_type -type $type -request pretty -var_list $var_list]
    }

    if { [llength $conditions] > 0 } {

	contact::search::get -search_id $search_id -array "search_info"

	if { $search_info(object_type) == "person" } {
	    set object_type [_ contacts.people]
	} elseif { $search_info(object_type) == "organization" } {
	    set object_type [_ contacts.organizations]
	} else {
	    set object_type [_ contacts.people_or_organizations]
	}

        set results "[_ contacts.Search_for_all_object_type_where]\n"

	if { $search_info(all_or_any) == "all" } {
	    append results [join $conditions "\n[_ contacts.and] "]
	} else {
	    append results [join $conditions "\n[_ contacts.or] "]
	}

	if { $format == "text/html" } { 
	    set results [ad_enhanced_text_to_html $results]
	} else {
	    set results [ad_enhanced_text_to_plain_text $results]
	}

	return $results
    } else {
	return {}
    }
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
            lappend where_clauses [contacts::search::condition_type -type $type -request sql -var_list $var_list -revision_id $revision_id -party_id $party_id]
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

