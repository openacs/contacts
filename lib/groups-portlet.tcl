foreach optional_param {hide_form_p} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set portlet_layout [parameter::get -parameter "DefaultPortletLayout"]
set package_url [ad_conn package_url]

set groups_url "${package_url}/${party_id}/groups"