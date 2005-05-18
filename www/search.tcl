ad_page_contract {
    List and manage contacts.
 
    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {search_id:integer,optional}
    {type ""}
    {var1 ""}
    {var2 ""}
    {var3 ""}
    {var4 ""}
    {var5 ""}
    {save ""}
    {add ""}
    {next ""}
    {clear ""}
    {delete ""}
    {search ""}
    {object_type ""}
    {all_or_any ""}
    {title ""}
    {owner_id ""}
} -validate {
}

set page_title "Advanced Search"
set context [list $page_title]
set sw_admin_p [acs_user::site_wide_admin_p]

if { [exists_and_not_null clear] } {
    ad_returnredirect "search"
}

if { [exists_and_not_null delete] } {
    contact::search::delete -search_id $search_id
    ad_returnredirect "my-searches"
}

if { [exists_and_not_null search] } {
    ad_returnredirect ".?query_id=$search_id"
}


set search_exists_p 0
# set query_pretty [list]
if { [exists_and_not_null search_id] } {
    if { [contact::search::exists_p -search_id $search_id] } {
        db_1row get_em { select title, owner_id, all_or_any, object_type from contact_searches where search_id = :search_id }
        set search_exists_p 1
    }
}





if { [exists_and_not_null add] } {
    set action "add"
} else {
    set action "next"
}
switch $object_type {
    party        { set object_type_pretty "People or Organizations" }
    person       { set object_type_pretty "People" }
    organization { set object_type_pretty "Organizations" }
    default      {
        if { [exists_and_not_null object_type] } {
            ad_return_error "Invalid Object Type" "You have specified an invalid Object Type"
        }
    }
}

if { ![exists_and_not_null owner_id] } {
    set owner_id [ad_conn user_id]
}


# FORM HEADER
set form_elements {
    {search_id:key}
    {owner_id:integer(hidden)}
}
if { [exists_and_not_null object_type] } {
    append form_elements {
        {object_type:text(hidden) {value $object_type}}
        {object_type_pretty:text(inform) {label {Search for}} {value "<strong>$object_type_pretty</strong>"} {after_html " which match"}}
        {all_or_any:text(select),optional {label ""} {options {{All all} {Any any}}} {after_html "of the following conditions:<br>"}}
    }
} else {
#            {{People or Organizations} party}
    append form_elements {
        {object_type:text(select) {label {Search for}} {options {
            {{People} person}
            {{Organizations} organization}
        }} {html {onClick "javascript:acs_FormRefresh('advanced_search')"}}}
    }
}



# set query_pretty [list]
if { $search_exists_p } {
    set query_pretty "<ul>"
    db_foreach selectqueries {
        select type as query_type, var_list as query_var_list from contact_search_conditions where search_id = :search_id
    } {
        append query_pretty "<li>[contact::search::translate -type $query_type -var_list $query_var_list -to pretty -party_id "party_id" -revision_id "cr.revisions.revision_id"]</li>"
    }
    append query_pretty "</ul>"
    append form_elements {
        {query:text(hidden),optional}
        {query_pretty:text(inform),optional {label {}} {value $query_pretty}}
    }
    if { $sw_admin_p } {
	set query_code "
<pre>


select contact__name(party_id), party_id, revision_id
  from parties, cr_items, cr_revisions
 where party_id = cr_items.item_id
   and cr_items.latest_revision = cr_revisions.revision_id
[contact::search::where_clauses -and -search_id $search_id -party_id "party_id" -revision_id "cr.revisions.revision_id"]


</pre>
"
     }
}















if { [exists_and_not_null object_type] } {

    # QUERY TYPE
    set type_options [list \
                          [list "Attribute ->" "attribute"] \
                          [list "Contact ->" "contact"] \
                          [list "Group ->" "group"] \
                         ]

#    [list "Tasks ->" "tasks"]
    append form_elements {
        {type:text(select),optional {label {}} {options $type_options} {html {onClick "javascript:acs_FormRefresh('advanced_search')"}}}
    }
}


# each type must specify when to save a query
set add_p 0

switch $type {
    attribute {


        set attribute_options [db_list_of_lists get_attributes {
            select pretty_name || ' ->' , attribute_id
            from ams_attributes
            where object_type in ('organization','party','person','user') 
            and ams_attribute_id is not null
            order by upper (pretty_name) 
        }]

        append form_elements {
            {var1:text(select),optional {label {}} {options $attribute_options} {html {onClick "javascript:acs_FormRefresh('advanced_search')"}}}
        }

        if { [exists_and_not_null var1] } {
            set attribute_id $var1
            ams::attribute::get -attribute_id $attribute_id -array "attr_info"
            set value_method [ams::widget -widget $attr_info(widget) -request "value_method"]

            switch $value_method {
                ams_value__options {
                    set operand_options [list \
                                             [list "is ->" "selected"] \
                                             [list "is not ->" "not_selected"] \
                                             [list "is set" "set"] \
                                             [list "is not set" "not_set"] \
                                            ]

                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onClick "javascript:acs_FormRefresh('advanced_search')"}}}
                    }
                    if { [exists_and_not_null var2] } {
                        if { $var2 == "exists" || $var2 == "not_exists" } {
                            set action "add"
                        } else {
                            set option_options [ams::widget_options -attribute_id $attribute_id]
                            append form_elements {
                                {var3:text(select) {label {}} {options $option_options}}
                            }
                        }
                        set add_p 1
                    }

                }
                ams_value__telecom_number {
                    set operand_options [list \
                                             [list "area code is ->" "area_code_equals"] \
                                             [list "area code is not ->" "not_area_code_equals"] \
                                             [list "country code is ->" "country_code_equals"] \
                                             [list "country code is not ->" "not_country_code_equals"] \
                                             [list "is set" "set"] \
                                             [list "is not set" "not_set"] \
                                            ]

                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onClick "javascript:acs_FormRefresh('advanced_search')"}}}
                    }
                    if { [exists_and_not_null var2] } {
                        if { $var2 == "exists" || $var2 == "not_exists" } {
                            set action "add"
                        } else {
                            append form_elements {
                                {var3:integer(text) {label {}} {html {size 3 maxlength 3}}}
                            }
                        }
                        set add_p 1
                    }

                }
                ams_value__text {
                    set operand_options [list \
                                             [list "contains ->" "contains"] \
                                             [list "does not contain ->" "not_contains"] \
                                             [list "is set" "set"] \
                                             [list "is not set" "not_set"] \
                                            ]

                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onClick "javascript:acs_FormRefresh('advanced_search')"}}}
                    }
                    if { [exists_and_not_null var2] } {
                        if { $var2 == "exists" || $var2 == "not_exists" } {
                            set action "add"
                        } else {
                            append form_elements {
                                {var3:text(text) {label {}}}
                            }
                        }
                        set add_p 1
                    }

                }
                ams_value__postal_address {
                    set operand_options [list \
                                             [list "country is ->" "country_is"] \
                                             [list "country is not ->" "country_is_not"] \
                                             [list "state/province is ->" "state_is"] \
                                             [list "state/province is not ->" "state_is_not"] \
                                             [list "zip/postal starts with ->" "zip_is"] \
                                             [list "zip/postal does not start with ->" "zip_is_not"] \
                                             [list "is set" "set"] \
                                             [list "is not set" "not_set"] \
                                            ]

                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onClick "javascript:acs_FormRefresh('advanced_search')"}}}
                    }
                    if { [exists_and_not_null var2] } {
                        if { $var2 == "exists" || $var2 == "not_exists" } {
                            set action "add"
                        } elseif { $var2 == "state_is" || $var2 == "state_is_not" } {
                            append form_elements {
                                {var3:text(text) {label {}} {html {size 2 maxlength 2}}}
                            }
                        } elseif { $var2 == "country_is" || $var2 == "country_is_not" } {
                            set country_options [template::util::address::country_options]
                            append form_elements {
                                {var3:text(select) {label {}} {options $country_options}}
                            }
                        } else {
                            append form_elements {
                                {var3:text(text) {label {}} {html {size 7 maxlength 7}}}
                            }
                        }
                        set add_p 1
                    }

                }
                ams_value__number {
                    set operand_options [list \
                                             [list "is ->" "is"] \
                                             [list "is greater than ->" "greater_than"] \
                                             [list "is less than ->" "less_than"] \
                                             [list "is set" "set"] \
                                             [list "is not set" "not_set"] \
                                            ]

                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onClick "javascript:acs_FormRefresh('advanced_search')"}}}
                    }
                    if { [exists_and_not_null var2] } {
                        if { $var2 == "exists" || $var2 == "not_exists" } {
                            set action "add"
                        } else {
                            append form_elements {
                                {var3:integer(text) {label {}} {html {size 4 maxlength 20}}}
                            }
                        }
                        set add_p 1
                    }

                }
                ams_value__time {
                    set operand_options [list \
                                             [list "is less than ->" "less_than"] \
                                             [list "is more than ->" "more_than"] \
                                             [list "is after ->" "after"] \
                                             [list "is before ->" "before"] \
                                             [list "is set" "set"] \
                                             [list "is not set" "not_set"] \
                                            ]
                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onClick "javascript:acs_FormRefresh('advanced_search')"}}}
                    }
                    if { [exists_and_not_null var2] } {
                        if { $var2 == "exists" || $var2 == "not_exists" } {
                            set action "add"
                        } else {
                            if { $var2 == "more_than" || $var2 == "less_than" } {
                                set interval_options {
                                    {years years}
                                    {months months}
                                    {days days}
                                }
                                append form_elements {
                                    {var3:integer(text) {label {}} {html {size 2 maxlength 3}}}
                                    {var4:text(select) {label {}} {options $interval_options} {after_html {ago}}}
                                }
                            } else {
                                append form_elements {
                                    {var3:date(date) {label {}}}
                                }
                            }
                        }
                        set add_p 1
                    }

                }
            }


        }
    }
    contact {
        set contact_options [list \
                                 [list "updated in the last ->" "update"] \
                                 [list "not updated in the last ->" "not_update"] \
                                 [list "commented on in last ->" "comment"] \
                                 [list "not commented on in last ->" "not_comment"] \
                                 [list "created in the last ->" "created"] \
                                 [list "not created in the last ->" "not_created"] \
                                ]
        if { $object_type == "person" } {
            lappend contact_options [list "has logged in" "login"]
            lappend contact_options [list "has never logged in" "not_login"]
            lappend contact_options [list "has logged in within ->" "login_time"]
            lappend contact_options [list "has not logged in within ->" "not_login_time"]
        }
        append form_elements {
            {var1:text(select) {label {}} {options $contact_options} {html {onClick "javascript:acs_FormRefresh('advanced_search')"}}}
        }

        if { [exists_and_not_null var1] } {
            if { $var1 == "login" || $var1 == "not_login" } {
                set action "add"
            } else {
                set interval_options {
                    {days days}
                    {months months}
                    {years years}
                }
                append form_elements {
                    {var2:integer(text) {label {}} {html {size 3 maxlength 4}}}
                    {var3:text(select) {label {}} {options $interval_options}}
                }
            }
            set add_p 1
        }
    }
    group {
        set operand_options [list \
                                 [list "contact is in ->" "in"] \
                                 [list "contact is not in ->" "not_in"] \
                                ]

        set group_options [contact::groups -expand "all" -privilege_required "read"]
        set add_p 1
        append form_elements {
            {var1:text(select) {label {}} {options $operand_options}}
            {var2:text(select) {label {}} {options $group_options}}
        }

    }
    tasks {
        set contact_options [list \
                                 [list "" ""] \
                                 [list "" ""] \
                                 [list "" ""] \
                                 [list "" ""] \
                                 [list "" ""] \
                                 [list "" ""] \
                                ]
    }
}
































if { $add_p } {
    append form_elements {
        {add:text(submit) {label "Add Condition"} {value "add"}}
    }
} else {
    append form_elements {
        {next:text(submit) {label "Next"} {value "next"}}
    }
}















if { $search_exists_p } {
    append form_elements {
        {title:text(text),optional {label "<br><br>save this search as"} {html {size 40 maxlength 255}}}
        {save:text(submit) {label {Save}} {value "save"}}
        {search:text(submit) {label {Search}} {value "search"}}
        {clear:text(submit) {label {Clear}} {value "clear"}}
        {delete:text(submit) {label {Delete}} {value "delete"}}
    }
}
ad_form -name "advanced_search" -method "GET" -form $form_elements \
    -on_request {
    } -edit_request {
    } -on_refresh {
    } -on_submit {
        if { [contact::search::exists_p -search_id $search_id] } {
            contact::search::update -search_id $search_id -title $title -owner_id $owner_id -all_or_any $all_or_any
        }
        if { $action == "add" } {
            if { [string is false [contact::search::exists_p -search_id $search_id]] } {
                set search_id [contact::search::new -search_id $search_id -title $title -owner_id $owner_id -all_or_any $all_or_any -object_type $object_type]
            }
            set var_list $var1
            set vars [list var2 var3 var4 var5]
            foreach var $vars {
                if { [set $var] != "" } {
                    if { [template::element::get_property advanced_search $var widget] == "date" } {
                        set $var [join [template::util::date::get_property linear_date_no_time [set $var]] "-"]
                    }
                    lappend var_list [set $var]
                }
            }
            contact::search::condition::new -search_id $search_id -type $type -var_list $var_list
        }
    } -after_submit {
        if { $action == "add" } {
#            rp_internal_redirect search
            ad_returnredirect [export_vars -base "search" -url {search_id object_type all_or_any}]
            ad_script_abort
        }
    }

