ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {party_id:integer,notnull}
    {orderby ""}
} -validate {
    contact_exists -requires {party_id} {
	if { ![contact::exists_p -party_id $party_id] } {
	    ad_complain "[_ contacts.lt_The_contact_specified]"
	}
    }
}

set object_type [contact::type -party_id $party_id]
set user_id [ad_conn user_id]
set package_url [ad_conn package_url]


# Code for quickly adding an employee

if {$object_type == "organization"} {
} else {
    set employee_url ""
}

set live_revision [contact::live_revision -party_id $party_id]
if { [exists_and_not_null live_revision] } {
    set update_date [db_string get_update_date { select to_char(publish_date,'Mon FMDD, YYYY at FMHH12:MIam') from cr_revisions where revision_id = :live_revision } -default {}]
}


if { [site_node::get_package_url -package_key "tasks"] != "" } {
    set tasks_enabled_p 1
} else {
    set tasks_enabled_p 0
}

# Get the linked projekt_id to display the subprojects if projects is installed
set pm_package_id ""

if { [string is false [empty_string_p [info procs "::application_data_link::get_linked"]]] } {

    set project_id [lindex [application_data_link::get_linked -from_object_id $party_id -to_object_type "pm_project"] 0]
    set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $party_id -to_object_type "dotlrn_club"] 0]

    if {$project_id > 0 && $dotlrn_club_id <1} {
	set pm_package_id [acs_object::get_element -object_id $project_id -element package_id]
	set pm_base_url [apm_package_url_from_id $pm_package_id]
	set project_url [export_vars -base $base_url {{project_item_id $project_id}}]
	set projects_enabled_p 1
    } else {
	set projects_enabled_p 0
	set project_url ""
    }

    if {$dotlrn_club_id > 0} {
	set club_url [dotlrn_community::get_community_url $dotlrn_club_id]
	set dotlrn_club_enabled_p 1
	set pm_package_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]
	set pm_base_url [apm_package_url_from_id $pm_package_id]
    } else {
	set dotlrn_club_enabled_p 0
    }

    set iv_package_id [application_link::get_linked -from_package_id [ad_conn package_id] -to_package_key "invoices"]
    if {$iv_package_id > 0 } {
	set iv_base_url [apm_package_url_from_id $iv_package_id]
	set invoices_enabled_p 1
    } else {
        set invoices_enabled_p 0
    }
} else {
    set dotlrn_club_enabled_p 0
    set projects_enabled_p 0
    set invoices_enabled_p 0
}

# We are going to get a list of all members of the group Freelancer
# that have worked in a project for customer_id (party_id in this case).
# So first we get all projects were the party_id is customer

set project_list [db_list get_projects { select item_id from pm_projectsx where customer_id = :party_id }]

# Now we search for all the members of the Freelancer
# group that are assigned to one of this projects.

# Get the group members list
set group_id [group::get_id -group_name "Freelancer"]
set group_members_list [group::get_members -group_id $group_id]

# Now we create the select menu to use
set select_menu "<select name=\"supplier_id\">"
append select_menu "<option value=\"-100\" selected> - - - - - -</option>"
db_foreach get_members {  } {
    append select_menu "<option value=\"$supplier_id\">[contact::name -party_id $supplier_id]</option>"
}
append select_menu "</select>"





ad_return_template
