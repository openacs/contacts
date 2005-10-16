set optional_param_list [list customer_id supplier_id]
foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set portlet_layout [parameter::get -parameter "DefaultPortletLayout"]