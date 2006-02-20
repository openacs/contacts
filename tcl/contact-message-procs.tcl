ad_library {

    Support procs for the contacts package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
}

namespace eval contact:: {}
namespace eval contact::message:: {}
namespace eval contact::signature:: {}
namespace eval contact::oo:: {}

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
    {-banner ""}
    {-ps ""}
    {-package_id ""}
} {
    save a contact message
} {
    if { ![db_0or1row item_exists_p { select '1' from contact_message_items where item_id = :item_id }] } {
	if { [db_0or1row item_exists_p { select '1' from acs_objects where object_id = :item_id }] } {
	    error "The item_id specified is not a contact_message_item but already exists as an acs_object. This is not a valid item_id."
	}
        if { ![exists_and_not_null package_id] } {
	    set package_id [ad_conn package_id]
	}

	# we need to create the content item
	content::item::new \
            -name "message.${item_id}" \
            -parent_id [contact::message::root_folder] \
	    -item_id $item_id \
	    -creation_user [ad_conn user_id] \
	    -creation_ip [ad_conn peeraddr] \
	    -content_type "content_revision" \
	    -storage_type "text" \
            -package_id $package_id

	db_dml insert_into_message_items {
	    insert into contact_message_items
	    ( item_id, owner_id, message_type, locale, banner, ps )
	    values
	    ( :item_id, :owner_id, :message_type, :locale, :banner, :ps )
	}
        # contact item new does not set the package_id in acs_object so
        # we do it here
        db_dml update_package_id {
	    update acs_objects
               set package_id = :package_id
             where object_id = :item_id
	}

    } else {
	db_dml update_message_item {
	    update contact_message_items set owner_id = :owner_id, message_type = :message_type, locale = :locale, banner = :banner, ps = :ps where item_id = :item_id
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
    {-item_id ""}
} {
    Logs a message into contact_message_log table.

    @param message_type  The message_type of this message (e.g email, letter).
    @param sender_id     The party_id of the sender of the message.
    @recipient_id        The party_id of the reciever of the message.
    @sent_date           The date when the message was sent. Default to now.
    @title               The title of the logged message.
    @description         The description of the logged message.
    @content             The content of the message.
    @content_format      The format of the content.
    @item_id             The item_id of the message from the default messages.
    
} {
    if { ![exists_and_not_null sender_id] } {
	set sender_id [ad_conn user_id]
    }
    if { ![exists_and_not_null sent_date] } {
	set sent_date [db_string get_current_timestamp { select now() }]
    }
    set creation_ip [ad_conn peeraddr]
    set package_id [ad_conn package_id]

    # First we check the parameter to see if the emails are going to be logged or not,
    # if they are then we check if the message is a default one (message_id).

    if { ![string equal $message_type "email"] } {

	# We make every message logged in this table an acs_object
	set object_id [db_string create_acs_object { }]
	db_dml log_message { }
	
    } elseif { [parameter::get -parameter "LogEmailsP"] && [exists_and_not_null item_id] } {
	
	# We log all emails that used a default email message.
	set object_id [db_string create_acs_object { }]
	db_dml log_message { }
	
    }
}

ad_proc -private contact::message::email_address_exists_p {
    {-party_id:required}
} {
    Does a message email address exist for this party or his/her employer. Cached via contact::message::email_address.
} {
    return [string is false [empty_string_p [contact::message::email_address -party_id $party_id]]]
}

ad_proc -private contact::message::email_address {
    {-party_id:required}
} {
    Does a message email address exist for this party
} {
    return [util_memoize [list ::contact::message::email_address_not_cached -party_id $party_id]]
}

ad_proc -private contact::message::email_address_not_cached {
    {-party_id:required}
} {
    Does a message email address exist for this party
} {
    set email [contact::email -party_id $party_id]
    if { $email eq "" } {
	# if this person is the employee of
        # an organization we can attempt to use
        # that organizations email address
	foreach employer [contact::util::get_employers -employee_id $party_id] {
	    set email [contact::email -party_id [lindex $employer 0]]
	    if { $email ne "" } {
		break
	    }
	}
    }
    return $email
}

ad_proc -private contact::message::mailing_address_exists_p {
    {-party_id:required}
} {
    Does a mailing address exist for this party. Cached via contact::message::mailing_address.
} {
    # since this check is almost always called by a page which
    # will later ask for the mailing address we take on the 
    # overhead of calling for the address, which is cached.
    # this simplifies the code and thus "pre" caches the address
    # for the user, which overall is faster

    return [string is false [empty_string_p [contact::message::mailing_address -party_id $party_id -format "text"]]]
}

ad_proc -private contact::message::mailing_address {
    {-party_id:required}
    {-format "text/plain"}
    {-package_id ""}
} {
    Returns a parties mailing address. Cached
} {
    regsub -all "text/" $format "" format
    if { $format != "html" } {
	set format "text"
    }
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }
    return [util_memoize [list ::contact::message::mailing_address_not_cached -party_id $party_id -format $format -package_id $package_id]]
}

ad_proc -private contact::message::mailing_address_not_cached {
    {-party_id:required}
    {-format:required}
    {-package_id:required}
} {
    Returns a parties mailing address
} {
    set attribute_ids [contact::message::mailing_address_attribute_id_priority -package_id $package_id]
    set revision_id [contact::live_revision -party_id $party_id]
    set mailing_address {}
    foreach attribute_id $attribute_ids {
	set mailing_address [ams::value \
				 -object_id $revision_id \
				 -attribute_id $attribute_id \
				 -format $format]
	if { $mailing_address ne "" } {
	    break
	}
    }
    if { $mailing_address eq "" } {
	# if this person is the employee of
        # an organization we can attempt to use
        # that organizations email address
	foreach employer [contact::util::get_employers -employee_id $party_id] {
	    set mailing_address [contact::message::mailing_address -party_id [lindex $employer 0] -package_id $package_id]
	    if { $mailing_address ne "" } {
		break
	    }
	}
    }
    return $mailing_address
}



ad_proc -private contact::message::mailing_address_attribute_id_priority {
    {-package_id:required}
} {
    Returns the order of priority of attribute_ids for the letter mailing address. Cached
} {
    return [util_memoize [list ::contact::message::mailing_address_attribute_id_priority_not_cached -package_id $package_id]]
}

ad_proc -private contact::message::mailing_address_attribute_id_priority_not_cached {
    {-package_id:required}
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

ad_proc -public contact::oo::convert {
    {-content}
} {
    Returns a string which we can insert into the content.xml file
} {
    regsub -all -nocase "<br>" $content "<text:line-break/>" content
    regsub -all -nocase "<p>" $content "<text:line-break/>" content
    regsub -all -nocase "&nbsp;" $content " " content
    regsub -all -nocase "</p>" $content "<text:line-break/>" content
    return [string trim $content]
}
    
ad_proc -public contact::oo::import_oo_pdf {
    -oo_file:required
    {-printer_name "pdfconv"}
    {-title ""}
    {-item_id ""}
    {-parent_id ""}
    {-no_import:boolean}
} {
    Imports an OpenOffice file (.sxw / .odt) as a PDF file into the content repository. If item_id is specified a new revision of that item is created, else a new item is created.
    
    @param oo_file The full path to the OpenOffice file that containst the data to be exported as PDF.
    @param printer_name The name of the printer that is assigned as the PDF converter. Defaults to "pdfconv".
    @param title Title which will be used for the resulting content item and file name if none was given in the item
    @param item_id The item_id of the content item to which the content should be associated.
    @param parent_id Needed to set the parent of this object
    @param no_import If this flag is specified the location of the generated PDF will be returned, but the pdf will not be stored in the content repository
    @return item_id of the revision that contains the file
    @return file location of the file if "no_import" has been specified.
} {
    # This exec command is missing all the good things about openacs
    # Add the parameter to whatever package you put this procedure in.
    set oowriter_bin [parameter::get -parameter "OOWriterBin" -default "/opt/openoffice.org2.0/program/swriter"]

    set status [catch {exec -- /bin/sh [acs_package_root_dir contacts]/bin/convert.sh $oo_file } result]

    if { $status == 0 } {

        # The command succeeded, and wrote nothing to stderr.
        # $result contains what it wrote to stdout, unless you
        # redirected it

    } elseif { [string equal $::errorCode NONE] } {

        # The command exited with a normal status, but wrote something
        # to stderr, which is included in $result.

    } else {

        switch -exact -- [lindex $::errorCode 0] {

            CHILDKILLED {
                foreach { - pid sigName msg } $::errorCode break

                # A child process, whose process ID was $pid,
                # died on a signal named $sigName.  A human-
                # readable message appears in $msg.

            }

            CHILDSTATUS {

                foreach { - pid code } $::errorCode break

                # A child process, whose process ID was $pid,
                # exited with a non-zero exit status, $code.

            }

            CHILDSUSP {

                foreach { - pid sigName msg } $::errorCode break

                # A child process, whose process ID was $pid,
                # has been suspended because of a signal named
                # $sigName.  A human-readable description of the
                # signal appears in $msg.

            }

            POSIX {

                foreach { - errName msg } $::errorCode break

                # One of the kernel calls to launch the command
                # failed.  The error code is in $errName, and a
                # human-readable message is in $msg.

            }

        }
    }
    
    # Strip the extension.
    set pdf_filename "[file rootname $oo_file].pdf"
    set mime_type "application/pdf"
    if {![file exists $pdf_filename]} {
	###############
	# this is a fix to use the oo file if pdf file could not be generated
	###############
	set pdf_filename $oo_file
	set mime_type "application/odt"
    } else {
	ns_unlink $oo_file
    }

    if {$no_import_p} {
	return [list $mime_type $pdf_filename]
    }

    set pdf_filesize [file size $pdf_filename]
    
    set file_name [file tail $pdf_filename]
    if {$title eq ""} {
	set title $file_name
    }
    
    if {[exists_and_not_null $item_id]} {
	set parent_id [get_parent -item_id $item_id]
	
	set revision_id [cr_import_content \
			     -title $title \
			     -item_id $item_id \
			     $parent_id \
			     $pdf_filename \
			     $pdf_filesize \
			     $mime_type \
			     $file_name ]
    } else {
	set revision_id [cr_import_content \
			     -title $title \
			     $parent_id \
			     $pdf_filename \
			     $pdf_filesize \
			     $mime_type \
			     $file_name ]
    }	

    ns_unlink $pdf_filename

    content::item::set_live_revision -revision_id $revision_id
    return [content::revision::item_id -revision_id $revision_id]
}

ad_proc -public contact::oo::change_content {
    -path:required
    -document_filename:required
    -contents:required
} {
    Takes the provided contents and places them in the content.xml file of the sxw file, effectivly changing the content of the file.

    @param path Path to the file containing the content
    @param document_filename The open-office file whose contents will be changed.
    @param contents This is a list of key-values (to be used as an array) of filenames and contents
                    to be replaced in the oo-file.
    @return The path to the new file.
} {
    # Create a temporary directory
    set dir [ns_tmpnam]
    ns_mkdir $dir

    array set content_array $contents
    foreach filename [array names content_array] {
	# Save the content to a file.
	set file [open "${dir}/$filename" w]
	fconfigure $file -encoding utf-8
	puts $file $content_array($filename)
	flush $file
	close $file
    }

    # copy the document
    ns_cp "${path}/$document_filename" "${dir}/$document_filename"

    # Replace old content in document with new content
    # The zip command should replace the content.xml in the zipfile which
    # happens to be the OpenOffice File. 
    foreach filename [array names content_array] {
	exec zip -j "${dir}/$document_filename" "${dir}/$filename"
    }

    # copy odt file
    set new_file "[ns_tmpnam].odt"
    ns_cp "${dir}/$document_filename" $new_file

    # delete other tmpfiles
    ns_unlink "${dir}/$document_filename"
    foreach filename [array names content_array] {
	ns_unlink "${dir}/$filename"
    }
    ns_rmdir $dir

    return $new_file
}








ad_proc -public -callback contacts::redirect -impl contactspdfs {
    {-party_id ""}
    {-action ""}
} {
    redirect the contact to the correct pdf stuff
} {

    ns_log notice "got here..."
    set url [ad_conn url]
    if { [regexp "^[ad_conn package_url]pdfs/" $url match] } {
	# this is a pdf url
	set filename [lindex [ad_conn urlv] end]
	if { ![regexp "^contacts_.*?_[ad_conn user_id](.*).pdf$" $filename match] || ![file exists "/tmp/${filename}"] } {
	    ad_return_error "No Permission" "You do not have permission to view this file, or the temporary file has been deleted."
	} else {
	    ns_returnfile 200 "application/pdf" "/tmp/${filename}"
	}
    }

}

