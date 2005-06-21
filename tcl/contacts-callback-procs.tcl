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
} {
}

ad_proc -public -callback contact::organization_new {
    {-package_id:required}
    {-contact_id:required}
    {-name:required}
} {
}

ad_proc -public -callback contact::person_new {
    {-package_id:required}
    {-contact_id:required}
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
    
    set contact_organizations [application_data_link::get_linked -from_object_id $folder_id -to_object_type "organization"]
    
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

