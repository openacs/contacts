# packages/contacts/lib/email.tcl
# Template for email inclusion
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-06-14
# @arch-tag: 48fe00a8-a527-4848-b5de-0f76dfb60291
# @cvs-id $Id$

foreach required_param {party_ids recipients} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {return_url} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set date [split [dt_sysdate] "-"]
append form_elements {
    message_id:key
    party_ids:text(hidden)
    return_url:text(hidden)
    title:text(hidden),optional
    {message_type:text(hidden) {value "letter"}}
    {paper_type:text(select),optional
	{label "[_ contacts.Paper_Type]"}
	{options {{"[_ contacts.Letter]" letter} {"[_ contacts.Letterhead]" letterhead}}}
    }
    {recipients:text(inform)
	{label "[_ contacts.Recipients]"}
    }
    {date:date(date)
	{label "[_ contacts.Date]"}
    }
    {address:text(inform),optional
	{label "[_ contacts.Address]"}
	{value "{name}<br>{mailing_address}"}
	{help_text {The recipeints name and mailing address will automatically be included so that they work with window envelopes}}
    }
    {content:richtext(richtext)
	{label "[_ contacts.Message]"}
	{html {cols 70 rows 24}}
	{help_text {[_ contacts.lt_remember_that_you_can]}}
    }
}

ad_form -action message \
    -name letter \
    -cancel_label "[_ contacts.Cancel]" \
    -cancel_url $return_url \
    -edit_buttons [list [list [_ contacts.Print] print]] \
    -form $form_elements \
    -on_request {
    } -new_request {
 	if {[exists_and_not_null signature_id]} {
	    set signature [contact::signature::get -signature_id $signature_id]
	    if { [exists_and_not_null signature] } {
		set signature [ad_html_text_convert \
				   -to "text/html" \
				   -from "text/plain" \
				   -- $signature \
				  ]
		set signature "<p>${signature}</p>"
	    }
	}
 	if {[exists_and_not_null item_id]} {
	    contact::message::get -item_id $item_id -array message_info
	    set subject $message_info(description)
	    set content [ad_html_text_convert \
			     -to "text/html" \
			     -from $message_info(content_format) \
			     -- $message_info(content) \
			    ]
	    if { [exists_and_not_null signature] } {
		append content "\n${signature}"
	    }
	    set content [list $content $message_info(content_format)]
	    set title $message_info(title)
	} else {
	    if { [exists_and_not_null signature] } {
		set content [list $signature "text/html"]
	    }
	}

    } -edit_request {
    } -on_submit {
	set user_id [ad_conn user_id]
	set content_raw [string trim \
			     [ad_html_text_convert \
				  -from [template::util::richtext::get_property format $content] \
				  -to "text/plain" \
				  [template::util::richtext::get_property content $content] \
				 ] \
			    ]
	if {$content_raw == "" } {
	    template::element set_error message content "[_ contacts.Message_is_required]"
	}
	set content_format [template::util::richtext::get_property format $content]
	set content [string trim [template::util::richtext::get_property content $content]]
	set date [lc_time_fmt [join [template::util::date::get_property linear_date_no_time $date] "-"] "%q"]

	set messages [list]
	foreach party_id $party_ids {
	    set name [contact::name -party_id $party_id]
	    set first_names [lindex $name 0]
	    set last_name [lindex $name 1]
	    set mailing_address [contact::message::mailing_address -party_id $party_id -format "text/html"]
	    if {[empty_string_p $mailing_address]} {
		ad_return_error [_ contacts.Error] [_ contacts.lt_there_was_an_error_processing_this_request]
		break
	    }

	    set letter "<div class=\"message\">
<div class=\"date\">$date</div>
<div class=\"mailing-address\">$name<br />
$mailing_address</div>
<div class=\"content\">$content</div>
</div>"

	    set values [list]
	    foreach element [list first_names last_name name] {
		lappend values [list "{$element}" [set $element]]
	    }
	    set letter [contact::message::interpolate -text $letter -values $values]

	    lappend messages $letter

	    contact::message::log \
		-message_type "letter" \
		-sender_id $user_id \
		-recipient_id $party_id \
		-title $title \
		-description "" \
		-content $letter \
		-content_format "text/html"


	}
	


	
	# onLoad=\"window.print()\"
	ns_return 200 text/html "
<html>
<head>
<title>[_ contacts.Print_Letter]</title>
<link rel=\"stylesheet\" type=\"text/css\" href=\"/resources/contacts/contacts-print.css\">
</head>
<body id=\"${paper_type}\">
<div id=\"header\">
<p>[_ contacts.lt_Once_done_printing_-return_url-]</p>
</div>

[join $messages "\n"]

</body>
</html>
"
        ad_script_abort
    }

