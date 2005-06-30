ad_library {

    Support procs for the contacts package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
}

namespace eval contact:: {}
namespace eval contact::message:: {}

ad_proc -private contact::message::root_folder {
} {
    returns the cr_folder for contacts
} {
    return [db_string get_root_folder { select contact__folder_id() }]
}

ad_proc -private contact::message::save {
    {-item_id:required}
    {-owner_id:required}
    {-message_type:required}
    {-title:required}
    {-description ""}
    {-content:required}
    {-content_format "text/plain"}
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
	    ( item_id, owner_id, message_type )
	    values
	    ( :item_id, :owner_id, :message_type )
	}
    } else {
	db_dml update_message_item {
	    update contact_message_items set owner_id = :owner_id, message_type = :message_type where item_id = :item_id
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
    {-message_id:required}
    {-message_type:required}
    {-sender_id ""}
    {-recipient_id:required}
    {-sent_date ""}
    {-title ""}
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
    db_dml log_message {
	insert into contact_message_log
	( message_id, message_type, sender_id, recipient_id, sent_date, title, content, content_format)
        values
        ( :message_id, :message_type, :sender_id, :recipient_id, :sent_date, :title, :content, :content_format)
    }
}


ad_proc -private contact::message::mailing_address_exists_p {
    {-party_id:required}
} {
    Does a mailing address exist for this party
} {
    set attribute_ids [contact::letter::mailing_address_attribute_id_priority]
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
    {-format "text"}
} {
    Does a mailing address exist for this party
} {
    set attribute_ids [contact::letter::mailing_address_attribute_id_priority]
    set revision_id [contact::live_revision -party_id $party_id]
    set attributes_with_values [db_list_of_lists mailing_address_values " select attribute_id, value_id from ams_attribute_values where object_id = :revision_id and attribute_id in ('[join $attribute_ids {','}]')"]
    foreach attribute $attribute_ids {
        if { [lsearch $attributes_with_values [lindex $attribute 0]] >= 0 } {
            # the attribute_id for this value is set
            set attribute_id [lindex $attribute 0]
            set value_id [lindex $attribute 1]
            break
        }
    }
    if { [exists_and_not_null attribute_id] } {
        return [ams::widget \
                    -widget postal_address \
                    -request "value_${format}" \
                    -attribute_name "Mailing Address" \
                    -attribute_id $attribute_id \
                    -value [db_string get_value { select ams_attribute_value__value(:attribute_id,:value_id)} -default {}] \
                   ]

    } else {
        return {}
    }
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

