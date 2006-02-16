#    @author Matthew Geddert openacs@geddert.com
#    @creation-date 2005-05-09
#    @cvs-id $Id$


set contact_master_template [parameter::get_from_package_key -package_key "contacts" -parameter "ContactMaster" -default "/packages/contacts/lib/contact-master"]
if { $contact_master_template != "/packages/contacts/lib/contact-master" } {
    ad_return_template
}

# Set up links in the navbar that the user has access to
set name [contact::name -party_id $party_id]
if { ![exists_and_not_null name] } {
    ad_complain "[_ contacts.lt_The_contact_specified]"
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set tasks_url [site_node::get_package_url -package_key "tasks"]
set page_url [ad_conn url]
set page_query [ad_conn query]

set title $name
set context [list $name]
if {![empty_string_p $tasks_url]} {
    set prefix "/contacts/${party_id}/"
} else {
    set prefix "${package_url}${party_id}/"
}


set link_list [list]
if { [ad_conn user_id] != 0} {
    lappend link_list "${prefix}edit"
    lappend link_list "[_ contacts.All__Edit]"

    lappend link_list "${prefix}"
    lappend link_list "[_ contacts.Summary_View]"

    lappend link_list "${prefix}relationships"
    lappend link_list "[_ contacts.Relationships]"

    lappend link_list "${prefix}files"
    lappend link_list "[_ contacts.Files]"

    if {![empty_string_p $tasks_url]} {
	lappend link_list "${prefix}history" "[_ contacts.History]"
	lappend link_list "/tasks/contact" "[_ contacts.Tasks]"
    }

    lappend link_list "${prefix}message"
    lappend link_list "[_ contacts.Mail]"

    lappend link_list "${prefix}changes"
    lappend link_list "[_ contacts.Changes]"
}

# Convert the list to a multirow and add the selected_p attribute
multirow create links label url selected_p

foreach {url label} $link_list {
    set selected_p 0

    if {[string equal $page_url $url]} {
        set selected_p 1
        if { $url != "/contacts/contact" } {
            set context [list [list [contact::url -party_id $party_id] $name] $label]
        }
    }

    multirow append links $label [subst $url] $selected_p
}
 
if { [lsearch [list person user] [contact::type -party_id $party_id]] >= 0 } {
    set public_url [acs_community_member_url -user_id $party_id]
}

ad_return_template
