ad_page_contract {

    Merge two contacts.

    @author Matthew Geddert (openacs@geddert.com)
    @creation-date 2006-01-26
} {
    {party_id:integer}
    {merge_party_id ""}
    {primary:optional}
} -validate {
    contact_exists -requires {party_id} {
	if { ![contact::exists_p -party_id $party_id] } {
	    ad_complain "[_ contacts.lt_The_contact_specified]"
	}
    }
    contact_is_not_me -requires {party_id} {
	if { $party_id == [ad_conn user_id] } {
	    ad_complain "[_ contacts.lt_You_cannot_merge_yourself]"
	}
    }
    merge_contact_is_not_me -requires {merge_party_id} {
	if { $merge_party_id == [ad_conn user_id] } {
	    ad_complain "[_ contacts.lt_You_cannot_merge_yourself]"
	}
    }
    merge_contact_exists -requires {merge_party_id} {
	if { [string is integer $merge_party_id] && [exists_and_not_null merge_party_id] } {
	    if { ![contact::exists_p -party_id $merge_party_id] } {
		ad_complain "[_ contacts.lt_The_contact_specified]"
	    }
	}
    }
    primary_is_valid -requires {primary} {
	if { [lsearch [list party_id merge_party_id] $primary] < 0 } {
	    error "primary was not valid"
	}
    }
}



permission::require_permission -object_id [ad_conn package_id] -privilege "admin"


set title [_ contacts.Merge_Contacts]
set context [list $title]


set party_type [contact::type -party_id $party_id]
set party_url [contact::url -party_id $party_id]
set party_link [contact::link -party_id $party_id]

if { [string is integer $merge_party_id] && [exists_and_not_null merge_party_id] } {

    set display_contacts "1"

    set merge_party_type [contact::type -party_id $merge_party_id]
    set merge_party_url [contact::url -party_id $merge_party_id]
    set merge_party_link [contact::link -party_id $merge_party_id]

    if { $party_type == "user" } {
	set party_last_login [db_string get_it { select last_visit from users where user_id = :party_id } -default {}]
	if { [exists_and_not_null party_last_login] } {
	    set party_last_login [lc_time_fmt $party_last_login "%x %X"]
	}
    }
    if { $merge_party_type == "user" } {
	set merge_party_last_login [db_string get_it { select last_visit from users where user_id = :merge_party_id } -default {}]
	if { [exists_and_not_null merge_party_last_login] } {
	    set merge_party_last_login [lc_time_fmt $merge_party_last_login "%x %X"]
	}
    }


} else {

    set display_contacts "0"



}

if { $party_type == "organization" } {
    set form_type "organizations"
} else {
    set form_type "persons"
}

ad_form -method get -name merge_contacts \
    -form [list [list merge_party_id:contact_search(contact_search) [list label "[_ contacts.Merge_with]"] [list search "$form_type"]]] \
    -on_submit {


	if { $party_id == $merge_party_id } {
	    template::element::set_error merge_contacts merge_party_id "[_ contacts.lt_You_no_merge_with_self]"
	    set display_contacts "0"
	}


    }



if { [exists_and_not_null primary] && [string is true $display_contacts] } {

    if { $primary == "merge_party_id" } {
	# we need to swap the merge_party_id and party_id
	set orig_party_id $party_id
        set party_id $merge_party_id
        set merge_party_id $orig_party_id

    }

    foreach name [ns_cache names util_memoize] {
	ns_cache flush util_memoize $name
    } 


    db_transaction {
	# contact messages
	db_dml update_message_log { update contact_message_log set recipient_id = :party_id where recipient_id = :merge_party_id }
	

	# AMS Attributes
	
	set revision_id [contact::live_revision -party_id $party_id]
	set new_revision_id [contact::revision::new -party_id $party_id]
	ams::object_copy -from $revision_id -to $new_revision_id
	
	set merge_revision_id [contact::live_revision -party_id $merge_party_id]
	ams::object_copy -from $merge_revision_id -to $new_revision_id
	

	# Generic Attributes
	
	db_dml delete_empty_attribute_values "
	    delete from acs_attribute_values where object_id = :party_id and attr_value is null
	"
	

	db_dml update_generic_attributes "

	    insert into acs_attribute_values
	    (object_id,attribute_id,attr_value)
	    ( select :party_id,
	             attribute_id,
                     attr_value
                from acs_attribute_values
               where object_id = :merge_party_id 
                 and attribute_id not in ( select attribute_id from acs_attribute_values where object_id = :party_id and attr_value is not null )
            )

	"

	# we only update email addresses and url if it doesn't exists on the primary party_id
	if { ![db_0or1row get_it " select 1 from parties where party_id = :party_id and email is not null "] } {
	    set email [db_string get_info " select email from parties where party_id = :merge_party_id " -default {}]
	    if { [exists_and_not_null email] } {
		db_dml update_it " update parties set email = NULL where party_id = :merge_party_id "
		db_dml update_it " update parties set email = :email where party_id = :party_id "
		if { [contact::type -party_id $party_id] == "user" } {
		    # db_dml update_it " update users set username = :merge_party_id where user_id = :merge_party_id "
		    # db_dml update_it " update users set username = :email where user_id = :party_id "
		}
	    }
	}
	if { ![db_0or1row get_it " select 1 from parties where party_id = :party_id and url is not null "] } {
	    set url [db_string get_info " select url from parties where party_id = :merge_party_id " -default {}]
	    if { [exists_and_not_null url] } {
		db_dml update_it " update parties set url = NULL where party_id = :merge_party_id "
		db_dml update_it " update parties set url = :url where party_id = :party_id "
	    }
	}


	# files
	db_dml update_it { update acs_objects set context_id = :party_id where object_id in ( select item_id from cr_items where parent_id = :merge_party_id ) }
	db_dml update_it { update cr_items set parent_id = :party_id where parent_id = :merge_party_id }
	

	# cr_child _rels
	db_dml update_it { update acs_objects set context_id = :party_id where object_id in ( select rel_id from cr_child_rels where parent_id = :merge_party_id ) }
	db_dml update_it { update cr_child_rels set parent_id = :party_id where parent_id = :merge_party_id }



	# Tasks
	if { [apm_package_installed_p tasks] } {
	    db_dml update_it { update pm_task_assignment set party_id = :party_id where party_id = :merge_party_id }
	}

	# General Comments
	db_dml update_contexts { update acs_objects set context_id = :party_id where object_id in ( select comment_id from general_comments where object_id = :merge_party_id ) }
	db_dml update_comments { update general_comments set object_id = :party_id where object_id = :merge_party_id }

	# Forums Messages
	# if contacts becomes ubiquitous enough this should be moved to a callback managed by the forums packages
	if { [apm_package_installed_p forums] } {
	    db_dml update_contexts { update acs_objects set creation_user = :party_id where object_id in ( select message_id from forums_messages where user_id = :merge_party_id ) }
	    db_dml update_messages { update forums_messages set user_id = :party_id where user_id = :merge_party_id }
	}
	

	# Notifications
	# if contacts becomes ubiquitous enough this should be moved to a callback managed by the notifications package
	if { [apm_package_installed_p notifications] } {
	    
	    if { [contact::type -party_id $party_id] == "user" } {
		set update_user_info 1
	    } else {
		set update_user_info 0
	    }
	    
	    db_foreach get_all_notifications { select * from notification_requests where user_id = :merge_party_id } {
		set existing_request_id [db_string get_it " select request_id from notification_requests where type_id = :type_id and user_id = :party_id and object_id = :request_id " -default {}]
		if { ![exists_and_not_null existing_request_id] } {
		    db_dml update_it " update notification_requests set user_id = :party_id where request_id = :request_id "
		    if { [string is true $update_user_info] } {
			db_dml update_it " update acs_objects set creation_user = :party_id where object_id = :request_id "
		    }
		}
	    }
	    
	}


	callback contacts::merge -from_party_id $merge_party_id -to_party_id $party_id


        set rels [db_list_of_lists get_them " select rel_id, rel_type, object_id_one, object_id_two  from acs_rels where ( object_id_one = :merge_party_id or object_id_two = :merge_party_id )"]
	foreach rel $rels {
	    util_unlist $rel rel_id rel_type object_id_one object_id_two
	    if { $object_id_one == $merge_party_id } {
		set object_id_one $party_id
	    } else {
		set object_id_two $party_id
	    }
	    set existing_rel_id [db_string existing_p " select rel_id from acs_rels where rel_type = :rel_type and object_id_one = :object_id_one and object_id_two = :object_id_two " -default {}]
	    if { ![exists_and_not_null existing_rel_id] } {
		db_dml update_it " update acs_rels set object_id_one = :object_id_one, object_id_two = :object_id_two where rel_id = :rel_id "
	    } else {
		ams::object_copy -from $rel_id -to $existing_rel_id
                # delete rel
		db_1row delete_it { select acs_rel__delete(:rel_id) }
	    }
	}

	# Application data links
	set party_links [application_data_link::get -object_id $party_id]
	foreach linked_object_id [application_data_link::get -object_id $merge_party_id] {
	    if { [lsearch $party_links $linked_object_id] < 0 } {
		application_data_link::new -this_object_id $party_id -target_object_id $linked_object_id
	    }
	}
	application_data_link::delete_links -object_id $merge_party_id


	# first we delete the contact_party_revisions
	db_dml update_it { update cr_items set live_revision = NULL, latest_revision = NULL where item_id = :merge_party_id }
	db_list do_it { select content_revision__delete(revision_id) from cr_revisions where item_id = :merge_party_id }
	db_dml delete_item { delete from cr_items where item_id = :merge_party_id }

	# now we delete group membership
	db_list do_it { select acs_rel__delete(rel_id) from acs_rels where object_id_one = :merge_party_id or object_id_two = :merge_party_id }

	# now we update creation_user logs
	db_dml update_it { update acs_objects set creation_user = :party_id where creation_user = :merge_party_id }
	db_dml update_it { update acs_objects set modifying_user = :party_id where modifying_user = :merge_party_id }

	db_dml update_it { update group_element_index set element_id = :party_id where element_id = :merge_party_id }
	db_dml update_it { delete from party_approved_member_map where party_id = :merge_party_id and member_id = :merge_party_id }
	db_dml update_it { update party_approved_member_map set member_id = :party_id where member_id = :merge_party_id }
	db_dml update_it { update party_approved_member_map set party_id = :party_id where party_id = :merge_party_id }


	if { [contact::type -party_id $merge_party_id] == "user" } {
	    # nuke the user from the database
	    acs_user::delete -user_id $merge_party_id -permanent
	} else {
	    db_dml delete_org_type { delete from organization_type_map where organization_id = :merge_party_id }
	    db_exec_plsql permanent_delete { select acs_object__delete(:merge_party_id)  }
	}

    } on_error {
	# something went wrong. this site might need a custom contacts::merge callback
	ad_return_error "Error." $errmsg
	ad_script_abort
    }

    foreach name [ns_cache names util_memoize] {
	ns_cache flush util_memoize $name
    } 
    contact::flush -party_id $party_id
    contact::flush -party_id $merge_party_id

    util_user_message -message "[_ contacts.lt_The_contacts_were_merged]"
    ad_returnredirect [contact::url -party_id $party_id]
    ad_script_abort
    


}


ad_return_template
