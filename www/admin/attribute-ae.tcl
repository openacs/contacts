ad_page_contract {

    Create an Attribute

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
} {
    attribute_id:integer,optional
    widget_id:integer,optional
    {locale "en_US"}
}


set attr_exists_p 0
if { [exists_and_not_null attribute_id] } {
    set attr_exists_p [db_0or1row select_attr_exists_p { select 1 from contact_attributes where attribute_id = :attribute_id } ] 
    if { ![exists_and_not_null widget_id] } {
        db_1row get_widget_id { select widget_id from contact_attributes where attribute_id = :attribute_id }
    }
}

if { ![exists_and_not_null widget_id] } {
    ad_returnredirect "attribute-add"
    ad_abort_script
}

db_1row get_widget_description { select description as widget_description from contact_widgets where widget_id = :widget_id }

db_1row get_options_p { select CASE WHEN storage_column = 'option_map_id' THEN '1' ELSE '0' END as options_p
                          from contact_widgets
                         where widget_id = :widget_id
}

set languages [lang::system::get_locale_options]

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

ad_form -name attribute_form -action attribute-ae -form {
    {attribute_id:key}
    {widget_id:integer(hidden)}
    {widget_description:text(inform) {label "Widget"}}
    {language:text(select) {label "Language"} {value $locale} {options $languages}}
    {name:text {label "Name"} {html {size 50 maxlength 100}}}
    {help_text:text(textarea),optional {label "Help Text"} {html {rows 3 cols 50}} {help_text {Text entered here will assist people in filling out forms by adding extra information, useful facts, etc. Just like this scentence assists in describing what the \"Help Text\" field is}}}
}

if { $options_p && !$attr_exists_p } {
    ad_form -extend -name attribute_form -form {
        {options:text(textarea),nospell {label "Options"} {help_text "One option per line"} {html {cols 35 rows 6 wrap virtual}}}
    }
}


ad_form -extend -name attribute_form -new_request {
    set title "Add an Attribute"
} -edit_request {
    db_1row select_attribute_properties { select * from contact_attributes where attribute_id = :attribute_id }
    db_1row select_attribute_properties { select * from contact_attribute_names where attribute_id = :attribute_id and locale = :locale } 
   if { $options_p } {
        set options ""
        db_foreach get_options { select option from contact_attribute_options where attribute_id = :attribute_id } {
            append options "$option\r"
        }
        
    }
    set title "Edit: $attribute"
} -validate {
    # i need to add validation that the attribute isn't already in the database
} -on_submit {
} -new_data {
    set user_id [ad_conn user_id]
    set peeraddr [ad_conn peeraddr]
    set context_id [ad_conn package_id]
    set attribute [util_text_to_url -text $name]
    db_1row create_new_attribute_and_get_id {
	    select contact__attribute_create (
                                              :attribute_id,
					      :attribute,
                                              :widget_id,
                                              'f',
                                              now(),
					      :user_id,
					      :peeraddr,
                                              :context_id
					      )
    }
    db_1row save_attribute_name {
        select contact__attribute_name_save (
                                            :attribute_id,
                                            :language,
                                            :name,
                                            :help_text
                                            );
    }
    if { $options_p } {
        set sort_order "1"
        set options [string trim $options]
        foreach option [split $options "\n"] {
            set option [string trim $option]
            if { ![empty_string_p $option] } {
                db_1row create_option { select contact__attribute_option_create (:attribute_id,:option,:sort_order) }
                incr sort_order
            }
        }
    }
    ad_returnredirect -message "Added attribute '$name'" attributes
    ad_script_abort
} -edit_data {
    db_1row save_attribute_name {
        select contact__attribute_name_save (
                                            :attribute_id,
                                            :language,
                                            :name,
                                            :help_text
                                            );
    }
    ad_returnredirect -message "Updated attribute '$name'" attributes
} -after_submit {
    ad_returnredirect "attributes"
    ad_script_abort
}

set context [list [list "attributes" "Attributes"] $title]

ad_return_template

