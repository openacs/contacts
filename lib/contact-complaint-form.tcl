# customer_id. Party ID of the customer for which the complaint was made.
# supplier_id. Party ID of the supplier who caused the complaint
# project_id. Alternative for the customer_id, if you know the project_id

if { ![info exist return_url] } {
    set return_url [get_referrer]
}


if { ![exists_and_not_null complaint_id] } {
    if { [info exist complaint_id] } {
	unset complaint_id
    }
    set complaint_rev_id ""
} else {
    set complaint_rev_id $complaint_id
}

ad_form -name complaint_form -form {
    complaint_id:key
    {title:text(text)
	{label "[_ contacts.Title_1]"}
        {help_text "[_ contacts.complaint_title_help]"}
    }
    {return_url:text(hidden)
	{value $return_url}
    }
}

set customer_name [contact::name -party_id $customer_id]
ad_form -extend -name complaint_form -form {
    {customer_id:text(hidden)
	{value $customer_id}
    }
    {customer:text(inform),optional
	{label "[_ contacts.Customer]"}
	{value "<a href=\"/contacts/${customer_id}\">$customer_name</a>"}
    }
}

if { ![exists_and_not_null supplier_id]} {

    set user_options [list]
    db_foreach get_users { } {
	lappend user_options [list $fullname $user_id]
    }
    ad_form -extend -name complaint_form -form {
	{supplier_id:text(select)
	    {label "[_ contacts.Supplier]"}
	    {options $user_options}
	}
    }
} else {
    
    set supplier_name [contact::name -party_id $supplier_id]
    ad_form -extend -name complaint_form -form {
	{supplier_id:text(hidden)
	    {value $supplier_id}
	}
	{supplier:text(inform),optional
	    {label "[_ contacts.Supplier]"}
	    {value "$supplier_name"}
	}
    }
}

ad_form -extend -name complaint_form -form {
    {turnover:text(text)
	{label "[_ contacts.Turnover]"}
	{html {size 10}}
        {help_text "[_ contacts.complaint_turnover_help]"}
    }
    {percent:text(text)
	{label "[_ contacts.Percent]"}
	{html {size 2}}
	{after_html "%"}
        {help_text "[_ contacts.complaint_percent_help]"}
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
	    {label "[_ contacts.Project]"}
	    {options $project_options}
	}
    }
} else {
    set object_id $project_id
    ad_form -extend -name complaint_form -form {
	{object_id:text(hidden)
	    {value $object_id}
	}
	{project:text(inform)
	    {label "[_ contacts.Object]"}
	    {value "[pm::project::name -project_item_id $object_id]"}
	}
    }
}

ad_form -extend -name complaint_form -form {
    {paid:text(text)
	{label "[_ contacts.Paid]"}
	{html {size 10}}
        {help_text "[_ contacts.complaint_paid_help]"}

    }
    {status:text(select)
	{label "[_ contacts.Status]"}
	{options { { [_ contacts.open] open } { [_ contacts.valid] valid } { [_ contacts.invalid] invalid } }}
        {help_text "[_ contacts.complaint_status_help]"}

    }
    {description:text(textarea)
	{label "[_ contacts.Description]"}
	{html {rows 10 cols 30}}
        {help_text "[_ contacts.complaint_description_help]"}
    }
} -validate {
    {title
	{ ![contact::complaint::check_name -name $title -complaint_id $complaint_rev_id] }
	"[_ contacts.title_already_present]"
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

