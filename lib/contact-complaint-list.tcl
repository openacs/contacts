# filter_p:     if set to 1, the filter selection will be displayed
# customer_id:  customer_id for which we want to see the complaints
# supplier_id:  supplier_id for which we want to see the complaints

set required_param_list [list]
set optional_param_list [list filter_p]
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

set edit_url "/contacts/add-edit-complaint?complaint_id=@complaint.complaint_id@&customer_id=@complaint.customer_id@"
set elements [list \
		  title [list label [_ contacts.Title_1] \
			     display_template \
			     "<a href=\"$edit_url\"><img border=0 src=\"/resources/Edit16.gif\"></a>@complaint.title@"]\
		  customer [list label [_ contacts.Customer]]\
		  supplier [list label [_ contacts.Supplier]]\
		  turnover [list label [_ contacts.Turnover]]\
		  percent [list label [_ contacts.Percent]]\
		  state [list label "[_ contacts.Status]:"]\
		  object_id [list label [_ contacts.Object_id]]\
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
    -elements $elements


db_multirow -extend { customer supplier title description } complaint get_complaints { } {
    set customer "[contact::name -party_id $customer_id]"
    set supplier "[contact::name -party_id $supplier_id]"
    db_1row get_revision_info { }
}
