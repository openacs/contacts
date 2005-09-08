#packages/contacts/www/admin/ext-search-options.tcl
ad_page_contract {
    UI to add edit or delete options for extended search.
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Network www.viaro.net
    @creation-date 2005-09-08
} {
    extend_id:optional
    {edit_p "f"}
    {delete_p "f"}
    {orderby "var_name,asc"}
}

set page_title [_ contacts.Extended_search_opt]
set context [list [_ contacts.Extended_search_opt]]

if { $delete_p } {
    contact::extend::delete -extend_id $extend_id
    ad_returnredirect -message "[_ contacts.ext_del_message]" "ext-search-options"
}

ad_form -name "add_option" -form {
    extend_id:key(contact_extend_search_seq)
}
if { $edit_p } {
    ad_form -extend -name "add_option" -form {
	{var_name:text(text)
	    {label "[_ contacts.Var_name]:"}
	    {help_text "[_ contacts.var_name_help]"}
	    {mode display }
	}
    }
} else {
    ad_form -extend -name "add_option" -form {
	{var_name:text(text)
	    {label "[_ contacts.Var_name]:"}
	    {help_text "[_ contacts.var_name_help]"}
	}
    }
}

ad_form  -extend -name "add_option" -form {
    {pretty_name:text(text)
	{label "[_ contacts.Pretty_name]:"}
	{help_text "[_ contacts.pretty_name_help]"}
    }
    {subquery:text(textarea),nospell
	{label "[_ contacts.Subquery]:"}
	{html {cols 40 rows 4}}
	{help_text "[_ contacts.subquery_help]"}
    }
    {description:text(textarea),optional,nospell
	{label "[_ contacts.Description]"}
	{html {cols 40 rows 2}}
	{help_text "[_ contacts.description_help]"}
    }
}

if { !$edit_p } {
    ad_form  -extend -name "add_option" -validate {
	{var_name
	    {![contact::extend::var_name_check -var_name $var_name]}
	    "[_ contacts.this_var_name]"
	}
    }
}

ad_form  -extend -name "add_option" -new_data {
    contact::extend::new \
	-extend_id $extend_id \
	-var_name $var_name \
	-pretty_name $pretty_name \
	-subquery $subquery \
	-description $description

} -select_query {
    select * from contact_extend_options where extend_id = :extend_id
} -edit_data {
    contact::extend::update \
	-extend_id $extend_id \
	-var_name $var_name \
	-pretty_name $pretty_name \
	-subquery $subquery \
	-description $description
} -after_submit {
    ad_returnredirect "ext-search-options"
}

set edit_url "ext-search-options?extend_id=@ext_options.extend_id@&edit_p=t"
set delete_url "ext-search-options?extend_id=@ext_options.extend_id@&delete_p=t"

template::list::create \
    -name ext_options \
    -multirow ext_options \
    -elements {
	action_buttons {
	    display_template {
		<a href="$edit_url"><img src="/resources/Edit16.gif" border="0"></a>
		<a href="$delete_url"><img src="/resources/Delete16.gif" border="0"></a>
	    }
	    html { width 5% }
	}
	var_name {
	    label "[_ contacts.Var_name]"
	    html { width 10% }
	}
	pretty_name {
	    label "[_ contacts.Pretty_name]"
	    html { width 10% }
	}
	subquery {
	    label "[_ contacts.Subquery]"
	    html { width 45% }
	}
	description {
	    label "[_ contacts.Description]"
	    html { width 25% }
	}
    } -orderby {
	var_name {
	    label "[_ contacts.Var_name]"
	    orderby_asc "var_name asc"
	    orderby_desc "var_name desc"
	}
	pretty_name {
	    label "[_ contacts.Pretty_name]"
	    orderby_asc "pretty_name asc"
	    orderby_desc "pretty_name desc"
	}
    }

db_multirow ext_options ext_options " "
