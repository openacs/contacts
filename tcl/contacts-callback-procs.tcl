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

ad_proc -public -callback contact::contact_form_after_submit {
    {-package_id:required}
    {-form:required}
    {-object_type:required}
    {-party_id:required}
} {
    After the contact-edit and/or contact-add form have been completely submitted,
    and data has been flushed you can do something for your site.
} -

ad_proc -public -callback contacts::multirow::extend {
    {-type}
    {-key}
    {-select_query}
    {-format "html"}
} {
} -

ad_proc -public -callback contacts::merge {
    {-from_party_id:required}
    {-to_party_id:required}
} {
    This callback is executed when merging two contacts. Packages should move all information
    from the from_party_id to the to_party_id. Contacts will attempt to delete the from_party_id
    at the end of the merge process. DO NOT USE db_foreach AND PUT UPDATES IN IT. The merge
    is done within a db_transaction and if you use db_foreach and do updates within that the 
    database hangs. You should use db_list_of_lists and then foreach the tcl list to perform updates
} -

ad_proc -public -callback contacts::extensions {
    {-multirow}
    {-user_id}
    {-package_id}
    {-object_type "party"}
} {
} -

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
    {-package_id:required}
} {
    This is a callback that is executed when you add a new person in a relationship to an organization.
    This will enable other packages to check if the person is added into a special relationship with the 
    organization and then do something with them accordingly.
} -

ad_proc -public -callback contact::organization_new_rel {
    {-party_id:required}
    {-object_id_two:required}
    {-rel_type:required}
    {-package_id:required}
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

ad_proc -public -callback contact::contact_rels {
} {
    This callback is executed in the relationship add page.
    It is used to extend the display so you could add additional attributes 
    That make clear e.g. which organization or user you are talking about.
} - 

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
	    set value [string trim [template::element::get_value $form $element]]
	    switch $element {
		email {
		    if { [contact::type -party_id $party_id] eq "user" } {
			# if the system uses email for username we need to update it
                        if { [string is true [auth::UseEmailForLoginP]] } {
			    if {[exists_and_not_null value]} {
				set username $value
			    } else {
				set username $party_id
			    }
			    acs_user::update -user_id $party_id -username $username
			}
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
	set project_id [db_string get_linked_project_id {
	    select r.object_id_two as project_id
	    from acs_data_links r, cr_items p
	    where r.object_id_one = :folder_id
	    and r.object_id_two = p.item_id
	    and p.content_type = 'pm_project'
	} -default ""]
    }

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
	upvar return_url return_url_loc
	set return_url_loc "[ad_conn url]?[ad_conn query]"
	set contact_ids_loc $contact_list

	lappend local_var "[_ contacts.Mail_to_contact]" "/contacts/message" "[_ contacts.Mail_to_contact]"
	lappend local_list "party_ids" "return_url"
	
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


ad_proc -public -callback contacts::multirow::extend -impl attributes {
    {-type}
    {-key}
    {-select_query}
    {-format "html"}
} {
} {
    if { $format ne "text" } {
	set format "html"
    }

    set object_type $type
    set results [list]
    if { $object_type eq "party" && [lsearch [list email url] $key] >= 0 } {
	db_foreach get_party_info " select $key as value, party_id from parties where party_id in ( $select_query ) " {
	    if { $format eq "html" && $value ne "" } {
		set value [ad_html_text_convert -from "text/plain" -to "text/html" -- $value]
	    }
	    lappend results $party_id $value
	}
    } elseif { $object_type eq "person" && [lsearch [list first_names last_name] $key] >= 0 } {
	db_foreach get_person_info " select person_id, $key as value from persons where person_id in ( $select_query ) " {
	    lappend results $person_id $value
	}
    } elseif { $object_type eq "organization" && [lsearch [list name legal_name reg_number notes] $key] >= 0 } {
	db_foreach get_organization_info " select organization_id, $key as value from organizations where organization_id in ( $select_query ) " {
	    lappend results $organization_id $value
	}
    } elseif { [lsearch [list party person organization] $object_type] >= 0 } {
	set attribute_name $key
	# now we check for a sub_attribute
	regexp {^(.*)__(.*)$} $attribute_name match attribute_name sub_attribute_name

	set attribute_id [attribute::id -object_type $object_type -attribute_name $attribute_name]
	if { [db_0or1row get_attribute_info { select aa.*, aw.value_method from ams_attributes aa, ams_widgets aw where aa.widget = aw.widget and aa.attribute_id = :attribute_id }] } {

	    db_foreach get_ams_values "
select ci.item_id as party_id, ${value_method}(aav.value_id) as value
  from ams_attribute_values aav,
       cr_items ci
 where aav.attribute_id = $attribute_id
   and aav.object_id = ci.live_revision
   and ci.item_id in ( $select_query )
            " {

		if { [info exists sub_attribute_name] } {
		    array set sub_attribute_values [ams::widget -widget $widget -request "value_list_${format}" -attribute_name $attribute_name -attribute_id $attribute_id -value $value]
		    if { [info exists sub_attribute_values($sub_attribute_name)] } {
			set value $sub_attribute_values($sub_attribute_name)
			lappend results $party_id $value
		    } else {
			# an invalid sub_attribute_name was specified
			error "error in callback contacts::multirow::extend -impl attributes, an invalid sub_attribute_name of '$sub_attribute_name' was specified"
		    }
		} else {
		    lappend results $party_id [ams::widget -widget $widget -request "value_${format}" -attribute_name $attribute_name -attribute_id $attribute_id -value $value]
		}

	    }
	}
    }
    return $results
}


ad_proc -public -callback contacts::extensions -impl attributes {
    {-multirow}
    {-user_id}
    {-package_id}
    {-object_type}
} {
} {

    set list_ids [contact::util::get_ams_list_ids -user_id $user_id -package_id $package_id -privilege "read" -object_type $object_type]

    if { [llength $list_ids] == 0 } {
	return {}
    }

    if { $object_type ne "party" } {
	set object_type_clause "and object_type in ('party','${object_type}')"
    } else {
	set object_type_clause ""
    }

    set attr_list [db_list_of_lists get_all_attributes "
select pretty_name, object_type, attribute_name, widget
  from ams_attributes
 where attribute_id in ( select attribute_id
                           from ams_list_attribute_map
                          where list_id in ([template::util::tcl_to_sql_list $list_ids])
                       )
   $object_type_clause
   and not deprecated_p
    "]

    set attr_list [ams::util::localize_and_sort_list_of_lists -list $attr_list -position 0]
    # now that its sorted by attribute_name, we sort it
    # by object_type, lsort leaves the same order
    # as the previous sort if the new sort is tied
    # so this keeps the attributes ordered alphabetically
    # by type
    set attr_list [lsort -dictionary -index 1 $attr_list]
    
    # now we want to first get the sort by
    foreach attr $attr_list {
	util_unlist $attr pretty_name object_type attribute_name widget
	switch $object_type {
	    party { set type_pretty [_ contacts.Contact] }
	    person { set type_pretty [_ contacts.Person] }
	    organization { set type_pretty [_ contacts.Organization] }
	}
	append type_pretty " [_ contacts.Attributes]"
	
	set sub_attributes_list [ams::widget -widget $widget -request value_list_headings]
	
	if { [llength $sub_attributes_list] > 0 } {
	    foreach {sub_attribute_name sub_pretty_name} $sub_attributes_list {
		template::multirow append $multirow attribute $object_type $type_pretty "${attribute_name}__${sub_attribute_name}" "${pretty_name}: ${sub_pretty_name}"
	    }
	} else {
	    template::multirow append $multirow attribute $object_type $type_pretty $attribute_name $pretty_name
	}
	
    }

}

ad_proc -public -callback contacts::multirow::extend -impl relationships {
    {-type}
    {-key}
    {-select_query}
    {-format "html"}
} {
} {
    if { $type eq "relationships" } {
	if { $format ne "text" } {
	    set format "html"
	}
	# now we need to figure out what ends of a relationship this role can be
	set object_one_types [list]
	set object_two_types [list]
	db_foreach get_types "
	    select *
              from acs_rel_types
             where ( role_one = :key or role_two = :key )
               and rel_type like ('contact_rels_%')
	" {
	    if { $role_one eq $key } {
		lappend object_one_types $rel_type
	    }
	    if { $role_two eq $key } {
		lappend object_two_types $rel_type
	    }
	}
	set query ""
	if { [llength $object_one_types] > 0 } {
	    append query "
            select object_id_two as party_id,
                   object_id_one as related_party_id
              from acs_rels
             where rel_type in ([template::util::tcl_to_sql_list $object_one_types])
               and object_id_two in ( $select_query )
            "
	    if { [llength $object_two_types] > 0 } {
		append query "union\n"
	    }
	}
	if { [llength $object_two_types] > 0 } {
	    append query "
            select object_id_one as party_id,
                   object_id_two as related_party_id
              from acs_rels
             where rel_type in ([template::util::tcl_to_sql_list $object_two_types])
               and object_id_one in ( $select_query )
            "
	}
	db_foreach get_roles $query {
	    if { [info exists roles_list($party_id)] } {
		lappend roles_list($party_id) [contact::name -party_id $related_party_id] 
	    } else {
		set roles_list($party_id) [list [contact::name -party_id $related_party_id]]
	    }
	}
	if { ![array exists roles_list] } {
	    return [list]
	} else {
	    set results [list]
	    foreach {party_id related_parties} [array get roles_list] {
		lappend results $party_id [join [lsort -dictionary $related_parties] ", "]
	    }
	    return $results
	}
    }
    return [list]
}


ad_proc -public -callback contacts::extensions -impl relationships {
    {-multirow}
    {-user_id}
    {-package_id}
    {-object_type}
} {
} {

    switch $object_type {
	person { set object_types [list person party] }
	organization { set object_types [list organization party] }
	default { set object_types [list person organization party] }
    }

    # we might want to add different variables here, such as
    # quantity of related roles, true/false for exists, etc.

    set role_types [db_list_of_lists get_roles "
	select role, pretty_plural
          from acs_rel_roles
         where ( role in ( 
                 select role_one
                   from acs_rel_types
                  where rel_type like ('contact_rels_%')
                    and object_type_two in ([template::util::tcl_to_sql_list $object_types])
                ) or (
                 role in (
                 select role_two
                   from acs_rel_types
                  where rel_type like ('contact_rels_%')
                    and object_type_one in ([template::util::tcl_to_sql_list $object_types]) 
                )
                ))
    "]

    set role_types [ams::util::localize_and_sort_list_of_lists -list $role_types -position 1]
    set relationships_pretty [_ contacts.Relationships]
    foreach role_type $role_types {
	# util_unlist $role_type role pretty_plural
	template::multirow append $multirow relationships relationships $relationships_pretty [lindex $role_type 0] [lindex $role_type 1]
    }
}

ad_proc -public -callback contacts::multirow::extend -impl groups {
    {-type}
    {-key}
    {-select_query}
    {-format "html"}
} {
} {
    set results [list]
    if { $type eq "groups" && [string is integer $key] && $key ne ""} {
	set true [_ contacts.True]
	set false [_ contacts.False]
	db_foreach get_group_members "
	    select parties.party_id,
                   gm.member_id
              from parties left join ( select member_id from group_approved_member_map where group_id = :key ) gm on (parties.party_id = gm.member_id)
             where parties.party_id in ( $select_query )
	" {
	    if { $member_id eq "" } {
		# they are a not member
		lappend results $party_id $false
	    } else {
		lappend results $party_id $true
	    }
	}
    }
    return $results
}


ad_proc -public -callback contacts::extensions -impl groups {
    {-multirow}
    {-user_id}
    {-package_id}
    {-object_type}
} {
} {
    set groups_list [list]
    foreach group [contact::groups_list -package_id $package_id] {
	util_unlist $group group_id group_name member_count component_count mapped_p default_p
	if { [string is true $mapped_p] } {
	    if { [permission::permission_p -object_id $group_id -party_id $user_id -privilege "read"] } {
		lappend groups_list [list $group_id $group_name]
	    }
	}
    }
    if { [llength $groups_list] > 0 } {
	set groups_pretty [_ contacts.Groups]
	foreach group [ams::util::localize_and_sort_list_of_lists -list $groups_list -position "1"] {
	    util_unlist $group group_id group_name
	    template::multirow append $multirow groups groups $groups_pretty $group_id $group_name
	}
    }
}

ad_proc -public -callback contacts::multirow::extend -impl privacy {
    {-type}
    {-key}
    {-select_query}
    {-format "html"}
} {
} {
    set results [list]
    if { $type eq "privacy" } {
	set true [_ contacts.True]
	set false [_ contacts.False]
	db_foreach get_group_members "
	    select party_id,
                   $key as permission_p
              from contact_privacy
             where party_id in ( $select_query )
	" {
	    if { $permission_p } {
		lappend results $party_id $false
	    } else {
		lappend results $party_id $true
	    }
	}
    }
    return $results
}


ad_proc -public -callback contacts::extensions -impl privacy {
    {-multirow}
    {-user_id}
    {-package_id}
    {-object_type}
} {
} {
    if { [parameter::get -boolean -package_id $package_id -parameter "ContactPrivacyEnabledP" -default "0"] } {
	set pretty_group [_ contacts.Privacy_Settings]
	template::multirow append $multirow privacy privacy $pretty_group gone_p  [_ contacts.Closed_down_or_deceased]
	template::multirow append $multirow privacy privacy $pretty_group email_p [_ contacts.Do_not_email]
	template::multirow append $multirow privacy privacy $pretty_group mail_p [_ contacts.Do_not_mail]
	template::multirow append $multirow privacy privacy $pretty_group phone_p [_ contacts.Do_not_phone]
    }
}

ad_proc -public -callback contacts::redirect -impl contactspdfs {
    {-party_id ""}
    {-action ""}
} {
    redirect the contact to the correct pdf stuff
} {

    set url [ad_conn url]
    if { [regexp "^[ad_conn package_url]pdfs/" $url match] } {
	# this is a pdf url
	set filename [lindex [ad_conn urlv] end]
	if { ![regexp "^contacts_.*?_[ad_conn user_id](.*).pdf$" $filename match] || ![file exists "/tmp/${filename}"] } {
	    ad_return_error "No Permission" "You do not have permission to view this file, or the temporary file has been deleted."
	} else {
	    ns_returnfile 200 "application/pdf" "/tmp/${filename}"
            # now that we have displayed the file we can delete it
            # if a user does not click on the display link
            # the file will remain in the /tmp/ folder until its 
            # cleared. We may want to sweep the /tmp/ directory
            # every now and then to delete stale files.
            file delete "/tmp/${filename}"

	}
    }

}


ad_proc -public -callback contact::contact_form_after_submit -impl spouse_sync {
    -party_id:required
    -package_id:required
    -object_type:required
    -form:required
} {
    Sync information from a spousal relationship (if such a relationship exists)
} {
    if { [contacts::spouse_enabled_p -package_id $package_id] } {
	# the special spousal relationship exists
	set spouse_id [contact::spouse_id_not_cached -party_id $party_id]
	if { $spouse_id ne "" } {
	    # this party has a spouse, the edit form has already save
            # all of the attributes for the party so we only need to save
            # attributes for the spouse

	    set party_revision_id [contact::live_revision -party_id $party_id]

	    set spouse_revision_id [contact::live_revision -party_id $spouse_id]
	    set new_spouse_revision_id [contact::revision::new -party_id $spouse_id]
	    ams::object_copy -from $spouse_revision_id -to $new_spouse_revision_id

	    set attribute_ids [contacts::spouse_sync_attribute_ids -package_id [ad_conn package_id]]
	    foreach attribute_id $attribute_ids {
		set value_id [db_string get_value_id { select value_id from ams_attribute_values where attribute_id = :attribute_id and object_id = :party_revision_id } -default {}]
		ams::attribute::value_save -object_id $new_spouse_revision_id -attribute_id $attribute_id -value_id $value_id
	    }

	    set spouse_link [contact::link -party_id $spouse_id]
	    util_user_message -html -message [_ contacts.lt_spouse_spouse_link_was_updated]

	    if { [parameter::get -boolean -package_id $package_id -parameter "ContactPrivacyEnabledP" -default "0"] } {
		# we copy privacy settings from the most recently edited contact, i.e. party_id
                # UNLESS this person is deceased
		if { [db_0or1row get_info { select * from contact_privacy where party_id = :party_id and gone_p is false }] } {
		    db_dml update_privacy { update contact_privacy
                                               set email_p = :email_p,
                                                   mail_p = :mail_p,
                                                   phone_p = :phone_p
                                             where party_id = :party_id
                                               and gone_p is false }
		}
	    }

	    contact::flush -party_id $spouse_id
	    contact::search::flush_results_counts

	}
    }
}
