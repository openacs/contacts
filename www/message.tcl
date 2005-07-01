ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {party_id:integer,multiple,optional}
    {party_ids:optional}
    {message_type ""}
    {message:optional}
    {return_url "./"}
    {object_id:integer,multiple,optional}
    {file_ids ""}
    {item_id:integer ""}
    {signature_id:integer ""}
} -validate {
    valid_message_type -requires {message_type} {
	if { [lsearch [list email letter] $message_type] < 0 } {
	    ad_complain "[_ contacts.lt_Your_provided_an_inva]"
	}
    }
    valid_party_submission {
	if { ![exists_and_not_null party_id] && ![exists_and_not_null party_ids] } { 
	    ad_complain "[_ contacts.lt_Your_need_to_provide_]"
	}
    }
}
if { [exists_and_not_null message] && ![exists_and_not_null message_type] } {
    set message_type [lindex [split $message "."] 0]
    set item_id [lindex [split $message "."] 1]
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

set recipients  [list]
foreach party_id $party_ids {
    set contact_name   [contact::name -party_id $party_id]
    set contact_url    [contact::url -party_id $party_id]
    set contact_link   "<a href=\"${contact_url}\">${contact_name}</a>"
    set sort_key       [string toupper $contact_name]
    # Check if the party has a valid e-mail address we can send to
    set email_p        [contact::message::email_address_exists_p -party_id $party_id]
    set letter_p       [contact::message::mailing_address_exists_p -party_id $party_id]
    lappend recipients [list $contact_name $party_id $contact_link $email_p $letter_p]
}
set sorted_recipients  [ams::util::sort_list_of_lists -list $recipients]
set recipients         [list]
set invalid_recipients [list]
set party_ids          [list]
set invalid_party_ids  [list]

foreach recipient $sorted_recipients {
    set party_id       [lindex $recipient 1]
    set contact_link   [lindex $recipient 2]
    set email_p        [lindex $recipient 3]
    set letter_p       [lindex $recipient 4]
    if { $message_type == "letter" } {
        if { $letter_p } {
            lappend party_ids $party_id
            lappend recipients $contact_link
        } else {
            lappend invalid_party_ids $party_id
            lappend invalid_recipients $contact_link
        }
    } elseif { $message_type == "email" } {
        if { $email_p } {
            lappend party_ids $party_id
            lappend recipients $contact_link
        } else {
            lappend invalid_party_ids $party_id
            lappend invalid_recipients $contact_link
        }
    } else {
        if { $email_p || $letter_p } {
            lappend party_ids $party_id
            lappend recipients $contact_link
        } else {
            lappend invalid_party_ids $party_id
            lappend invalid_recipients $contact_link
        }
    }
}

set recipients [join $recipients ", "]
set invalid_recipients [join $invalid_recipients ", "]
if { [llength $invalid_recipients] > 0 } {
    switch $message_type {
        letter {
            util_user_message -html -message [_ contacts.lt_You_cannot_send_a_letter_to_invalid_recipients]
        }
        email {
            util_user_message -html -message [_ contacts.lt_You_cannot_send_an_email_to_invalid_recipients]
        }
        default {
            util_user_message -html -message [_ contacts.lt_You_cannot_send_a_message_to_invalid_recipients]
        }
    }
}

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
    file_ids:text(hidden)
    party_ids:text(hidden)
    return_url:text(hidden)
    {to:text(inform),optional {label "[_ contacts.Recipients]"} {value $recipients}}
}


if { [string is false [exists_and_not_null message_type]] } {

    set message_type_options [ams::util::localize_and_sort_list_of_lists \
				  -list [db_list_of_lists get_message_types { select pretty_name, message_type from contact_message_types }] \
				 ]

    set message_options [list]
    foreach op $message_type_options {
	lappend message_options [list "-- [_ contacts.New] [lindex $op 0] --" [lindex $op 1]]
	# set email_text and letter_text and others in the future
	set "[lindex $op 1]_text" [lindex $op 0]
    }

    set public_text [_ contacts.Public]
    set package_id [ad_conn package_id]
    set message_options [concat \
			     $message_options \
			     [db_list_of_lists get_messages {
				 select CASE WHEN owner_id = :package_id THEN :public_text ELSE contact__name(owner_id) END || ' ' || CASE WHEN message_type = 'email' THEN :email_text WHEN message_type = 'letter' THEN :letter_text END || ': ' || title,
				        message_type || '.' || to_char(item_id,'FM9999999999999999999999')
                                   from contact_messages
                                  where owner_id in ( select party_id from parties )
                                     or owner_id = :package_id
                                  order by CASE WHEN owner_id = :package_id THEN '000000000' ELSE upper(contact__name(owner_id)) END, message_type, upper(title)
			     }] \
			    ]

    lappend form_elements [list \
			       message:text(select) \
			       [list label "[_ contacts.Message]"] \
			       [list options $message_options] \
			      ]
    set title [_ contacts.create_a_message]
} else {
    set title [_ contacts.create_$message_type]
}
set context [list $title]

if { [string is false [exists_and_not_null message]] } {
    set signature_list [list [list [_ contacts.--none--] ""]]
    set reset_title $title
    set reset_signature_id $signature_id
    db_foreach signatures "select title, signature_id, default_p
      from contact_signatures
     where party_id = :user_id
     order by default_p, upper(title), upper(signature)" {
         lappend signature_list [list $title $signature_id]
         if { $default_p == "t" } {
             set default_signature_id $signature_id
         }
     }
    set title $reset_title
    set signature_id $reset_signature_id
    append form_elements {
	{signature_id:text(select) 
	    {label "[_ contacts.Signature]"}
	    {options {$signature_list}}
	}
    }
    
}

set edit_buttons [list [list "[_ contacts.Next]" create]]

# the message form will rest party_ids so we need to carry it over
set new_party_ids $party_ids
ad_form -action message \
    -name message \
    -cancel_label "[_ contacts.Cancel]" \
    -cancel_url $return_url \
    -edit_buttons $edit_buttons \
    -form $form_elements \
    -on_request {
        if { [exists_and_not_null default_signature_id] } {
            set signature_id $default_signature_id
        } else {
            set signature_id ""
        }
    } -new_request {
    } -edit_request {
    } -on_submit {
    }
set party_ids $new_party_ids
