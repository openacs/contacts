# /packages/mbryzek-subsite/www/admin/rel-type/new.tcl

ad_page_contract {

    Form to create a new relationship type

    @author mbryzek@arsdigita.com
    @creation-date Sun Nov 12 18:27:08 2000
    @cvs-id $Id$

} {
    {item_id:integer,optional}
    {message_type ""}
    {return_url "messages"}
} -properties {
} -validate {
    type_exists -requires {message_type} {
	if { ![exists_and_not_null message_type] && ![exists_and_not_null item_id] } {
	    ad_complain [_ contacts.lt_You_must_specify_a_message_type]
	}
    }
    item_exists -requires {item_id} {
	if { ![db_0or1row message_exists_p { select 1 from contact_messages where item_id = :item_id}] && ![exists_and_not_null message_type]} {
	    ad_complain [_ contacts.lt_The_message_id_specified_does_not_exist]
	}
    }
    item_not_yours -requires {item_id} {
	if { ![permission::permission_p -object_id [ad_conn package_id] -privilege "admin"] } {
	    set user_id [ad_conn user_id]
	    if { ![db_0or1row message_exists_p { select 1 from contact_messages where item_id = :item_id and owner_id = :user_id}] } {
		ad_complain [_ contacts.lt_The_message_id_specified_does_not_belong_to_you]
	    }
	}
    }
}

set message_exists_p 0
if { [exists_and_not_null item_id] } {
    if { [db_0or1row message_exists_p { select 1 from contact_messages where item_id = :item_id}] } {
	set message_exists_p 1
    }
}

if { $message_exists_p } {
    db_1row get_message_type_and_title { select message_type, title as page_title from contact_messages where item_id = :item_id }
} else {
    set page_title "[_ contacts.Add] [lang::util::localize [db_string select_type_pretty { select pretty_name from contact_message_types where message_type = :message_type}]]"
}
set context [list [list "messages" "[_ contacts.Messages]"] $page_title]

set form_elements {
    {item_id:key}
    {owner_id:integer(hidden)}
    {message_type:text(hidden)}
    {return_url:text(hidden)}
    {title:text(text) {label "[_ contacts.Title]"} {html {size 45 maxlength 1000}} {help_text "[_ contacts.lt_Title_is_not_shown_in_the_message]"}}
    {locale:text(select) {label "[_ acs-lang.Locale]"} {options [lang::util::get_locale_options]}}
}

switch $message_type {
    email {
	append form_elements {
	    {description:text(text) {label "[_ contacts.Subject]"} {html {size 55 maxlength 1000}}}
	    {content:text(textarea) {label "[_ contacts.Body]"} {html {cols 70 rows 24}}}
	}
    }
    letter {
	append form_elements {
	    {content:richtext(richtext) {label "[_ contacts.Message]"} {html {cols 70 rows 24}}}
	}
    }
    header {
	append form_elements {
	    {content:richtext(richtext) {label "[_ contacts.Header]"} {html {cols 70 rows 24}}}
	}
    } 
    footer {
	append form_elements {
	    {content:richtext(richtext) {label "[_ contacts.Header]"} {html {cols 70 rows 24}}}
	}
    } 

}

ad_form -name "rel_type" \
    -cancel_label [_ contacts.Cancel] \
    -cancel_url $return_url \
    -form $form_elements \
    -on_request {
    } -new_request {
	set owner_id [ad_conn user_id]
	set locale [lang::system::locale]
    } -edit_request {

	db_1row get_data { select * from contact_messages where item_id = :item_id }
	if { $message_type != "email" } {
	    set content [list $content $content_format]
	}
	
    } -on_submit {

	if { $message_type != "email" } {
	    set content_format [template::util::richtext::get_property format $content]
	    set content [template::util::richtext::get_property content $content]
	    set description ""
	} else {
	    set content_format "text/plain"
	}

	contact::message::save \
	    -item_id $item_id \
	    -owner_id $owner_id \
	    -message_type $message_type \
	    -title $title \
	    -description $description \
	    -content $content \
	    -content_format $content_format \
	    -locale $locale

    } -after_submit {
	ad_returnredirect $return_url
	ad_script_abort
    }

ad_return_template
