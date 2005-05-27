ad_page_contract {

    List and manage files for a contact.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2005-05-24
    @cvs-id $Id$
} {
    {party_id:integer,notnull}
    {upload_count:integer "1"}
    {orderby "file,asc"}
} -validate {
    contact_exists -requires {party_id} {
	if { ![contact::exists_p -party_id $party_id] } {
	    ad_complain "The contact specified does not exist"
	}
    }
}

if { $upload_count != 10 } {
    set upload_count 1
}

set contact_name [contact::name -party_id $party_id]
set form_elements [list {party_id:integer(hidden)}]
lappend form_elements [list {upload_count:integer(hidden)}]
lappend form_elements [list {orderby:text(hidden),optional}]
set upload_number 1
while { $upload_number <= $upload_count } {
    lappend form_elements [list "upload_file${upload_number}:file(file),optional" [list label ""] [list section "section$upload_number"]]
    lappend form_elements [list "upload_title${upload_number}:text(text),optional" [list html "size 45 maxlength 100"] [list label ""]]
    incr upload_number
}
if { $upload_count == 1 } { set upload_label "Upload" } else { set upload_label "Done" }
lappend form_elements [list "upload:text(submit),optional" [list "label" $upload_label]]
lappend form_elements [list "upload_more:text(submit),optional" [list "label" "Upload More"]]

ad_form -name upload_files -html {enctype multipart/form-data} -form $form_elements -on_request {
} -on_submit {
    set upload_number 1
    set message [list]
    while { $upload_number <= $upload_count } {
        set file [set "upload_file${upload_number}"]
	set title [set "upload_title${upload_number}"]
        set filename [template::util::file::get_property filename $file]
        if { $filename != "" } {
            set tmp_filename [template::util::file::get_property tmp_filename $file]
            set mime_type [template::util::file::get_property mime_type $file]
            set tmp_size [file size $tmp_filename]
	    set extension [contact::util::get_file_extension -filename $filename]
	    if { ![exists_and_not_null title] } {
		regsub -all ".${extension}\$" $filename "" title
	    }
	    set filename [contact::util::generate_filename -title $title -extension $extension -party_id $party_id]
            set revision_id [cr_import_content -storage_type "file" -title $title $party_id $tmp_filename $tmp_size $mime_type $filename]

            content::item::set_live_revision -revision_id $revision_id

            # if the file is an image we need to create thumbnails
            #
	    #/sw/bin/convert -gravity Center -crop 75x75+0+0 fred.jpg fred.jpg
	    #/sw/bin/convert -gravity Center -geometry 100x100+0+0 04055_7.jpg fred.jpg

	    lappend message "<a href=\"files/$filename\">$title</a>"
        }
        incr upload_number
    }
    if { [llength $message] == 1 } {
	util_user_message -html -message "The file [lindex $message 0] was successfully uploaded"
    } elseif { [llength $message] > 1 } {
	util_user_message -html -message "The files [join $message ", "] were successfully uploaded"
    }

} -after_submit {
    if { [exists_and_not_null upload_more] } {
	ad_returnredirect [export_vars -base "files" -url {{upload_count 10}}]
    } else {
	ad_returnredirect "files"
    }
    ad_script_abort
}




template::list::create \
    -html {width 100%} \
    -name "files" \
    -multirow "files" \
    -row_pretty_plural "files" \
    -checkbox_name checkbox \
    -bulk_action_export_vars [list party_id orderby] \
    -bulk_actions {
        "Delete" "../files-delete" "Delete the selectted files"
	"Update" "../files-update" "Update filenames"
    } -selected_format "normal" \
    -key item_id \
    -elements {
        file {
	    label {File}
	    display_col title
	    link_url_eval $file_url
	}
        rename {
            label {Rename}
	    display_template {
                <input name="rename.@files.item_id@" value="@files.title@" size="30">
	    }
	}
        type {
	    label "Type"
	    display_col extension
	}
        creation_date {
	    label "Updated On"
	    display_col creation_date_pretty
	}
        creation_user {
	    label "Updated By"
	    display_col creation_user_pretty
	}
    } -filters {
    } -orderby {
        file {
            label "File"
            orderby_asc  "upper(cr.title) asc,  ao.creation_date desc"
            orderby_desc "upper(cr.title) desc, ao.creation_date desc"
            default_direction asc
        }
        creation_date {
            label "Updated On"
            orderby_asc  "ao.creation_date asc"
            orderby_desc "ao.creation_date desc"
	    default_direction desc
	}
        creation_user {
            label "Updated By"
            orderby_asc  "upper(contact__name(ao.creation_user)) asc, upper(cr.title) asc"
            orderby_desc "upper(contact__name(ao.creation_user)) desc, upper(cr.title) asc"
	    default_direction desc
	}
        default_value file,asc
    } -formats {
	normal {
	    label "Table"
	    layout table
	    row {
	    }
	}
    }

set package_url [ad_conn package_url]
db_multirow -extend {file_url extension} -unclobber files select_files " 
select ci.item_id,
       ci.name,
       cr.title,
       to_char(ao.creation_date,'FMMon DD FMHH12:MIam') as creation_date_pretty,
       contact__name(ao.creation_user) as creation_user_pretty
  from cr_items ci, cr_revisions cr, acs_objects ao
 where ci.parent_id = :party_id
   and ci.live_revision = cr.revision_id
   and cr.revision_id = ao.object_id
[template::list::orderby_clause -orderby -name "files"]
" {
     set file_url "${package_url}${party_id}/files/${name}"
     set extension [lindex [split $name "."] end]

}


ad_return_template
