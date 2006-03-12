# packages/contacts/tcl/contacts-callback-procs.tcl

ad_library {
    
    Callback procs for contacts
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-15
    @arch-tag: 4267c818-0019-4222-8a50-64edbe7563d1
    @cvs-id $Id$
}


ad_proc -public -callback contacts::package_instantiate {
    {-package_id:required}
} {
    After instantiate callback
} -

ad_proc -public -callback contact::label {
    {-request:required}
    {-for ""}
} {
    You can request one of:
    1. ad_form_option (list of pretty name key to be used in ad_form)
    2. template (the template and stylesheet parts of a page template) the option selected
       will be passed to the callback as 'for', so the template should only be returned if
       it matches the option provided by this implementation from ad_form_option
} -

ad_proc -public -callback contact::envelope {
    {-request:required}
    {-for ""}
} {
    You can request one of:
    1. ad_form_option (list of pretty name key to be used in ad_form)
    2. template (the template and stylesheet parts of a page template) the option selected
       will be passed to the callback as 'for', so the template should only be returned if
       it matches the option provided by this implementation from ad_form_option
} -

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

ad_proc -public -callback contacts::redirect {
    {-party_id ""}
    {-action ""}
} {
    This callback is executed by /package/contacts/index.vuh. If you want contact urls to map
    to or override standard files/links this is where you can customize the rp_internal_redirect
    or add your own ad_returnredirect
} -

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

ad_proc -public -callback contact::search::query_clauses {
    {-query:required}
    {-party_id:required}
} {
    This callback is executed by the contact::search::query_clause
    and allows a site to customize the behavior or the entered
    query string in the primary contacts search box it should
    return a list of conditions. These conditions will be joined by 
    and in the sql query, so if you want it to be or you should 
    return the conditions in quotes with or's already in place
} -

ad_proc -public -callback contact::special_attributes::ad_form_values {
    {-party_id:required}
    {-form:required}
} {
    This callback is executed last in the edit_request ad_form
    block of editing a contact
} -

ad_proc -public -callback contact::special_attributes::ad_form_save {
    {-party_id:required}
    {-form:required}
} {
    This callback is executed first in the new_data or edit_data ad_from
    blocks when creating or saving a contacts information
} -

ad_proc -public -callback contact::special_attributes::ad_form_values -impl contacts {
    -party_id:required
    -form:required
} {
} {
    set object_type [contact::type -party_id $party_id]

    db_1row get_extra_info {
	select email, url
	from parties
	where party_id = :party_id}
    set element_list [list email url]

    if { [lsearch [list person user] $object_type] >= 0 } {

	array set person [person::get -person_id $party_id]
	set first_names $person(first_names)
	set last_name $person(last_name)

	lappend element_list first_names last_name
    } elseif {$object_type == "organization" } {

	db_0or1row get_org_info {
            select name, legal_name, reg_number, notes
	    from organizations
	    where organization_id = :party_id}
	lappend element_list name legal_name reg_number notes
    }

    foreach element $element_list {
	if {[exists_and_not_null $element]} {
	    if {[template::element::exists $form $element]} {
		template::element::set_value $form $element [set $element]
	    }
	}
    }
}

ad_proc -public -callback contact::special_attributes::ad_form_save -impl contacts {
    -party_id:required
    -form:required
} {
} {
    set object_type [contact::type -party_id $party_id]
    set element_list [list email url]
    if { [lsearch [list person user] $object_type] >= 0 } {
	lappend element_list first_names last_name
    } elseif {$object_type == "organization" } {
	lappend element_list name legal_name reg_number notes
    }
    foreach element $element_list {
	if {[template::element::exists $form $element]} {
	    set value [template::element::get_value $form $element]
	    switch $element {
		email {
		    if {[db_0or1row party_is_user_p {select '1' from users where user_id = :party_id}]} {
			if {[exists_and_not_null value]} {
			    set username $value
			} else {
			    set username $party_id
			}
			acs_user::update -user_id $party_id -username $username
		    }
		    party::update -party_id $party_id -email $value -url [db_string get_url {select url from parties where party_id = :party_id} -default {}]
		}
		url {
		    party::update -party_id $party_id -email [db_string get_email {select email from parties where party_id = :party_id} -default {}] -url $value
		}
		default {
		    set $element $value
		}
	    }
        }
    }
    if { [lsearch [list person user] $object_type] >= 0 } {

	# first_names and last_name are required

	if {[exists_and_not_null first_names] 
	    && [exists_and_not_null last_name]} {
	    person::update -person_id $party_id -first_names $first_names -last_name $last_name
	} else {
	    if {![exists_and_not_null first_names]} {
		error "The object type was person but first_names (a required element) did not exist"
	    }
	    if {![exists_and_not_null last_name]} {
	        error "The object type was person but first_names (a required element) did not exist"
	    }
	}
    } elseif {$object_type == "organization" } {

	# name is required

	if {[exists_and_not_null name]} {
	    if {![exists_and_not_null legal_name]} {set legal_name "" }
	    if {![exists_and_not_null reg_number]} {set reg_number "" }
	    if {![exists_and_not_null notes]} {set notes "" }
	    db_dml update_org {
		update organizations
		set name = :name,
		legal_name = :legal_name,
		reg_number = :reg_number,
		notes = :notes
		where organization_id = :party_id}
	} else {
	    error "The object type was organization but name (a required element) did not exist"
	}
    }
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


ad_proc -public -callback contact::label -impl avery5160 {
    {-request:required}
    {-for ""}
} {
} {
    switch $request {
	ad_form_option {
	    return [list "Avery 5160 (1in x 2.5in, 30 per sheet)" avery5160]
	}
	template {
	    if { $for == "avery5160" } {
		return {<template pageSize="(8.5in, 11in)"
          leftMargin="0in"
          rightMargin="0in"
          topMargin="0in"
          bottomMargin="0in"
          title="Avery 5160"
          author="Avery 5160"
          allowSplitting="0"
          showBoundary="0"
          >
          <!-- showBoundary means that we will be able to see the            -->
          <!-- limits of frames                                              -->
    <pageTemplate id="main">
        <pageGraphics>
        </pageGraphics>
        <frame id="label01" x1="0.25in" y1="9.30in" width="2.50in" height="1.00in"/>
        <frame id="label02" x1="0.25in" y1="8.30in" width="2.50in" height="1.00in"/>
        <frame id="label03" x1="0.25in" y1="7.30in" width="2.50in" height="1.00in"/>
        <frame id="label04" x1="0.25in" y1="6.30in" width="2.50in" height="1.00in"/>
        <frame id="label05" x1="0.25in" y1="5.30in" width="2.50in" height="1.00in"/>
        <frame id="label06" x1="0.25in" y1="4.30in" width="2.50in" height="1.00in"/>
        <frame id="label07" x1="0.25in" y1="3.30in" width="2.50in" height="1.00in"/>
        <frame id="label08" x1="0.25in" y1="2.30in" width="2.50in" height="1.00in"/>
        <frame id="label09" x1="0.25in" y1="1.30in" width="2.50in" height="1.00in"/>
        <frame id="label10" x1="0.25in" y1="0.30in" width="2.50in" height="1.00in"/>
        <frame id="label11" x1="3.00in" y1="9.30in" width="2.50in" height="1.00in"/>
        <frame id="label12" x1="3.00in" y1="8.30in" width="2.50in" height="1.00in"/>
        <frame id="label13" x1="3.00in" y1="7.30in" width="2.50in" height="1.00in"/>
        <frame id="label14" x1="3.00in" y1="6.30in" width="2.50in" height="1.00in"/>
        <frame id="label15" x1="3.00in" y1="5.30in" width="2.50in" height="1.00in"/>
        <frame id="label16" x1="3.00in" y1="4.30in" width="2.50in" height="1.00in"/>
        <frame id="label17" x1="3.00in" y1="3.30in" width="2.50in" height="1.00in"/>
        <frame id="label18" x1="3.00in" y1="2.30in" width="2.50in" height="1.00in"/>
        <frame id="label19" x1="3.00in" y1="1.30in" width="2.50in" height="1.00in"/>
        <frame id="label20" x1="3.00in" y1="0.30in" width="2.50in" height="1.00in"/>
        <frame id="label21" x1="5.75in" y1="9.30in" width="2.50in" height="1.00in"/>
        <frame id="label22" x1="5.75in" y1="8.30in" width="2.50in" height="1.00in"/>
        <frame id="label23" x1="5.75in" y1="7.30in" width="2.50in" height="1.00in"/>
        <frame id="label24" x1="5.75in" y1="6.30in" width="2.50in" height="1.00in"/>
        <frame id="label25" x1="5.75in" y1="5.30in" width="2.50in" height="1.00in"/>
        <frame id="label26" x1="5.75in" y1="4.30in" width="2.50in" height="1.00in"/>
        <frame id="label27" x1="5.75in" y1="3.30in" width="2.50in" height="1.00in"/>
        <frame id="label28" x1="5.75in" y1="2.30in" width="2.50in" height="1.00in"/>
        <frame id="label29" x1="5.75in" y1="1.30in" width="2.50in" height="1.00in"/>
        <frame id="label30" x1="5.75in" y1="0.30in" width="2.50in" height="1.00in"/>
    </pageTemplate>
</template>
<stylesheet>
    <paraStyle name="name"
      fontName="Helvetica"
      fontSize="9"
      alignment="CENTER"
    />
    <paraStyle name="address"
      fontName="Helvetica"
      fontSize="9"
      alignment="CENTER"
    />
</stylesheet>
}
	    }
	}
    }

}

ad_proc -public -callback contact::envelope -impl envelope10 {
    {-request:required}
    {-for ""}
} {
} {
    switch $request {
	ad_form_option {
	    return [list "Envelope \#10 (9.5in x 4.125in)" envelope10]
	}
	template {
	    if { $for == "envelope10" } {
		return {
<template pageSize="(9.5in, 4.125in)"
          leftMargin="0in"
          rightMargin="0in"
          topMargin="0in"
          bottomMargin="0in"
          title="Envelope \#10"
          author="$author"
          allowSplitting="0"
          showBoundary="0"
          >
          <!-- showBoundary means that we will be able to see the            -->
          <!-- limits of frames                                              -->
    <pageTemplate id="main">
        <pageGraphics>
        </pageGraphics>
        <frame id="label01" x1="5.5in" y1=".5in" width="3in" height="1.5in"/>
    </pageTemplate>
</template>
<stylesheet>
    <paraStyle name="name"
      fontName="Helvetica"
      fontSize="12"
      leading="15"
      alignment="LEFT"
    />
    <paraStyle name="address"
      fontName="Helvetica"
      fontSize="12"
      leading="15"
      alignment="LEFT"
    />
</stylesheet>
}
	    }
	}
    }

}
