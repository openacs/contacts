# packages/contacts/tcl/contacts-callback-procs.tcl

ad_library {
    
    Callback procs for contacts
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-15
    @arch-tag: 4267c818-0019-4222-8a50-64edbe7563d1
    @cvs-id $Id$
}


ad_proc -public -callback contact::contact_form {
    {-package_id:required}
    {-form:required}
    {-object_type:required}
    {-party_id}
    {-group_ids ""}
    {-rel_type ""}
} {
    Form when adding a new contact. This is especially used when presetting values
} -

ad_proc -public -callback contact::contact_form_validate {
    {-package_id:required}
    {-form:required}
    {-object_type:required}
    {-party_id}
} {
}

ad_proc -public -callback contact::organization_new {
    {-package_id:required}
    {-contact_id:required}
    {-name:required}
} {
}

ad_proc -public -callback contact::person_add {
    {-package_id:required}
    {-person_id:required}
} {
}

ad_proc -public -callback contact::person_new_group {
    {-person_id:required}
    {-group_id:required}
} {
    This is a callback that is executed when you add a new person to a group.
    This will enable other packages to check if the person is added into a special group and then
    do something with them accordingly.
} -

ad_proc -public -callback contact::organization_new_group {
    {-organization_id:required}
    {-group_id:required}
} {
    This is a callback that is executed when you add a new organization to a group.
    This will enable other packages to check if the organization is added into a special group and then
    do something with them accordingly.
} -

ad_proc -public -callback contact::person_new_rel {
    {-party_id:required}
    {-object_id_two:required}
    {-rel_type:required}
} {
    This is a callback that is executed when you add a new person in a relationship to an organization.
    This will enable other packages to check if the person is added into a special relationship with the 
    organization and then do something with them accordingly.
} -

ad_proc -public -callback contact::organization_new_rel {
    {-party_id:required}
    {-object_id_two:required}
    {-rel_type:required}
} {
    This is a callback that is executed when you add a new organization in a relationship.
    This will enable other packages to check if the organization is added into a special relationship
    and then do something with them accordingly.
} -

ad_proc -public -callback contact::history {
    {-party_id:required}
    {-multirow:required}
    {-truncate_len ""}
} {
}

ad_proc -public -callback contacts::bulk_actions {
    {-multirow:required}
} {
}

ad_proc -public -callback contacts::email_subject {
    {-folder_id:required}
} {
}

ad_proc -public -callback contact::append_attribute {
    {-multirow_name:required}
    {-name:required}
} {
}

ad_proc -public -callback contact::after_instantiate {
    {-package_id:required}
} {
}

ad_proc -public -callback pm::project_new -impl contacts {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
} {
    map selected organization to new project
} {
    array set callback_data $data
    set project_rev_id [pm::project::get_project_id \
			    -project_item_id $project_id]

    if {[exists_and_not_null callback_data(organization_id)]} {
	application_data_link::new -this_object_id $project_rev_id -target_object_id $callback_data(organization_id)
    }
}

ad_proc -public -callback pm::project_edit -impl contacts {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
} {
    map selected organization to updated project
} {
    array set callback_data $data
    set project_rev_id [pm::project::get_project_id \
			    -project_item_id $project_id]

    if {[exists_and_not_null callback_data(organization_id)]} {
	application_data_link::new -this_object_id $project_rev_id -target_object_id $callback_data(organization_id)
    }
}

ad_proc -public -callback fs::folder_chunk::add_bulk_actions -impl contacts {
    {-bulk_variable:required}
    {-folder_id:required}
    {-var_export_list:required}
} {
    Callback to add a bulk action for sending a mail to the contact with the files attached that are mapped in the folder view
    If you have an organization, all persons related to it will be added to the mail sending as well.

    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-15
    
    @param bulk_variable The name of the variable to upvar for extending the bulk variable list

    @return 
    
    @error 
} {
    set community_id [dotlrn_community::get_community_id]

    # Try to retrieve the project_id from the folder
    set project_id [db_string get_project_id_from_folder {
	select r.object_id_two as project_id
	from acs_data_links r, cr_items i, cr_items p
	where i.item_id = :folder_id
	and r.object_id_one = i.parent_id
	and r.object_id_two = p.item_id
    	and p.content_type = 'pm_project'
    } -default ""]

    if {[empty_string_p $project_id]} {
	# no project -> mail to all organization contacts
	set contact_organizations [application_data_link::get_linked -from_object_id $community_id -to_object_type "organization"]
	set contact_list ""
	foreach party_id $contact_organizations {
	    set contact_list [concat $contact_list [contact::util::get_employees -organization_id $party_id]]
	}
    } else {
	# project -> mail to project contact
	db_1row get_project_contact {
	    select p.contact_id as contact_list
	    from pm_projects p, cr_items i
	    where i.latest_revision = p.project_id
	    and i.item_id = :project_id
	}
    }

    # A lot of upvar magic is used here to set the variables in the folder-chunk.tcl
    # context. 
    if {[exists_and_not_null contact_list]} {
	upvar $bulk_variable local_var
	upvar $var_export_list local_list
	upvar party_ids contact_ids_loc
	set contact_ids_loc $contact_list

	lappend local_var "[_ contacts.Mail_to_contact]" "/contacts/message" "[_ contacts.Mail_to_contact]"
	lappend local_list "party_ids"
	
	# Add the message type automatically
	# lappend local_list "message_type"
	# upvar message_type message_type_loc
	# set message_type_loc "email"

	if {![empty_string_p $project_id]} {
	    lappend local_list "context_id"
	    upvar context_id context_id
	    set context_id $project_id
	}
    }
}


ad_proc -public -callback dotlrn_community::add_members -impl contacts_employees {
    {-community_id}
} {
    Callback to add the employees of an organization to the club as members

    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-15
    
    @param community_id The ID of the community

    @return 
    
    @error 
} {
    
    # Get list of employees and register them within the community
    set organization_id [lindex [application_data_link::get_linked -from_object_id $community_id -to_object_type "organization"] 0]
    
    set employee_list [contact::util::get_employees -organization_id $organization_id]
    foreach employee_id $employee_list {
	# Only add the user if the user is already in the system as a user, not a person.
	if {[contact::user_p -party_id $employee_id]} {
	    # Just to be on the save side, we actually check if the user is already in .LRN
	    dotlrn::user_add -user_id $employee_id
	    dotlrn_club::add_user -community_id $community_id -user_id $employee_id
	}
    }
}