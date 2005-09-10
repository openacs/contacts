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
foreach optional_param {return_url file_ids} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}


set form_elements {
    message_id:key
    party_ids:text(hidden)
    return_url:text(hidden)
    title:text(hidden),optional
}

if { [exists_and_not_null file_ids] } {
    append form_elements {
        file_ids:text(inform)
    }
}

append form_elements {
    {message_type:text(hidden) {value "email"}}
    {to:text(inform),optional {label "[_ contacts.Recipients]"} {value $recipients}}
}


append form_elements {
    {subject:text(text)
	{label "[_ contacts.Subject]"}
	{html {size 55}}
    }
    {content:text(textarea)
	{label "[_ contacts.Message]"}
	{html {cols 55 rows 18}}
	{help_text {[_ contacts.lt_remember_that_you_can]}}
    }

}

if { [parameter::get -boolean -parameter "EmailAttachmentsAllowed" -default "1"] } {
    append form_elements {
	{upload_file:file(file),optional
	    {label "[_ contacts.Upload_File]"}
	}
    }
}

ad_form -action message \
    -html {enctype multipart/form-data} \
    -name email \
    -cancel_label "[_ contacts.Cancel]" \
    -cancel_url $return_url \
    -edit_buttons [list [list [_ contacts.Send] send]] \
    -form $form_elements \
    -on_request {
    } -new_request {
	if {[exists_and_not_null folder_id]} {
	    callback contacts::email_subject -folder_id $folder_id
	}
 	if {[exists_and_not_null item_id]} {
	    contact::message::get -item_id $item_id -array message_info
	    set subject $message_info(description)
	    set content [ad_html_text_convert \
			     -to "text/plain" \
			     -from $message_info(content_format) \
			     -- $message_info(content) \
			    ]
	    set title $message_info(title)
	}
 	if {[exists_and_not_null signature_id]} {
	    set signature [contact::signature::get -signature_id $signature_id]
#	    set signature [ad_convert_to_html -- "$signature"]
	    if { [exists_and_not_null signature] } {
		append content "\n\n"
		append content $signature
	    }
	}
    } -edit_request {
    } -on_submit {
	set user_id [ad_conn user_id]
	set from [contact::name -party_id $user_id]
	set from_addr [contact::email -party_id $user_id]
	template::multirow create messages message_type to_addr subject content party_id title to

	# Insert the uploaded file linked under the package_id
	if { [parameter::get -boolean -parameter "EmailAttachmentsAllowed" -default "1"] } {
	    set filename [template::util::file::get_property filename $upload_file]
	} else {
	    set filename ""
	}
	set package_id [ad_conn package_id]

	if {$filename != "" } {
	    set tmp_filename [template::util::file::get_property tmp_filename $upload_file]
	    set mime_type [template::util::file::get_property mime_type $upload_file]
	    set tmp_size [file size $tmp_filename]
	    set extension [contact::util::get_file_extension \
			       -filename $filename]
	    if {![exists_and_not_null title]} {
		regsub -all ".${extension}\$" $filename "" title
	    }
	    set filename [contact::util::generate_filename \
			      -title $title \
			      -extension $extension \
			      -party_id $party_id \
			     ]
	    
	    set revision_id [cr_import_content \
				 -storage_type "file" \
				 -title $title \
				 $package_id \
				 $tmp_filename \
				 $tmp_size \
				 $mime_type \
				 $filename \
				]

	    if {[exists_and_not_null file_ids]} {
		append file_ids ",$revision_id"
	    } else {
		set file_ids $revision_id
	    }

	    content::item::set_live_revision -revision_id $revision_id
	}

	foreach party_id $party_ids {
	    set name [contact::name -party_id $party_id]
	    set first_names [lindex $name 0]
	    set last_name [lindex $name 1]
	    set date [lc_time_fmt [dt_sysdate] "%q"]
	    set to $name
	    set to_addr [contact::email -party_id $party_id]
	    if {[empty_string_p $to_addr]} {
		ad_return_error [_ contacts.Error] [_ contacts.lt_there_was_an_error_processing_this_request]
		break
	    }
	    set values [list]
	    foreach element [list first_names last_name name date] {
		lappend values [list "{$element}" [set $element]]
	    }
	    template::multirow append messages $message_type $to_addr [contact::message::interpolate -text $subject -values $values] [contact::message::interpolate -text $content -values $values] $party_id $title $to

	    # Link the file to all parties
	    if {[exists_and_not_null revision_id]} {
		application_data_link::new -this_object_id $revision_id -target_object_id $party_id $to
	    }
	}
	
	set recipients [list]
	template::multirow foreach messages {
	    if {[exists_and_not_null file_ids]} {
		acs_mail_lite::complex_send -to_addr $to_addr -from_addr "$from_addr" -subject "$subject" -body "$content" -package_id $package_id -file_ids $file_ids
	    } else {
		acs_mail_lite::send -to_addr $to_addr -from_addr "$from_addr" -subject "$subject" -body "$content" -package_id $package_id
	    }
	    
	    contact::message::log \
		-message_type "email" \
		-sender_id $user_id \
		-recipient_id $party_id \
		-title $title \
		-description $subject \
		-content $content \
		-content_format "text/plain"

	    lappend recipients "<a href=\"[contact::url -party_id $party_id]\">$to</a>"
	}
	set recipients [join $recipients ", "]
	util_user_message -html -message [_ contacts.Your_message_was_sent_to_-recipients-]

    } -after_submit {
	ad_returnredirect $return_url
	ad_script_abort
    }

