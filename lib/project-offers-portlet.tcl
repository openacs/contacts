# Portlet for displaying all offer-item lists of projects that have the status Open

foreach optional_param {status_id} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set portlet_layout [parameter::get -parameter "DefaultPortletLayout"]