#    @author Matthew Geddert openacs@geddert.com
#    @creation-date 2005-05-09
#    @cvs-id $Id$


set contacts_master_template [parameter::get_from_package_key -package_key "contacts" -parameter "ContactsMaster" -default "/packages/contacts/lib/contacts-master"]
if { $contacts_master_template != "/packages/contacts/lib/contacts-master" } {
    ad_return_template
}

# Set up links in the navbar that the user has access to
set package_url [ad_conn package_url]

set link_list [list]
lappend link_list "${package_url}"
lappend link_list "[_ contacts.Contacts]"
lappend link_list "contacts"


if { ![parameter::get -boolean -parameter "ForceSearchBeforeAdd" -default "0"] } {
    lappend link_list "${package_url}add/employee"
    lappend link_list "[_ contacts.Add_Employee]"
    lappend link_list "add_employee"

    lappend link_list "${package_url}add/person"
    lappend link_list "[_ contacts.Add_Person]"
    lappend link_list "add_person"
    
    lappend link_list "${package_url}add/organization"
    lappend link_list "[_ contacts.Add_Organization]"
    lappend link_list "add_organization"
}

lappend link_list "${package_url}search"
lappend link_list "[_ contacts.Advanced_Search]"
lappend link_list "advanced_search"

lappend link_list "${package_url}searches"
lappend link_list "[_ contacts.Saved_Searches]"
lappend link_list "saved_searches"

# this should be taken care of by a callback...
if { [apm_package_enabled_p tasks] } {
    lappend link_list "${package_url}tasks"
    lappend link_list "[_ tasks.Tasks]"
    lappend link_list "tasks"
    
    lappend link_list "${package_url}processes"
    lappend link_list "[_ tasks.Processes]"
    lappend link_list "processes"
}

lappend link_list "${package_url}messages"
lappend link_list "[_ contacts.Messages]"
lappend link_list "messages"

lappend link_list "${package_url}settings"
lappend link_list "[_ contacts.Settings]"
lappend link_list "settings"

if { [permission::permission_p -object_id [ad_conn package_id] -privilege "admin"] } {
    lappend link_list "${package_url}admin/"
    lappend link_list "[_ contacts.Admin]"
    lappend link_list "admin"
}



set page_url [ad_conn url]
set page_query [ad_conn query]

# Convert the list to a multirow and add the selected_p attribute
multirow create links label url id selected_p

set navbar {}
foreach {url label id} $link_list {
    set selected_p 0

    if {[string equal $page_url $url]} {
        set selected_p 1
        if { ${url} == ${package_url} } {
	    set title [ad_conn instance_name]
        } else {
	    set title $label
	}
    }
    lappend navbar [list [subst $url] $label]
    multirow append links $label [subst $url] $id $selected_p
}

if { [parameter::get -boolean -parameter "ForceSearchBeforeAdd" -default "0"] } {
    if { $page_url == "${package_url}add/person" } {
	    set title [_ contacts.Add_Person]
    } elseif { $page_url == "${package_url}add/organization" } {
	    set title [_ contacts.Add_Organization]
    }
}

if { ![exists_and_not_null title] } {
    set title [ad_conn instance_name]
    set context [list]
} else {
    set context [list $title]
}


ad_return_template
