ad_page_contract {


    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

} {
    {searchterm ""}
    {letter ""}
    {num_rows "20"}
    {start_row:naturalnum "0"}
    {category_id:multiple,optional}
    {groupby:optional}
    {orderby:optional}
    {sortby "first_names"}
    {format "normal"}
    {status "current"}
    {object_type ""}
}

set admin_p [ad_permission_p [ad_conn package_id] admin]

set title "Contacts"
set context {}

set valid_numrows [list 10 20 50 100 ALL]
if { [lsearch $valid_numrows $num_rows] < 0 } {
    set num_rows 50
}



if { $num_rows == "ALL" } {
    set start_row 0
}





set export_vars_page_nav      [export_vars -url  { category_id format letter num_rows object_type orderby searchterm sortby status }]
set export_vars_search_form   [export_vars -form { category_id format        num_rows object_type orderby            sortby status }]
set export_vars_search_url    [export_vars -url  { category_id format        num_rows object_type orderby            sortby status }]
set export_vars_letter_url    [export_vars -url  { category_id format        num_rows object_type orderby            sortby status }]
set export_vars_sortby_url    [export_vars -url  { category_id format letter num_rows object_type orderby searchterm        status }]
set export_vars_num_rows_url  [export_vars -url  { category_id format letter          object_type orderby searchterm sortby status }]
set export_vars_category_form [export_vars -form {             format letter num_rows object_type orderby searchterm sortby status }]
set export_vars_category_url  [export_vars -url  {             format letter num_rows object_type orderby searchterm sortby status }]




if {[exists_and_not_null category_id]} {
    set category_id_filter "party_id in ( select object_id from category_object_map where category_id = $category_id )"
    set temp_category_id $category_id
} else {
    set category_id_filter ""
    set temp_category_id ""
}

set categories_p [contacts::categories::enabled_p]

if { [string is true $categories_p] } {
set category_select [contacts::categories::get_selects -export_vars $export_vars_category_form -category_id $temp_category_id] 
}


set searchterm_filter "upper(sort_$sortby) like upper('%$searchterm%')"
set letter_filter "upper(sort_$sortby) like upper('$letter%')"

if { [lsearch [list organization person] $object_type] < 0 } {
    set object_type_filter ""
} else {
    set object_type_filter "object_type = '$object_type'"
}

if { [lsearch [list current archived] $status] < 0 } {
    set status_filter ""
} else {
    set status_filter "status = '$status'"
}


if { $status == "archived" } {
set bulk_actions [list \
        "\#contacts.Make_Current\#" "contact-current" "\#contacts.Make_the_checked_contacts_current\#"]
} else {
set bulk_actions [list \
        "\#contacts.Archive\#" "contact-archive" "\#contacts.Archive_the_checked_contacts\#"]
}
#        "\#contacts.Add_to_Category\#" "contacts-category-add" "\#contacts.Add_the_selected_contacts_to_a_category\#" 
#        "\#contacts.Send_Email\#" "bulk-email" "\#contacts.Send_an_email_message_to_the_selected_contacts\#" \


list::create \
    -html { width 100% } \
    -name entries \
    -multirow entries \
    -key party_id \
    -row_pretty_plural "Contacts" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
        variable
    } -actions {
        "\#contacts.Add_a_Person\#" "contact-ae?object_type=person" "\#contacts.Add_a_Person\#"
        "\#contacts.Add_an_Organization\#" "contact-ae?object_type=organization" "\#contacts.Add_an_Organization\#"
    } -bulk_actions $bulk_actions \
    -elements {
        edit {
            label {}
            display_template {
                <a href="contact-ae?party_id=@entries.party_id@" title="\#acs-kernel.common_Edit\# @entries.sort_first_names@"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a>
            }

        }
        contact_name {
            display_col contact_name
            link_url_eval $contact_url
            label "\#contacts.Contact\#"
        }
        first_names {
            display_col first_names
            label "First Names"
        }
        last_name {
            display_col last_name
            label "Last Name"
        }
        organization_name {
            display_col name
            label "Organization"
        }
        email {
            display_template {
                @entries.email_url;noquote@
            }
            label "\#contacts.Email_Address\#"
        }
        contact_type {
            display_template {
                <if @entries.object_type@ eq organization>\#contacts.Organization\#</if>
                <else>\#contacts.Person\#</else>
            }
            label "\#contacts.Contact_Type\#"
        }
    } -filters {
        sortby {
            label "\#contacts.Sort_By\#"
            values {
                {{\#contacts.First_Names\#} first_names}
                {{\#contacts.Last_Name\#} last_name}
            }
            where_clause {}            
        }
        start_row {}
        category_id {
            label Categories
            where_clause {$category_id_filter}
        }
        letter {
            label "Letter"
            where_clause {$letter_filter}
        }
        object_type {
            label "\#contacts.Contact_Type\#"
            values {
                {{\#contacts.Organization\#} organization}
                {{\#contacts.Person\#} person}
            }
            where_clause {$object_type_filter}
        }
        searchterm {
            label "Search"
            where_clause {$searchterm_filter}
        }
        status {
            label "\#contacts.Status\#"
            values {
                {{\#contacts.Current\#} current}
                {{\#contacts.Archived\#} archived}
            }
            where_clause {$status_filter}
        }
        num_rows {
            label "\#contacts.Number_of_Rows\#"
            values {
                {10 10}
                {20 20}
                {50 50}
                {100 100}
                {500 500}
                {All ALL}
            }
        }
    } -groupby {
    } -orderby {
        default_value contact_name,asc
        contact_name {
            label "\#contacts.Contact\#"
            orderby_desc "contacts.sort_$sortby desc, contacts.object_type desc, contacts.email desc"
            orderby_asc  "contacts.sort_$sortby asc, contacts.object_type desc, contacts.email desc"
            default_direction asc
        }
        email {
            label "\#contacts.Email_Address\#"
            orderby_desc "contacts.email desc, contacts.sort_$sortby desc, contacts.object_type desc"
            orderby_asc  "contacts.email asc, contacts.sort_$sortby desc, contacts.object_type desc"
            default_direction asc
        }
        contact_type {
            label "\#contacts.Contact_Type\#"
            orderby_desc "contacts.object_type desc, contacts.sort_$sortby desc, contacts.email desc"
            orderby_asc  "contacts.object_type asc, contacts.sort_$sortby desc, contacts.email desc"
            default_direction asc
        }
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                checkbox {}
                edit {}
                contact_name {}
                email {}
                contact_type {}
            }
        }
        csv {
            label "CSV"
            output csv
            row {
                contact_name {}
                first_names {}
                last_name {}
                organization_name {}
                email {}
                contact_type {}
            }
        }
    }

# This query will override the ad_page_contract value entry_id

#  left join category_object_map c on (contact_attrs.party_id = c.object_id)
set multirow_query "
"
#        [template::list::sortby_clause -sortby -name entries]

db_multirow -extend { contact_url email_url object_type_pretty } -unclobber entries get_contact_info {} {
    set contact_url "view/$party_id"
    if { [exists_and_not_null email] } {
        set email_url "<a href=\"mailto:$email\">$email</a>"
    }
    if { $object_type == "organization" } {
        set object_type_pretty "\#contacts.Organization\#"
    } else {
        set object_type_pretty "\#contacts.Person\#"
    }
}


set initial_list_query "
select distinct upper(substr(sort_$sortby,1,1))
  from contacts
 where party_id is not null
"

if { [exists_and_not_null category_id_filter  ] } {
    append initial_list_query "and $category_id_filter\n"
}
# we cannot use the letter filter because it defeats the purpose
#if { [exists_and_not_null letter_filter       ] } {
#    append initial_list_query "and $category_id_filter"
#
#}
if { [exists_and_not_null object_type_filter  ] } {
    append initial_list_query "and $object_type_filter\n"
}
if { [exists_and_not_null searchterm_filter   ] } {
    append initial_list_query "and $searchterm_filter\n"
}
if { [exists_and_not_null status_filter       ] } {
    append initial_list_query "and $status_filter\n"
}

set initial_list [db_list_of_lists get_list_of_starting_letters $initial_list_query]



set letter_bar [contacts::util::letter_bar -letter $letter -export_vars $export_vars_letter_url -initial_list $initial_list]


# pagination - hopefully once list builder has pagination documenation
# this can be built into list builder


db_1row get_total_rows "
select count(*) as total_rows
  from contacts
 where party_id is not null
       [template::list::filter_where_clauses -and -name entries]
"

if { $num_rows != "ALL" } {

    set first_row                [expr $start_row + 1]
    set last_row                 [expr $start_row + $num_rows]

    if { $num_rows >= $total_rows } {
        set first_row 1
        set last_row $total_rows
        set start_row 0
    }


    if { $last_row >= $total_rows } {
        set next_link_p 0
        set last_row $total_rows
    } else {
        set next_link_p 1
        set next_link_url "?start_row=$last_row&$export_vars_page_nav"
    }
    if { $start_row == "0" } {
        set prev_link_p 0
    } else {
        set prev_link_p 1
        set prev_link_start_row [expr $start_row - $num_rows]
        if { $prev_link_start_row < "0" } {
            set prev_link_start_row "0"
        }
        set prev_link_url "?start_row=$prev_link_start_row&$export_vars_page_nav"    
    }

} else {
    set next_link_p 0
    set prev_link_p 0
    set first_row 1
    set last_row $total_rows
}
template::list::write_output -name entries









ad_return_template


