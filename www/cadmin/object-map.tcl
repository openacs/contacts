ad_page_contract {
    
    This page lets users map contact attributes to any
    acs_object. It also lets one customize the way the
    form elements are presented to that object.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    object_id:integer,notnull
    groupby:optional
    orderby:optional
    {format "normal"}
    {status "normal"}
    {locale "en_US"}
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $object_id -privilege admin

set object_name [db_string get_object_name {}]

set title "Attribute Management"
set context [list $title]

set contacts_admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege admin]



list::create \
    -name mapped_attributes \
    -multirow mapped_attributes \
    -key attribute_id \
    -row_pretty_plural "Mapped Attributes" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
    } -actions {
    } -bulk_actions {
	"Answer Required" "attributes-answer-required" "Require an answer from the checked attributes"
	"Answer Optional" "attributes-answer-optional" "An answer from the checked attributes is optional"
	"Unmap" "attributes-unmap" "Unmap check attributes"
	"Update ordering" "attributes-order-update" "Update ordering from values in list"
    } -bulk_action_export_vars { 
        object_id
    } -elements {
        attribute {
            label "\#contacts.Attribute\#"
            display_col attribute
        }
        name {
            label "\#contacts.Name\#"
            display_col name
        }
        widget {
            display_col widget_description
            label "\#contacts.Widget\#"
        }
        action {
            label "\#contacts.Action\#"
            display_template {
                <a href="attributes-unmap?object_id=$object_id&attribute_id=@mapped_attributes.attribute_id@" class="button">Unmap</a>
            }
        }
        answer {
            label "\#contacts.Required\#"
            display_template {
                <if @mapped_attributes.required_p@>
                <a href="attributes-answer-optional?object_id=$object_id&attribute_id=@mapped_attributes.attribute_id@"><img src="/resources/checkboxchecked.gif" title="Required" border="0"></a>
                </if>
                <else>
                <a href="attributes-answer-required?object_id=$object_id&attribute_id=@mapped_attributes.attribute_id@"><img src="/resources/checkbox.gif" title="Optional" border="0"></a>
                </else>
            }
        }
        sort_order {
            label "\#contacts.Ordering\#"
            display_template {
                <input name="sort_key.@mapped_attributes.attribute_id@" value="@mapped_attributes.sort_order_key@" size="4">
            }
        }
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                checkbox {}
                name {}
                sort_order {}
                answer {}
                action {}
            }
        }
    }



# This query will override the ad_page_contract value entry_id
template::multirow create mapped_attributes attribute_id attribute name help_text required_p sort_order widget_description sort_order_key

set sort_order_key 0

db_foreach get_mapped_courses {} {
    incr sort_order_key 10
    template::multirow append mapped_attributes $attribute_id $attribute $name $help_text $required_p $sort_order $widget_description $sort_order_key

}


#----------------------------------------------------------------------
# List builder
#----------------------------------------------------------------------





list::create \
    -name unmapped_attributes \
    -multirow unmapped_attributes \
    -key attribute_id \
    -row_pretty_plural "Unmapped Attributes" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
    } -actions {
    } -bulk_actions {
	"Map" "attributes-map" "Map the selected attributes"
    } -bulk_action_export_vars { 
        object_id 
    } -elements {
        attribute {
            label "\#contacts.Attribute\#"
            display_col attribute
        }
        name {
            label "\#contacts.Name\#"
            display_col name
        }
        widget {
            display_col widget_description
            label "\#contacts.Widget\#"
        }
        action {
            label "\#contacts.Action\#"
            display_template {
                <a href="attributes-map?object_id=$object_id&attribute_id=@unmapped_attributes.attribute_id@" class="button">Map</a>
            }
        }
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                checkbox {}
                name {}
                action {}
            }
        }
    }



# This query will override the ad_page_contract value entry_id

db_multirow -extend { sort_order_key } -unclobber unmapped_attributes get_unmapped_courses {} {
}



ad_return_template





