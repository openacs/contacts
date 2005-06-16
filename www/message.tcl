ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {party_id:integer,multiple,optional}
    {party_ids:optional}
    {message_id:integer,optional}
    {message_type ""}
    {message:optional}
    {return_url "./"}
    {object_id:integer,multiple,optional}
    {file_ids ""}
    {subject ""}
    {content ""}
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
set parties_new [list]
foreach party_id $party_ids {
    
    # Check if the party has a valid e-mail address
    if {![empty_string_p [cc_email_from_party $party_id]]} {
	lappend recipients "<a href=\"[contact::url -party_id $party_id]\">[contact::name -party_id $party_id]</a>"
	lappend parties_new $party_id
    }
}

set party_ids $parties_new

set recipients [join $recipients ", "]

if {[exists_and_not_null object_id]} {
    foreach object $object_id {
	if {[fs::folder_p -object_id $object]} {
	    db_foreach files "select r.revision_id
	    from cr_revisions r, cr_items i
	    where r.item_id = i.item_id and i.parent_id = :object" {
		lappend file_list $revision_id
	    }
	} else {
	    lappend file_list $object
	}
    }
}

if {[exists_and_not_null file_list]} {
    set file_ids [join $file_list ","]
}

set form_elements {
    message_id:key
    file_ids:text(hidden)
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
    set title [_ contacts.create_$message_type]
}
set context [list $title]

if { [string is false [exists_and_not_null message]] } {
    append form_elements {
	{message:text(select) {label "[_ contacts.Message]"} {options {{{-- Create New Message --} new}}}}
    }
    set edit_buttons [list [list "[_ contacts.Next]" create]]

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
	}
}


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
