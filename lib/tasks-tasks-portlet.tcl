foreach optional_param {party_id query search_id tasks_interval page page_size page_flush_p tasks_orderby} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set portlet_layout [parameter::get -parameter "DefaultPortletLayout"]
set row_list {checkbox {} deleted_p {} priority {} title {} process_title {} date {} creation_user {}}
set package_id [apm_package_id_from_key tasks]
