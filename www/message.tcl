ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {party_id:integer,multiple,optional}
    {party_ids:optional}
    {message_id:integer,optional}
    {message_type:optional}
    {message:optional}
    {return_url "./"}
} -validate {
    valid_message_type -requires {message_type} {
	if { [lsearch [list email letter label] $message_type] < 0 } {
	    ad_complain "[_ contacts.lt_Your_provided_an_inva]"
	}
    }
    valid_party_submission {
	if { ![exists_and_not_null party_id] && ![exists_and_not_null party_ids] } { 
	    ad_complain "[_ contacts.lt_Your_need_to_provide_]"
	}
    }
}
if { [exists_and_not_null party_id] } {
    set party_ids [list]
    foreach party_id $party_id {
	lappend party_ids $party_id
    }
}

set party_count [llength $party_ids]


set title "[_ contacts.Messages]"
set user_id [ad_conn user_id]
set context [list $title]

set recipients [list]
foreach party_id $party_ids {
    lappend recipients "<a href=\"[contact::url -party_id $party_id]\">[contact::name -party_id $party_id]</a>"
}
set recipients [join $recipients ", "]

set form_elements {
    message_id:key
    party_ids:text(hidden)
    return_url:text(hidden)
    {to:text(inform),optional {label "[_ contacts.Recipients]"} {value $recipients}}
}


if { [string is false [exists_and_not_null message_type]] } {
    append form_elements {
	{message_type:text(select) {label "[_ contacts.Type]"} {options {{Email email} {Letter letter} {Label label}}}}
    }
    set title [_ contacts.create_a_message]
} else {
    append form_elements {
	{message_type:text(hidden)}
    }
    set title [_ contacts.create_$message_type]
}
set context [list $title]

if { [string is false [exists_and_not_null message]] } {
    append form_elements {
	{message:text(select) {label "[_ contacts.Message]"} {options {{{-- Create New Message --} new}}}}
    }
    set edit_buttons [list [list "[_ contacts.Next]" create]]
} else {
    append form_elements {
	{message:text(hidden)}
    }
    if { $message_type == "email" } {
	append form_elements {
	    {subject:text(text),optional
		{label "[_ contacts.Subject]"}
		{html {size 55}}
	    }
	    {content:text(textarea),optional
		{label "[_ contacts.Message]"}
		{html {cols 55 rows 18}}
		{help_text {remember that you can use <a href="message-help">mail merge substitutions</a>. the most common wildcards are \{name\} \{first_names\}, \{last_name\}, \{home_address\} and \{date\}}}
	    }
	}
    } elseif { $message_type == "letter" } {
	set todays_date [lc_time_fmt [dt_sysdate] "%q"]
	append form_elements {
            {paper_type:text(select),optional
		{label "[_ contacts.Paper_Type]"}
		{options {{{Letter} letter} {Letterhead letterhead}}}
	    }
            {date:text(inform),optional
		{label "[_ contacts.Date]"}
		{value $todays_date}
	    }
            {address:text(inform),optional
		{label "[_ contacts.Address]"}
		{value "{name}<br>{mailing_address}"}
		{help_text {The recipeints name and mailing address will automatically be included so that they work with window envelopes}}
	    }
	    {content:richtext(richtext),optional
		{label "[_ contacts.Message]"}
		{html {cols 70 rows 24}}
		{help_text {[_ contacts.lt_remember_that_you_can]}}
	    }
	}
    } else {
	error "[_ contacts.lt_labels_are_not_implem]"
    }
    set sig_options "{{[_ contacts.lt_--_no_not_include_a_s]} \"none\"} [db_list_of_lists select_sigs {select title, signature from contact_signatures where party_id = :user_id}]"
    append form_elements {
        {include_signature:text(select),optional {label "[_ contacts.Signature]"} {options $sig_options} {help_text {you may modify <a href="settings">[_ contacts.your_signatures]</a>}}}
	{save_as:text(text),optional {label "[_ contacts.Save_Message_As]"} {html {size 35}}}
    }
    append form_elements 
    set edit_buttons [list [list "[_ contacts.Preview]" create]]
}





ad_form -action message \
    -name message \
    -cancel_label "[_ contacts.Cancel]" \
    -cancel_url $return_url \
    -edit_buttons $edit_buttons \
    -form $form_elements \
    -on_request {
    } -new_request {
    } -edit_request {
    } -on_submit {
	if { [exists_and_not_null include_signature] } {
	    # we need to do validation
	    switch $message_type {
		letter {
		    set content_raw [string trim \
					 [ad_html_text_convert \
					      -from [template::util::richtext::get_property format $content] \
					      -to "text/plain" \
					      [template::util::richtext::get_property content $content] \
					 ] \
				    ]
		    if { $content_raw == "" } {
			template::element set_error message content "[_ contacts.Message_is_required]"
		    }
		}
		email {
		    if { [string trim $subject] == "" } {
			template::element set_error message subject "[_ contacts.Subject_is_required]"
		    }
		    if { [string trim $content] == "" } {
			template::element set_error message content "[_ contacts.Message_is_required]"
		    }
		} 
	    }
	}
    }




if { [string is false [::template::form::is_valid message]] } {
    ad_return_template message
} else {
    if { [exists_and_not_null include_signature] } {
	# we had good input
	switch $message_type {
	    letter {
		set content [ad_html_text_convert -from [template::util::richtext::get_property format $content] -to "text/html" [template::util::richtext::get_property content $content]]
		set subject ""
	    }
	    email {
		set this_subject [string trim $subject]
	    } 
	}
	set from [contact::name -party_id [ad_conn user_id]]
	template::multirow create messages message_type to subject content
	foreach party_id $party_ids {
	    set name [contact::name -party_id $party_id]
	    set first_names [lindex $name 0]
	    set last_name [lindex $name 1]
	    set date [lc_time_fmt [dt_sysdate] "%q"]
	    set to $name
	    set values [list]
	    foreach element [list first_names last_name name date] {
		lappend values [list "{$element}" [set $element]]
	    }
	    template::multirow append messages $message_type $to [contact::util::interpolate -text $subject -values $values] [contact::util::interpolate -text $content -values $values]
	}

	ad_return_template message-messages
    } else {
	ad_return_template message
    }
}
