#    @author Matthew Geddert openacs@geddert.com
#    @creation-date 2005-05-09
#    @cvs-id $Id$


# Set up links in the navbar that the user has access to
set package_url [ad_conn package_url]

if { [site_node::get_package_url -package_key "tasks"] != "" } {
    set prefix "/contacts/"
} else {
    set prefix "${package_url}"
}
if { [site_node::get_package_url -package_key "tasks"] != "" } {
    set tasks_enabled_p 1
} else {
    set tasks_enabled_p 0
}

set link_list [list]
lappend link_list "${prefix}"
lappend link_list "[_ contacts.Contacts]"

if { ![parameter::get -boolean -parameter "ForceSearchBeforeAdd" -default "0"] && !${tasks_enabled_p} } {
    lappend link_list "${prefix}add/person"
    lappend link_list "[_ contacts.Add_Person]"

    lappend link_list "${prefix}add/organization"
    lappend link_list "[_ contacts.Add_Organization]"
}

lappend link_list "${prefix}search"
lappend link_list "[_ contacts.Advanced_Search]"

lappend link_list "${prefix}searches"
lappend link_list "[_ contacts.Saved_Searches]"

if { ${tasks_enabled_p} } {
	lappend link_list "/tasks/"
	lappend link_list "[_ contacts.Tasks]"
}

lappend link_list "${prefix}settings"
lappend link_list "[_ contacts.Settings]"

if { [permission::permission_p -object_id [ad_conn package_id] -privilege "admin"] } {
    lappend link_list "${prefix}admin/"
    lappend link_list "[_ contacts.Admin]"
}



set page_url [ad_conn url]
set page_query [ad_conn query]

# Convert the list to a multirow and add the selected_p attribute
multirow create links label url selected_p

foreach {url label} $link_list {
    set selected_p 0

    if {[string equal $page_url $url]} {
        set selected_p 1
        if { ${url} == ${prefix} } {
	    set title [ad_conn instance_name]
        } else {
	    set title $label
	}
    }
    multirow append links $label [subst $url] $selected_p
}

if { [parameter::get -boolean -parameter "ForceSearchBeforeAdd" -default "0"] } {
    if { $page_url == "${prefix}add/person" } {
	    set title [_ contacts.Add_Person]
    } elseif { $page_url == "${prefix}add/organization" } {
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