# filter_p:     if set to 1, the filter selection will be displayed
# customer_id:  customer_id for which we want to see the complaints
# supplier_id:  supplier_id for which we want to see the complaints
# elements:     list of elements to be displayed

set required_param_list [list]
set optional_param_list [list filter_p elements]
set optional_unset_list [list customer_id supplier_id]

foreach required_param $required_param_list {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}

foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
	if {[empty_string_p [set $optional_unset]]} {
	    unset $optional_unset
	}
    }
}

# Here we specified which elements we will show
set rows_list [list]
if {![exists_and_not_null elements] } {
    set rows_list [list title {} customer {} supplier {} turnover {} percent {} state {} complaint_object_id {} description {}]
} else {
    foreach element $elements {
	lappend rows_list [list $element]
	lappend rows_list [list]
    }
}

# This are the elements of the template::list
set edit_url "/contacts/add-edit-complaint?complaint_id=@complaint.complaint_id@&customer_id=@complaint.customer_id@"
set elements_list [list \
		  title [list label [_ contacts.Title_1] \
			     display_template \
			     "<a href=\"$edit_url\"><img border=0 src=\"/resources/Edit16.gif\"></a>
                              <a href=\"${edit_url}&mode=display\">@complaint.title@</a>"] \
		  customer [list label [_ contacts.Customer] \
			       display_template \
			       "<a href=\"@complaint.customer_url@\">@complaint.customer@</a>"]\
		  supplier [list label [_ contacts.Supplier] \
			       display_template \
			       "<a href=\"@complaint.supplier_url@\">@complaint.supplier@</a>"]\
		  turnover [list label [_ contacts.Turnover]]\
		  percent [list label [_ contacts.Percent]]\
		  state [list label "[_ contacts.Status]:"]\
		  complaint_object_id [list label [_ contacts.Object_id]]\
		  description [list label [_ contacts.Description]]\
		 ]


set customer_list [list]
set supplier_list [list]

db_foreach get_users { } {
    if { [string equal [lsearch $customer_list [list $customer $c_id]] "-1"] } {
	lappend customer_list [list "$customer" $c_id]
    } 
    if { [string equal [lsearch $supplier_list [list $supplier $s_id]] "-1"] } {
	lappend supplier_list [list "$supplier" $s_id]
    }
}

template::list::create \
    -name complaint \
    -multirow complaint \
    -key complaint_id \
    -selected_format normal \
    -filters {
	customer_id {
	    label "[_ contacts.Customer]"
 	    values { $customer_list }
	    where_clause {
		customer_id = :customer_id
	    }
	}
	supplier_id {
	    label "[_ contacts.Supplier]"
 	    values { $supplier_list }
	    where_clause {
		supplier_id = :supplier_id
	    }
	}
    } \
    -elements $elements_list \
    -formats {
        normal {
            label "Table"
            layout table
            row $rows_list
        }
    }


db_multirow -extend { customer customer_url supplier supplier_url } complaint get_complaints { } {
    set customer "[contact::name -party_id $customer_id]"
    set supplier "[contact::name -party_id $supplier_id]"
    set customer_url "/contacts/$customer_id"
    set supplier_url "/contacts/$supplier_id"
}
