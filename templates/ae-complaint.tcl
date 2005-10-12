set page_title "[_ contacts.Edit_complaint]"

set context [list $page_title]

if { [empty_string_p $return_url] } {
    set return_url [get_referrer]
}
