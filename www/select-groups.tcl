ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {object_type}
} 


set title "[_ contacts.Add_new_in_Group]"
set user_id [ad_conn user_id]
set context [list $title]
set package_id [ad_conn package_id]

set form_elements {
    object_type:text(hidden)
}

set group_options [contact::groups -privilege_required "create"]
if { [llength $group_options] == "0" } {
    # only the default group is available to this user
    set group_ids "-2" 
    ad_returnredirect [export_vars -base "add/${object_type}" -url {object_type group_ids}]
#    ad_return_error "[_ contacts.lt_Insufficient_Permissi]" "[_ contacts.lt_You_do_not_have_permi]"
}

append form_elements {
    {group_ids:text(checkbox),multiple,optional {label "[_ contacts.Add_to_Groups]"} {options $group_options}}
}
set edit_buttons [list [list "[_ contacts.lt_Add_new_in_Selected_Groups]" create]]

ad_form \
    -name group-parties-add \
    -cancel_label "[_ contacts.Cancel]" \
    -cancel_url "." \
    -edit_buttons $edit_buttons \
    -form $form_elements \
    -on_request {
    } -on_submit {
    } -after_submit {
	# the contact needs to be added to the default group
	lappend group_ids "-2"
	ad_returnredirect [export_vars -base "add/${object_type}" -url {object_type group_ids}]
	ad_script_abort
    }


