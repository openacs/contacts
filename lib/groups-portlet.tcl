foreach optional_param {hide_form_p} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set portlet_layout [parameter::get -parameter "DefaultPortletLayout"]

set groups_url "[site_node::get_package_url -package_key "contacts"]${party_id}/groups"