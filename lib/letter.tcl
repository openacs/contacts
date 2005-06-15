# packages/contacts/lib/email.tcl
# Template for email inclusion
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-06-14
# @arch-tag: 48fe00a8-a527-4848-b5de-0f76dfb60291
# @cvs-id $Id$

foreach required_param {} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

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
	if {[exists_and_not_null include_signature]} {

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
	}
    }
}

