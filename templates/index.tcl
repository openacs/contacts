if { [exists_and_not_null add_person] } {
    ad_returnredirect "add/person"
    ad_script_abort
} elseif { [exists_and_not_null add_organization] } {
    ad_returnredirect "add/organization"
    ad_script_abort
}

set aggregated_p 0
if {[exists_and_not_null aggregate_attribute_id] } {
    set aggregated_p 1
} 

set extend_p 0
if { [exists_and_not_null search_id] } {
    set extend_p 1
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

set valid_page_sizes [list 25 50 100 500]
if { ![exists_and_not_null page_size] || [lsearch $valid_page_sizes $page_size] < 0 } {
    set page_size [parameter::get -boolean -parameter "DefaultPageSize" -default "50"]
}

set contacts_total_count [contact::search::results_count -search_id $search_id -query $query]

if { $aggregated_p } {
    set contacts_total_count "<a href=\"?search_id=$search_id\">$contacts_total_count</a>"
}

if { [exists_and_not_null search_id] } {
    contact::search::log -search_id $search_id
}

set public_searches [lang::util::localize_list_of_lists -list [db_list_of_lists public_searches {}]]
set search_options [concat [list [list [_ contacts.All_Contacts] ""]] $public_searches]
set searchcount 1
db_foreach my_recent_searches {} {
    lappend search_options [list "${searchcount}) ${recent_title}" ${recent_search_id}]
    incr searchcount
}

lang::util::localize_list_of_lists -list $search_options



set form_elements {
    {search_id:integer(select),optional {label ""} {options $search_options} {html {onChange "javascript:acs_FormRefresh('search')"}}}
    {query:text(text),optional {label ""} {html {size 20 maxlength 255}}}
    {save:text(submit) {label {[_ contacts.Search]}} {value "go"}}
    {results_count:integer(inform),optional {label "&nbsp;&nbsp;<span style=\"font-size: smaller;\">[_ contacts.Results] $contacts_total_count </span>"}}
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
