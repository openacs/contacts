ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    orderby:optional
    {owner_id:optional}
    {message_type ""}
} -validate {
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
if { ![exists_and_not_null owner_id] } {
    set owner_id $user_id
}
set owner_options [db_list_of_lists select_owner_options {}]
set owner_options [concat [list [list [_ contacts.Public_Messages] "${package_id}"]] $owner_options]

set message_types [ams::util::localize_and_sort_list_of_lists \
		       -list [db_list_of_lists get_message_types { select pretty_name, message_type from contact_message_types}] \
		      ]

set actions [list]
foreach type $message_types {
    lappend actions "[_ contacts.Add] [lindex $type 0]" [export_vars -base message-ae -url [list [list message_type [lindex $type 1]]]] "[_ contacts.Add] [lindex $type 0]"
    set type_pretty_name([lindex $type 1]) [lindex $type 0]
}

template::list::create \
    -name "messages" \
    -multirow "messages" \
    -row_pretty_plural "[_ contacts.messages]" \
    -actions $actions \
    -key item_id \
    -elements {
        type_pretty {
	    label {#contacts.Type#}
	    display_col type_pretty
	}
        title {
	    label {#contacts.Title#}
	    display_col title
            link_url_eval $message_url
	}
        action {
            label ""
            display_template {
                <a href="@messages.copy_url@" class="button">#contacts.Copy#</a>
                <if @messages.delete_url@ not nil>
                <a href="@messages.delete_url@" class="button">#contacts.Delete#</a>
                </if>
                <if @messages.make_public_url@ not nil>
                <a href="@messages.make_public_url@" class="button">#contacts.Make_Public#</a>
                </if>
            }
        }
    } -filters {
        owner_id {
            label "\#contacts.Owner\#"
            values $owner_options
            where_clause ""
            default_value $user_id
        }
    } -orderby {
    } -formats {
    }


set return_url [export_vars -base messages -url {owner_id}]
set admin_p [permission::permission_p -object_id $package_id -privilege "admin"]

db_multirow -extend {message_url make_public_url delete_url copy_url type_pretty} -unclobber messages select_messages {} {
    set type_pretty $type_pretty_name($message_type)
    if { $owner_id != $package_id && $admin_p } {
        set make_public_url [export_vars -base message-action -url {item_id {owner_id $package_id} {action move} return_url}]
    }
    if { $owner_id == $user_id || $admin_p } {
        set delete_url      [export_vars -base message-action -url {item_id {action delete}}]
    }
    set message_url [export_vars -base "message-ae" -url {item_id}]
    set copy_url        [export_vars -base message-action -url {item_id {owner_id $user_id} {action copy} return_url}]

}


