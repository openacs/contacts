ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    orderby:optional
} -validate {
}

set title "My Searches"
set context [list [list "search" "Advanced Search"] $title]

template::list::create \
    -name "searches" \
    -multirow "searches" \
    -row_pretty_plural "searches" \
    -selected_format "normal" \
    -key party_id \
    -actions [list \
		  "Add Search" "search" "Add Search"] \
    -elements {
        object_type {
            label {Type}
            display_col object_type
        }
        title {
	    label {Title}
	    display_col title
            link_url_eval "search?search_id=$search_id"
	}
        query {
	    label {Query}
            display_col query;noquote
        }
    } -filters {
    } -orderby {
    } -formats {
	normal {
	    label "Table"
	    layout table
	    row {
	    }
	}
    }


#multirow create searches search_id object_type title query

set owner_id [ad_conn user_id]

db_multirow -extend {query} -unclobber searches get_searches {
(    select search_id, title, upper(title) as order_title, all_or_any, object_type
       from contact_searches
      where owner_id = :owner_id
        and title is not null
) union (
     select search_id, 'Search \#' || to_char(search_id,'FM9999999999999999999') || ' on ' || to_char(creation_date,'Mon FMDD') as title, 'zzzzzzzzzzz' as order_title, all_or_any, contact_searches.object_type
       from contact_searches, acs_objects
      where owner_id = :owner_id
        and search_id = object_id
        and contact_searches.title is null
      limit 10
)
      order by order_title
} {
    db_foreach selectqueries {
        select type as query_type, var_list as query_var_list from contact_search_conditions where search_id = :search_id
    } {
        if { [exists_and_not_null query] } {
            append query "<br>"
        }
        append query "[contact::search::translate -type $query_type -var_list $query_var_list -to pretty -party_id "party_id" -revision_id "cr.revisions.revision_id"]</li>"
    }
}

