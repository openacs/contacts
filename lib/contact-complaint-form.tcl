

if { ![info exist customer_id] || ![info exist supplier_id] } {
    set user_options [list]
    db_foreach get_users { } {
	lappend user_options [list $fullname $user_id]
    }
}

if { ![info exist return_url] } {
    set return_url [get_referrer]
}


ad_form -name complaint_form -form {
    complaint_id:key
    {title:text(text)
	{label "Title:"}
    }
    {return_url:text(hidden)
	{value $return_url}
    }
}

if { ![info exist customer_id] } {
    ad_form -extend -name complaint_form -form {
	{customer_id:text(select)
	    {label "Customer:"}
	    {options $user_options}
	}
    }
} else {
    acs_user::get -user_id $customer_id -array customer_info
    ad_form -extend -name complaint_form -form {
	{customer_id:text(hidden)
	    {value $customer_id}
	}
	{customer:text(inform),optional
	    {label "Customer:"}
	    {value "$customer_info(first_names) $customer_info(last_name)"}
	}
    }
}

if { ![info exist supplier_id]} {
    ad_form -extend -name complaint_form -form {
	{supplier_id:text(select)
	    {label "Supplier:"}
	    {options $user_options}
	}
    }
} else {
    acs_user::get -user_id $supplier_id -array supplier_info
    ad_form -extend -name complaint_form -form {
	{supplier_id:text(hidden)
	    {value $supplier_id}
	}
	{supplier:text(inform),optional
	    {label "Supplier:"}
	    {value "$supplier_info(first_names) $supplier_info(last_name)"}
	}
    }
}

ad_form -extend -name complaint_form -form {
    {turnover:text(text)
	{label "Turnover:"}
	{html {size 10}}
    }
    {percent:text(text)
	{label "Percent:"}
	{html {size 2}}
	{after_html "%"}
    }
}

if { ![info exist project_id] } {
    set project_options [list]
    db_foreach get_projects { } {
	set project_name [pm::project::name -project_item_id $project_item_id]
	lappend project_options [list $project_name $project_item_id]
    }
    ad_form -extend -name complaint_form -form {
	{object_id:text(select)
	    {label "Project:"}
	    {options $project_options}
	}
    }
} else {
    ad_form -extend -name complaint_form -form {
	{object_id:text(hidden)
	    {value $object_id}
	}
	{project:text(inform)
	    {label "Object:"}
	    {value [pm::project::name -project_item_id $object_id]}
	}
    }
}

ad_form -extend -name complaint_form -form {
    {paid:text(text)
	{label "Paid:"}
	{html {size 10}}
    }
    {description:text(textarea)
	{label "Description:"}
	{html {rows 10 cols 30}}
    }
} -new_data {
  
    contact::complaint::new \
	-customer_id $customer_id \
	-title $title \
	-turnover $turnover \
	-percent $percent \
	-description $description \
	-supplier_id $supplier_id \
	-paid $paid \
	-object_id $object_id

} -edit_data {
    
    contact::complaint::new \
	-complaint_id $complaint_id \
	-customer_id $customer_id \
	-title $title \
	-turnover $turnover \
	-percent $percent \
	-description $description \
	-supplier_id $supplier_id \
	-paid $paid \
	-object_id $object_id

} -edit_request {

    db_1row get_revision_info { }

} -after_submit {
    ad_returnredirect $return_url
}

