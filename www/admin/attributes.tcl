ad_page_contract {

    list all attributes avaiable, and let the user edit edit permissions, regroup, etc.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    groupby:optional
    orderby:optional
    {format "normal"}
    {status "normal"}
    {locale "en_US"}
}

set title "\#contacts.Attributes\#"
set context [list $title]

list::create \
    -name entries \
    -multirow entries \
    -key attribute_id \
    -row_pretty_plural $title \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
        variable
    } -actions {
        "Add" "attribute-ae" "Add an Attribute"
        "Widgets" "widgets" "Widgets"
    } -bulk_actions {
        "Depreciate" "attribute-depreciate" "Depreciated checked attribute"
        "Restore" "attribute-restore" "Restore checked attribute"
    } -elements {
        edit {
            label {}
            display_template {
                <a href="attribute-ae?attribute_id=@entries.attribute_id@" title="Edit this attribute"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a>
            }
        }
        attribute {
            label "\#contacts.Attribute\#"
            display_col attribute
        }
        name {
            label "\#contacts.Name\#"
            display_template {
                <a href="attribute-view?attribute_id=@entries.attribute_id@">@entries.name@</a>
                <if @entries.depreciated_p@>(Depreciated - <a href="attribute-restore?attribute_id=@entries.attribute_id@">Restore</a>)</if>
            }
        }
        widget {
            display_col widget_description
            label "\#contacts.Widget\#"
        }
        help_text {
            display_col help_text
            label "\#contacts.Help_Text\#"
        }
        permissions {
            display_template {
                   <a href="permissions?object_id=@entries.attribute_id@">Permissions</a>
            }
            label "Permissions"
        }
    } -filters {
    } -groupby {
    } -orderby {
        default_value name,asc
        name {
            label "\#contacts.Name\#"
            orderby_desc "upper(can.name) desc"
            orderby_asc "upper(can.name) asc"
            default_direction asc
        }
        attribute {
            label "\#contacts.Attribute\#"
            orderby_desc "upper(ca.attribute) desc"
            orderby_asc "upper(ca.attribute) asc"
            default_direction asc
        }
        widget {
            label "\#contacts.Widget\#"
            orderby_desc "upper(cw.description) desc"
            orderby_asc "upper(cw.description) asc"
            default_direction asc
        }
        help_text {
            label "\#contacts.Help_Text\#"
            orderby_desc "upper(help_text) desc"
            orderby_asc "upper(help_text) asc"
            default_direction asc
        }
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                checkbox {}
                edit {}
                name {}
                attribute {}
                widget {}
                help_text {}
                permissions {}
            }
        }
    }




db_multirow -unclobber entries get_attributes {}



ad_return_template
