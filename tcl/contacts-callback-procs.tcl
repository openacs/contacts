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
} {
}

ad_proc -public -callback contact::organization_new {
    {-package_id:required}
    {-contact_id:required}
    {-name:required}
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
    
    set contact_organizations [application_data_link::get_linked -from_object_id $community_id -to_object_type "organization"]
    
    set contact_list ""
    foreach party_id $contact_organizations {
	set contact_list [concat $contact_list [contact::util::get_employees -organization_id $party_id]]
    }
	
    if {[exists_and_not_null contact_list]} {
	upvar $bulk_variable local_var
	upvar $var_export_list local_list
	upvar party_ids contact_ids_loc
	set contact_ids_loc $contact_list
	upvar return_url return_loc
	set return_loc "/contacts/$party_id"
	lappend local_var "Mail to contact" "/contacts/message" "Mail to contact"
	lappend local_list "party_ids"
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
	if {[contact::user_p $employee_id]} {
	    # Just to be on the save side, we actually check if the user is already in .LRN
	    dotlrn::user_add -user_id $employee_id
	    dotlrn_club::add_user -community_id $club_id -user_id $employee_id
	}
    }
}