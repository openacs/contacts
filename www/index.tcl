ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {orderby "first_names,asc"}
    {format "normal"}
    {search_id:integer ""}
    {query ""}
    {page:optional}
    {page_size:integer ""}
    {add_person:optional}
    {add_organization:optional}
}

if { [exists_and_not_null add_person] } {
    ad_returnredirect "add/person"
    ad_script_abort
} elseif { [exists_and_not_null add_organization] } {
    ad_returnredirect "add/organization"
    ad_script_abort
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

set valid_page_sizes [list 25 50 100 500]
if { ![exists_and_not_null page_size] || [lsearch $valid_page_sizes $page_size] < 0 } {
    set page_size [parameter::get -boolean -parameter "DefaultPageSize" -default "50"]
}

set contacts_total_count [contact::search::results_count -search_id $search_id -query $query]

if { [exists_and_not_null search_id] } {
    contact::search::log -search_id $search_id
}
set search_options [concat [list [list [_ contacts.All_Contacts] ""]] [db_list_of_lists public_searches {}]]

set searchcount 1
db_foreach my_recent_searches {} {
    lappend search_options [list "${searchcount}) ${recent_title}" ${recent_search_id}]
    incr searchcount
}




set form_elements {
    {search_id:integer(select),optional {label ""} {options $search_options} {html {onChange "javascript:acs_FormRefresh('search')"}}}
    {query:text(text),optional {label ""} {html {size 20 maxlength 255}}}
    {save:text(submit) {label {[_ contacts.Search]}} {value "go"}}
    {results_count:integer(inform),optional {label "&nbsp;&nbsp;<span style=\"font-size: smaller;\">[_ contacts.Results]</span> $contacts_total_count"}}
}

if { [parameter::get -boolean -parameter "ForceSearchBeforeAdd" -default "0"] } {
    if { [exists_and_not_null query] && $search_id == "" } {
	append form_elements {
	    {add_person:text(submit) {label {[_ contacts.Add_Person]}} {value "1"}}
	    {add_organization:text(submit) {label {[_ contacts.Add_Organization]}} {value "1"}}
	}
    }
}

ad_form -name "search" -method "GET" -export {orderby page_size format} -form $form_elements \
    -on_request {
    } -edit_request {
    } -on_refresh {
    } -on_submit {
    } -after_submit {
    }

