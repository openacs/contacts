ad_page_contract {


    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

} {
    party_id:integer
    view_id:integer
}


permission::require_permission -object_id [ad_conn package_id] -privilege "read"

contacts::view::get $view_id 

if { [exists_and_not_null privilege_required] && [exists_and_not_null privilege_object_id] } {
    permission::require_permission -object_id "$privilege_object_id" -privilege "$privilege_required"
}

# NOTE, since this page is called on by the index.vuh file the party_id is already passed to the included page
rp_form_put return_url "[apm_package_url_from_id [ad_conn package_id]]view/$party_id\-$view_id"

set title "[contact::name $party_id]"
set context [list $title]

set object_type [contact::get::object_type $party_id]
set selected_view_id $view_id
set user_id [ad_conn user_id]

db_multirow -extend { name url selected_p } views select_views {} {
    if { $selected_view_id == $view_id } {
        set selected_p 1
    } else {
        set selected_p 0
    }
    set name [contacts::view::get::name $view_id]
    set url "$party_id\-$view_id"
}




ad_return_template
