if { ![contact::exists_p -party_id $party_id] } {
    ad_complain "The contact specified does not exist"
}

# Set up links in the navbar that the user has access to

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set page_url [ad_conn url]
set page_query [ad_conn query]

set admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege admin]


set name [contact::name -party_id $party_id]
set title $name
set context [list $name]

set link_list [list]
if { [ad_conn user_id] != 0} {
    lappend link_list "/contacts/contact-edit"
    lappend link_list "All / Edit"

    lappend link_list "/contacts/contact"
    lappend link_list "Summary View"

    lappend link_list "/contacts/contact-groups"
    lappend link_list "Groups"

    lappend link_list "/contacts/contact-rels"
    lappend link_list "Relationships"

    lappend link_list "/contacts/comments"
    lappend link_list "Comments"

    lappend link_list "/tasks/"
    lappend link_list "Tasks"

    lappend link_list "/contacts/message"
    lappend link_list "Mail"
}
#    lappend link_list "/tasks/contact"
#    lappend link_list "Tasks"
#    lappend link_list "/contacts/contact-files"
#    lappend link_list "Files"
#    lappend link_list "/contacts/contact-history"
#    lappend link_list "History"



if { $admin_p } {

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

    multirow append links $label [export_vars -base $url -url {party_id}] $selected_p
}













ad_return_template
