ad_page_contract {


    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

} {
    {party_id:integer}
    {return_url ""}
    groupby:optional
    orderby:optional
    {format "normal"}
    {status "normal"}
}

set actions_list [list "Edit" "[apm_package_url_from_id [ad_conn package_id]]contact-ae?party_id=$party_id\&return_url=$return_url" "Edit [contact::name $party_id]"]

list::create \
    -name attributes \
    -multirow attributes \
    -key comment_id \
    -row_pretty_plural "Attributes" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
    } -actions $actions_list \
    -bulk_actions {
    } -bulk_action_export_vars { 
    } -elements {
        attribute {
            label "Attribute"
            display_col pretty_attribute_name
        }
        attribute_value {
            label "Value"
            display_col pretty_value_html;noquote
        }
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                attribute {}
                attribute_value {}
            }
        }
    }

set user_id [ad_conn user_id]
set object_type [contact::get::object_type $party_id]
if { $object_type == "organization" } {
    set object_id [contacts::util::organization_object_id]
}

if { $object_type == "person" } {
    set object_id [contacts::util::person_object_id]
}

contacts::get::values::multirow -multirow_name "attributes" -party_id $party_id -object_id $object_id




ad_return_template
