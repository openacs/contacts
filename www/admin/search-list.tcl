ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    orderby:optional
    {owner_id:optional}
    {format "normal"}
} -validate {
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
if { ![exists_and_not_null owner_id] } {
    set owner_id $user_id
}

template::list::create \
    -name "searches" \
    -key search_id \
    -multirow "searches" \
    -row_pretty_plural "[_ contacts.searches]" \
    -selected_format $format \
    -key search_id \
    -elements {
        title {
	    label {#contacts.Title#}
	    display_col title
            link_url_eval "../search?search_id=$search_id"
	}
        query {
	    label {#contacts.Query#}
            display_col query;noquote
        }
        results {
	    label {#contacts.Results#}
            display_col results
            link_url_eval $search_url
        }
        action {
            label ""
            display_template {
                <a href="ext-search-options?search_id=@searches.search_id@" class="button">Default Extend Options</a>
                <a href="attribute-list?search_id=@searches.search_id@" class="button">Default Attributes</a>
            }
        }
    } -orderby {
    } -formats {
	normal {
	    label "[_ contacts.Table]"
	    layout table
	    row {
	    }
	}
	csv {
	    label "CSV"
	    output csv
	    row {
                title {}
                results {}
	    }
	}
    }


set return_url [export_vars -base searches -url {owner_id}]
set search_ids [list]
set admin_p [permission::permission_p -object_id $package_id -privilege "admin"]

db_multirow -extend {query search_url make_public_url delete_url copy_url results} -unclobber searches select_searches {} {
    set search_url [export_vars -base ../ -url {search_id}]

    lappend search_ids $search_id
}

# Since contact::search::results_count can if not cached required two db queries
# when this is included in the multirow code block above it can hang due to a lack
# of db pools. So it has to be done here.
template::multirow foreach searches {
    set results [contact::search::results_count -search_id $search_id]
    set query   [contact::search_pretty -search_id $search_id]
}

list::write_output -name searches
