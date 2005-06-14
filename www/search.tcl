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
    valid_object_type -requires {object_type} {
        if { [lsearch [list party person organization] $object_type] < 0 } {
            ad_complain "[_ contacts.You_have_specified_an_invalid_object_type]"
        }
    }
}


set page_title "[_ contacts.Advanced_Search]"
set context [list $page_title]
set sw_admin_p [acs_user::site_wide_admin_p]

if { [exists_and_not_null clear] } {
    ad_returnredirect "search"
}

if { [exists_and_not_null delete] } {
    ad_returnredirect [export_vars -base search-action -url {search_id {action delete}}]
}

if { [exists_and_not_null search] } {
    ad_returnredirect ".?search_id=$search_id"
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


set object_type_pretty_name(party)        [_ contacts.People_or_Organizations]
set object_type_pretty_name(person)       [_ contacts.People]
set object_type_pretty_name(organization) [_ contacts.Organizations]

if { ![exists_and_not_null owner_id] } {
    set owner_id [ad_conn user_id]
}


# FORM HEADER
set form_elements {
    {search_id:key}
    {owner_id:integer(hidden)}
}
if { [exists_and_not_null object_type] } {
    set object_type_pretty $object_type_pretty_name($object_type)
    append form_elements {
        {object_type:text(hidden) {value $object_type}}
        {object_type_pretty:text(inform) {label {[_ contacts.Search_for]}} {value "<strong>$object_type_pretty</strong>"} {after_html "[_ contacts.which_match]"}}
        {all_or_any:text(select),optional {label ""} {options {{[_ contacts.All] all} {[_ contacts.Any] any}}} {after_html "[_ contacts.lt_of_the_following_cond]<br>"}}
    }
} else {
    set object_type_options [list]
    foreach object_type_temp [list party person organization] {
        lappend object_type_options [list $object_type_pretty_name($object_type_temp) $object_type_temp]
    }
    append form_elements {
        {object_type:text(select) {label {#contacts.Search_for#}} {options $object_type_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
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
[contact::search::where_clause -and -search_id $search_id -party_id "party_id" -revision_id "cr.revisions.revision_id"]


</pre>
"
     }
}


if { [exists_and_not_null object_type] } {

    # QUERY TYPE
    set type_options [list \
                          [list "[_ contacts.Attribute_-]" "attribute"] \
                          [list "[_ contacts.Contact_-]" "contact"] \
                          [list "[_ contacts.Group_-]" "group"] \
                         ]

#    [list "Tasks ->" "tasks"]
    append form_elements {
        {type:text(select),optional {label {}} {options $type_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
    }
}


# each type must specify when to save a query
set add_p 0

switch $type {
    attribute {


        db_foreach get_attributes {
            select pretty_name, attribute_id
            from ams_attributes	
            where object_type in ('organization','party','person','user') 
            and ams_attribute_id is not null
            order by upper (pretty_name) 
        } {
	    set pretty_name [lang::util::localize $pretty_name]
	    lappend attribute_options [list "$pretty_name ->" $attribute_id]
	}

        append form_elements {
            {var1:text(select),optional {label {}} {options $attribute_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
        }

        if { [exists_and_not_null var1] } {
            set attribute_id $var1
            ams::attribute::get -attribute_id $attribute_id -array "attr_info"
            set value_method [ams::widget -widget $attr_info(widget) -request "value_method"]

            switch $value_method {
                ams_value__options {
                    set operand_options [list \
                                             [list "[_ contacts.is_-]" "selected"] \
                                             [list "[_ contacts.is_not_-]" "not_selected"] \
                                             [list "[_ contacts.is_set]" "set"] \
                                             [list "[_ contacts.is_not_set]" "not_set"] \
                                            ]

                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
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
                                             [list "[_ contacts.area_code_is_-]" "area_code_equals"] \
                                             [list "[_ contacts.area_code_is_not_-]" "not_area_code_equals"] \
                                             [list "[_ contacts.country_code_is_-]" "country_code_equals"] \
                                             [list "[_ contacts.lt_country_code_is_not_-]" "not_country_code_equals"] \
                                             [list "[_ contacts.is_set]" "set"] \
                                             [list "[_ contacts.is_not_set]" "not_set"] \
                                            ]

                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
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
                                             [list "[_ contacts.contains_-]" "contains"] \
                                             [list "[_ contacts.does_not_contain_-]" "not_contains"] \
                                             [list "[_ contacts.is_set]" "set"] \
                                             [list "[_ contacts.is_not_set]" "not_set"] \
                                            ]

                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
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
                                             [list "[_ contacts.country_is_-]" "country_is"] \
                                             [list "[_ contacts.country_is_not_-]" "country_is_not"] \
                                             [list "[_ contacts.stateprovince_is_-]" "state_is"] \
                                             [list "[_ contacts.lt_stateprovince_is_not_]" "state_is_not"] \
                                             [list "[_ contacts.lt_zippostal_starts_with]" "zip_is"] \
                                             [list "[_ contacts.lt_zippostal_does_not_st]" "zip_is_not"] \
                                             [list "[_ contacts.is_set]" "set"] \
                                             [list "[_ contacts.is_not_set]" "not_set"] \
                                            ]

                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
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
                                             [list "[_ contacts.is_-]" "is"] \
                                             [list "[_ contacts.is_greater_than_-]" "greater_than"] \
                                             [list "[_ contacts.is_less_than_-]" "less_than"] \
                                             [list "[_ contacts.is_set]" "set"] \
                                             [list "[_ contacts.is_not_set]" "not_set"] \
                                            ]

                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
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
                                             [list "[_ contacts.is_less_than_-]" "less_than"] \
                                             [list "[_ contacts.is_more_than_-]" "more_than"] \
                                             [list "[_ contacts.is_after_-]" "after"] \
                                             [list "[_ contacts.is_before_-]" "before"] \
                                             [list "[_ contacts.is_set]" "set"] \
                                             [list "[_ contacts.is_not_set]" "not_set"] \
                                            ]
                    append form_elements {
                        {var2:text(select),optional {label {}} {options $operand_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
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
                                 [list "[_ contacts.lt_updated_in_the_last_-]" "update"] \
                                 [list "[_ contacts.lt_not_updated_in_the_la]" "not_update"] \
                                 [list "[_ contacts.lt_commented_on_in_last_]" "comment"] \
                                 [list "[_ contacts.lt_not_commented_on_in_l]" "not_comment"] \
                                 [list "[_ contacts.lt_created_in_the_last_-]" "created"] \
                                 [list "[_ contacts.lt_not_created_in_the_la]" "not_created"] \
                                ]
        if { $object_type == "person" } {
            lappend contact_options [list "[_ contacts.has_logged_in]" "login"]
            lappend contact_options [list "[_ contacts.has_never_logged_in]" "not_login"]
            lappend contact_options [list "[_ contacts.lt_has_logged_in_within_]" "login_time"]
            lappend contact_options [list "[_ contacts.lt_has_not_logged_in_wit]" "not_login_time"]
        }
        append form_elements {
            {var1:text(select) {label {}} {options $contact_options} {html {onChange "javascript:acs_FormRefresh('advanced_search')"}}}
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
                                 [list "[_ contacts.contact_is_in_-]" "in"] \
                                 [list "[_ contacts.contact_is_not_in_-]" "not_in"] \
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
        {add:text(submit) {label "[_ contacts.Add_Condition]"} {value "add"}}
    }
} else {
    append form_elements {
        {next:text(submit) {label "[_ contacts.Next]"} {value "next"}}
    }
}

if { $search_exists_p } {
    set results_count [contact::search::results_count -search_id $search_id]

    append form_elements {
        {title:text(text),optional {label "<br><br>[_ contacts.save_this_search_]"} {html {size 40 maxlength 255}}}
        {save:text(submit) {label "[_ contacts.Save]"} {value "save"}}
        {search:text(submit) {label "[_ contacts.Search]"} {value "search"}}
        {clear:text(submit) {label "[_ contacts.Clear]"} {value "clear"}}
        {delete:text(submit) {label "[_ contacts.Delete]"} {value "delete"}}
        {results_count_widget:text(inform) {label "&nbsp;&nbsp;<span style=\"font-size: smaller;\">[_ contacts.Results]</span>"} {value {<a href="[export_vars -base ./ -url {search_id}]">$results_count</a>}}}
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

