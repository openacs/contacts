ad_library {

    Support procs for the contacts package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
}

namespace eval contact:: {}
namespace eval contact::message:: {}
namespace eval contact::signature:: {}

ad_proc -public contact::signature::get {
    {-signature_id:required}
} {
    Get a signature
} {
    return [db_string get_signature "select signature from contact_signatures where signature_id = :signature_id" -default {}]
}

ad_proc -private contact::message::root_folder {
} {
    returns the cr_folder for contacts
} {
    return [db_string get_root_folder { select contact__folder_id() }]
}

ad_proc -public contact::message::get {
    {-item_id:required}
    {-array:required}
} {
    Get the info on a contact message
} {
    upvar 1 $array row
    db_1row select_message_info { select * from contact_messages where item_id = :item_id } -column_array row
}

ad_proc -private contact::message::save {
    {-item_id:required}
    {-owner_id:required}
    {-message_type:required}
    {-title:required}
    {-description ""}
    {-content:required}
    {-content_format "text/plain"}
    {-locale ""}
} {
    save a contact message
} {
    if { ![db_0or1row item_exists_p { select '1' from contact_message_items where item_id = :item_id }] } {
	if { [db_0or1row item_exists_p { select '1' from acs_objects where object_id = :item_id }] } {
	    error "The item_id specified is not a contact_message_item but already exists as an acs_object. This is not a valid item_id."
	}
	# we need to create the content item
	content::item::new \
            -name "message.${item_id}" \
            -parent_id [contact::message::root_folder] \
	    -item_id $item_id \
	    -creation_user [ad_conn user_id] \
	    -creation_ip [ad_conn peeraddr] \
	    -content_type "content_revision" \
	    -storage_type "text"

	db_dml insert_into_message_items {
	    insert into contact_message_items
	    ( item_id, owner_id, message_type, locale )
	    values
	    ( :item_id, :owner_id, :message_type, :locale )
	}
    } else {
	db_dml update_message_item {
	    update contact_message_items set owner_id = :owner_id, message_type = :message_type, locale = :locale where item_id = :item_id
	}
    }

    set revision_id [content::revision::new \
			 -item_id $item_id \
			 -title $title \
			 -description $description \
			 -content $content \
			 -mime_type $content_format \
			 -is_live "t"]

    return $revision_id
}



ad_proc -private contact::message::log {
    {-message_type:required}
    {-sender_id ""}
    {-recipient_id:required}
    {-sent_date ""}
    {-title ""}
    {-description ""}
    {-content:required}
    {-content_format "text/plain"}
} {
    Does a mailing address exist for this party
} {
    if { ![exists_and_not_null sender_id] } {
	set sender_id [ad_conn user_id]
    }
    if { ![exists_and_not_null sent_date] } {
	set sent_date [db_string get_current_timestamp { select now() }]
    }
    set creation_ip [ad_conn peeraddr]
    set package_id [ad_conn package_id]
    # We make every message logged in this table an acs_object
    if { ![string equal $message_type "email"] } {
	set object_id [db_string create_acs_object { select acs_object__new (
									     null,
									     'contact_message_log',
									     :sent_date,
									     :sender_id,
									     :creation_ip,
									     :package_id
									     ) } ]
	db_dml log_message {
	    insert into contact_message_log
	    ( message_id, message_type, sender_id, recipient_id, sent_date, title, description, content, content_format)
	    values
	    ( :object_id, :message_type, :sender_id, :recipient_id, :sent_date, :title, :description, :content, :content_format)
	}
    }
}

ad_proc -private contact::message::email_address_exists_p {
    {-party_id:required}
} {
    Does a email address exist for this party. Cached
} {
    return [util_memoize [list ::contact::message::email_address_exists_p_not_cached -party_id $party_id]]
}

ad_proc -private contact::message::email_address_exists_p_not_cached {
    {-party_id:required}
} {
    Does a email address exist for this party
} {
    return [string is false [empty_string_p [contact::email -party_id $party_id]]]
}

ad_proc -private contact::message::mailing_address_exists_p {
    {-party_id:required}
} {
    Does a mailing address exist for this party. Cached
} {
    return [util_memoize [list ::contact::message::mailing_address_exists_p_not_cached -party_id $party_id]]
}

ad_proc -private contact::message::mailing_address_exists_p_not_cached {
    {-party_id:required}
} {
    Does a mailing address exist for this party
} {
    set attribute_ids [contact::message::mailing_address_attribute_id_priority]
    set revision_id [contact::live_revision -party_id $party_id]
    if { [llength $attribute_ids] > 0 } {
        if { [db_0or1row mailing_address_exists_p " select '1' from ams_attribute_values where object_id = :revision_id and attribute_id in ('[join $attribute_ids {','}]') limit 1 "] } {
            return 1
        } else {
            return 0
        }
    } else {
        return 0
    }
}


ad_proc -private contact::message::mailing_address {
    {-party_id:required}
    {-format "text/plain"}
} {
    Does a mailing address exist for this party
} {
    regsub -all "text/" $format "" format
    if { $format != "html" } {
	set format "text"
    }

    set attribute_ids [contact::message::mailing_address_attribute_id_priority]
    set revision_id [contact::live_revision -party_id $party_id]
    set mailing_address {}
    db_foreach mailing_address_values "
                   select attribute_id,
                          ams_attribute_value__value(attribute_id,value_id) as value
                     from ams_attribute_values
                    where object_id = :revision_id
                      and attribute_id in ('[join $attribute_ids {','}]')
    " {
	set attribute_value($attribute_id) $value
    }
    foreach attribute $attribute_ids {
	if { [info exists attribute_value($attribute)] } {
	    set mailing_address [ams::widget \
				     -widget postal_address \
				     -request "value_${format}" \
				     -value $value \
				    ]

            break
        }
    }
    return $mailing_address
}

ad_proc -private contact::message::mailing_address_attribute_id_priority {
} {
    Returns the order of priority of attribute_ids for the letter mailing address
} {
    set attribute_ids [parameter::get -parameter "MailingAddressAttributeIdOrder" -default {}]
    if { [llength $attribute_ids] == 0 } {
        # no attribute_id preference was specified so we get all postal_address attribute types and order them
        set postal_address_attributes [db_list_of_lists get_postal_address_attributes { select pretty_name, attribute_id from ams_attributes where widget = 'postal_address'}]
        set postal_address_attributes [ams::util::localize_and_sort_list_of_lists -list $postal_address_attributes]
        set attribute_ids [list]
        foreach attribute $postal_address_attributes {
            lappend attribute_ids [lindex $attribute 1]
        }
    }
    return $attribute_ids
}



ad_proc -private contact::message::interpolate {
    {-values:required}
    {-text:required}
} {
    Interpolates a set of values into a string. This is directly copied from the bulk mail package

    @param values a list of key, value pairs, each one consisting of a
    target string and the value it is to be replaced with.
    @param text the string that is to be interpolated

    @return the interpolated string
} {
    foreach pair $values {
        regsub -all [lindex $pair 0] $text [lindex $pair 1] text
    }
    return $text
}

