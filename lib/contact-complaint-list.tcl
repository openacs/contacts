ad_page_contract {
    Shows a list template with information about contact_complaint_tracking table

    @author Miguel Marin (miguelmarin@viaro.net)
    @author www.viaro.net www.viaro.net
    @creation-date 2005-08-05
} {
    customer_id:optional
    supplier_id:optional
}


set elements [list \
		  title [list label "Title"]\
		  customer [list label "Customer"]\
		  supplier [list label "Supplier"]\
		  turnover [list label "Turnover"]\
		  percent [list label "Percent"]\
		  state [list label "State"]\
		  object_id [list label "Object ID"]\
		  description [list label "Description"]\
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
	    label "Customer"
 	    values { $customer_list }
	    where_clause {
		customer_id = :customer_id
	    }
	}
	supplier_id {
	    label "Supplier"
 	    values { $supplier_list }
	    where_clause {
		supplier_id = :supplier_id
	    }
	}
    } \
    -elements $elements


db_multirow -extend { customer supplier title description } complaint get_complaints { } {
    acs_user::get -user_id $customer_id -array customer_info
    acs_user::get -user_id $supplier_id -array supplier_info
    set customer "$customer_info(first_names) $customer_info(last_name)"
    set supplier "$supplier_info(first_names) $supplier_info(last_name)"
    db_1row get_revision_info { }
}
