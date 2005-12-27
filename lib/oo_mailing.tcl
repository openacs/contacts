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

if {[exists_and_not_null header_id]} {
    contact::message::get -item_id $header_id -array header_info
    set header [ad_html_text_convert \
		     -to "text/html" \
		     -from $header_info(content_format) \
		     -- $header_info(content) \
		    ]
} else {
    set header "<div class=\"mailing-address\">{name}<br />
{mailing_address}</div>"
}

if {[exists_and_not_null footer_id]} {
    contact::message::get -item_id $footer_id -array footer_info
    set footer [ad_html_text_convert \
		     -to "text/html" \
		     -from $footer_info(content_format) \
		     -- $footer_info(content) \
		    ]
} else {
    set footer ""
}


    
set date [split [dt_sysdate] "-"]
append form_elements {
    message_id:key
    party_ids:text(hidden)
    return_url:text(hidden)
    title:text(hidden),optional
    {message_type:text(hidden) {value "oo_mailing"}}
    {recipients:text(inform)
	{label "[_ contacts.Recipients]"}
    }
    {date:date(date)
	{label "[_ contacts.Date]"}
    }
    {spoiler:text(text),optional
        {label "[_ contacts.Spoiler]"} 
        {help_text "[_ contacts.Spoiler_help_text]"}
        {html {size 45 maxlength 1000}}
    }
    {content:richtext(richtext)
	{label "[_ contacts.Message]"}
	{html {cols 70 rows 24}}
	{help_text {[_ contacts.lt_remember_that_you_can]}}
    }
    {ps:text(text),optional
        {label "[_ contacts.PS]"} 
        {help_text "[_ contacts.PS_help_text]"}
        {html {size 45 maxlength 1000}}
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
 	if {[exists_and_not_null item_id]} {
	    contact::message::get -item_id $item_id -array message_info
	    set subject $message_info(description)
	    set content [ad_html_text_convert \
			     -to "text/html" \
			     -from $message_info(content_format) \
			     -- $message_info(content) \
			    ]
	    set content [list $content $message_info(content_format)]
	    set title $message_info(title)
            set ps $message_info(ps)
            set spoiler $message_info(spoiler)
	} else {
	    if { [exists_and_not_null signature] } {
		set content [list $signature "text/html"]
	    }
	}
	set paper_type "letterhead"
    } -edit_request {
    } -on_submit {
        # Make sure the content actually exists
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

        # Now parse the content for openoffice
	set content_format [template::util::richtext::get_property format $content]
	set content [contact::oo::convert -content [string trim [template::util::richtext::get_property content $content]]]

        # Retrieve information about the user so it can be used in the template
	set user_id [ad_conn user_id]
        if {![contact::employee::get -employee_id $user_id -array user_info]} {
            ad_return_error $user_id "User is not an employee"
        }

        set return ""
	foreach party_id $party_ids {
            # get the user information
            if {[contact::employee::get -employee_id $party_id -array employee]} {
                set date [lc_time_fmt [join [template::util::date::get_property linear_date_no_time $date] "-"] "%q" "$employee(locale)"]
                set regards [lang::message::lookup $employee(locale) contacts.with_best_regards]
            } else {
                ad_return_error [_ contacts.Error] [_ contacts.lt_there_was_an_error_processing_this_request]
                break
            }

            set file [open "/web/wieners/vorlage.xml"]
            fconfigure $file -translation binary
            set template_content [read $file]
            close $file

            eval [template::adp_compile -string $template_content]
            append return $__adp_output

#	    contact::message::log \
#		-message_type "letter" \
#		-sender_id $user_id \
#		-recipient_id $party_id \
#		-title $title \
#		-description "" \
#		-content $letter \
#		-content_format "text/html"


	}
	

        set return [contact::oo::change_content2 -oo_filename "vorlage.odt" -oo_path "/web/" -content $return]
	
	# onLoad=\"window.print()\"
	ns_return 200 text/html "
<html>
<head>
<title>[_ contacts.Print_Letter]</title>
</head>

$return

</body>
</html>
"
        ad_script_abort
    }

