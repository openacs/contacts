ad_page_contract {

    list all attributes avaiable, and let the user edit edit permissions, regroup, etc.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    group_id:optional
    groupby:optional
    orderby:optional
    {format "normal"}
    {status "normal"}
}


set title "Add an Attribute"
set context [list [list "attributes" "Attributes"] $title]




list::create \
    -name entries \
    -multirow entries \
    -key course_id \
    -row_pretty_plural "Widgets" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
        variable
    } -actions {
    } -bulk_actions {
    } -elements {
        widget_id {
            display_col description
            label "Select a Widget"
            link_url_eval $attribute_add_url
        }
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                widget_id {}
            }
        }
    }



# This query will override the ad_page_contract value entry_id

db_multirow -extend { attribute_add_url } -unclobber entries select_widgets {} {
    set attribute_add_url "attribute-ae?widget_id=$widget_id"
}

ad_return_template

