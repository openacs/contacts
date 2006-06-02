ad_library {

    Support procs for the contacts package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
}

namespace eval contacts:: {}
namespace eval contact:: {}
namespace eval contact::util:: {}
namespace eval contact::group:: {}
namespace eval contact::revision:: {}
namespace eval contact::rels:: {}
namespace eval contacts::person:: {}
namespace eval contact::special_attributes {}

ad_proc -public contacts::default_group {
    {-package_id ""}
} {
    Returns the default group_id a contacts instance. Cached.
} {
    if {[string is false [exists_and_not_null package_id]]} {
	set package_id [ad_conn package_id]
    }
    return [util_memoize [list contacts::default_group_not_cached -package_id $package_id]]
}

ad_proc -private contacts::default_group_not_cached {
    {-package_id:required}
} {
    Returns the default group_id a contacts instance.
} {
    if { [string is true [parameter::get -package_id $package_id -parameter "UseSubsiteAsDefaultGroup" -default "0"]] } {
	# we cannot trust ad_conn subsite_id because instances may be asking for subsites of numerous other packages.
        set node_id [site_node::get_node_id_from_object_id -object_id $package_id]
        set package_id [db_string get_parent_subsite_id {}]
    }

    set group_id [application_group::group_id_from_package_id -no_complain -package_id $package_id]
    if {[string eq "" $group_id]} {
        # application_group should not be empty unless contacts
	set group_id "-2"
    }
    return $group_id
}


ad_proc -public contacts::default_groups {
    {-package_id ""}
} {
    Returns a list of group_ids that this instance searches for. Cached.
} {
    if { [string is false [exists_and_not_null package_id]] } {
	set package_id [ad_conn package_id]
    }
    return [util_memoize [list contacts::default_groups_not_cached -package_id $package_id]]
}

ad_proc -private contacts::default_groups_not_cached {
    {-package_id:required}
} {
    Returns a list of group_ids that this instance searches for.
} {
    if { [parameter::get -package_id $package_id -parameter "IncludeChildPackages" -default "0"] } {
        set node_id [site_node::get_node_id_from_object_id -object_id $package_id]
        set parent_node_id [site_node::get_parent_id -node_id $node_id]
        # this search currently does not differentiate between child
        # instances mounted on subsites or on other packages. Don't
        # know if this is good or bad... matthewg
	set package_ids [db_list get_child_contacts_instances {}]
	set package_ids [concat $package_id $package_ids]
	set group_ids [list]
	foreach package_id $package_ids {
	    lappend group_ids [contacts::default_group -package_id $package_id]
	}
	return [lsort -unique $group_ids]
    } else {
	return [contacts::default_group -package_id $package_id]
    }
}

ad_proc -private contacts::sweeper {
} {
    So that contacts searches work correctly, and quickly
    every person or organization in the system
    needs an associated content_item and live revision
    this could be done with left joins on persons and organizations
    tables but its slower so we create the necessary item_ids
    for person or organization objects that were not created
    by contacts (ones created by contacts automatically get
    associated item_id and live_revisions.
} {
    db_foreach get_persons_without_items {} {
	ns_log notice "contacts::sweeper creating content_item and content_revision for party_id: $person_id"
	contact::revision::new -party_id $person_id
    }
    db_foreach get_organizations_without_items {} {
	ns_log notice "contacts::sweeper creating content_item and content_revision for organization_id: $organization_id"
	contact::revision::new -party_id $organization_id
    }
    if { ![info exists person_id] && ![info exists organization_id] } {
	ns_log notice "contacts::sweeper no person or organization objects exist that do not have associated content_items"
    }
    db_dml insert_privacy_records {}
}

ad_proc -public contacts::multirow {
    {-extend ""}
    {-multirow}
    {-select_query}
    {-party_id_column "party_id"}
    {-format "html"}
} {
    This procedure extends a contacts multirow by the type.key pairs specified as 
    a list as the extend param. The supplied select query will return a list of
    party_ids to the callback proc... this proc is then to use the subselct
    in their retrieval of the values requested. A list of lists, i.e.
    {{party_id1 value1} {party_id2 value2}}
    this procedure then takes that list of lists and matches values with parties
    and extends the multirow provided with those values
} {
    if { $format ne "text" } {
	set format "html"
    }
    foreach id $extend {
	set ${id}__list ""
	regexp {^(.*?)__(.*)$} $id match type key
	set results [callback contacts::multirow::extend -type $type -key $key -select_query $select_query -format $format]
	foreach result $results {
	    if { $result ne "" } {
		array set "${id}__array" $result
	    }
	}
	template::multirow extend $multirow $id
    }
    template::multirow foreach $multirow {
	foreach id $extend {
	    if { [info exists ${id}__array([set ${party_id_column}])] } {
		set $id [set ${id}__array([set ${party_id_column}])]
	    }
	}
    }
}

ad_proc -public contacts::spouse_sync_attribute_ids {
    {-package_id:required}
} {
    Get the attribute_ids to keep in sync for the contact_rels_spouse relationship
} {
    set attribute_ids [list]
    foreach attribute [parameter::get -parameter "SpouseSyncedAttributes" -default "" -package_id $package_id] {
	if { [string is integer $attribute] } {
	    lappend attribute_ids $attribute
	} else {
	    set person_attribute_id [attribute::id -object_type person -attribute_name ${attribute}]
	    if { $person_attribute_id ne "" } {
		lappend attribute_ids $person_attribute_id
	    } else {
		set party_attribute_id [attribute::id -object_type party -attribute_name ${attribute}]
		if { $party_attribute_id ne "" } {
		    lappend attribute_ids $party_attribute_id
		}
	    }
	}
    }

    if { [llength $attribute_ids] == "0" } {
	return {}
    } else {
	# now we have a list of attribute_ids, we verify that they in are in fact valid by searching
	# for those attributes that have widgets
	return [db_list get_valid_attribute_ids {}]
    }

}

ad_proc -public contacts::spouse_enabled_p {
    {-package_id ""}
} {
    Is the special contact_rels_spouse enabled for this contacts instance. Cached.
} {
    if { [string is false [exists_and_not_null package_id]] } {
	set package_id [ad_conn package_id]
    }
    
    if { [util_memoize [list contacts::spouse_rel_type_enabled_p -package_id $package_id]] } {
	# parameter get is cached
	set spouse_synced_attributes [util_memoize [list contacts::spouse_sync_attribute_ids -package_id $package_id]]
	if { [llength $spouse_synced_attributes] > 0 } {
	    return 1
	}
    }
    return 0

}

ad_proc -public contacts::spouse_rel_type_enabled_p {
    {-package_id:required}
} {
    Does the special contact_rels_spouse exist.
} {
    return [db_0or1row rel_type_enabled_p {}]
}

ad_proc -public contact::privacy_allows_p {
    {-party_id:required}
    {-type:required}
    {-package_id ""}
} {
    @param party_id the party_id to check permission for
    @param type either 'email', 'mail' or 'phone'
    @returns 1 or 0 if the specified type of communication is allowed
} {
    if { [parameter::get -boolean -package_id $package_id -parameter "ContactPrivacyEnabledP" -default "0"] } {
	if { $package_id eq "" } {
	    if { [ad_conn package_key] eq "contacts" } {
		set package_id [ad_conn package_id]
	    } else {
		error "You must specify a valid contacts package id if your are accessing this procedure from a package other than contacts"
	    }
	}
	if { [lsearch [list email mail phone] $type] < 0 } {
	    error "contact::privacy_allows_p, you specified an invalid type: '${type}' (you must specify, email, mail or phone)"
	}
	if { [db_string is_type_allowed_p {} -default {1}] } {
	    return 1
	} else {
	    return 0
	}
    }
    # by default permission is allowed
    return 1
}

ad_proc -public contact::privacy_prevents_p {
    {-party_id:required}
    {-type:required}
    {-package_id ""}
} {
    @param party_id the party_id to check permission for
    @param type either 'email', 'mail' or 'phone'
    @returns 1 or 0 if the specified type of communication is allowed
} {
    if { [contact::privacy_allows_p -party_id $party_id -type $type -package_id $package_id] } {
	return 0
    } else {
	return 1
    }
}

ad_proc -public contact::privacy_set {
    {-party_id:required}
    {-email_p:required}
    {-mail_p:required}
    {-phone_p:required}
    {-gone_p:required}
} {
} {
    db_transaction {
	if { [db_0or1row record_exists_p {}] } {
	    db_dml update_privacy {}
	} else {
	    db_dml insert_privacy {}
	}
    }
}

ad_proc -private contact::util::generate_filename {
    {-title:required}
    {-extension:required}
    {-existing_filenames ""}
    {-party_id ""}
} {
    Generate a pretty filename that relates to the title supplied

    @param party_id if supplied the filenames associated with this party will be used as existing_filenames if existing filenames is not provided

    @param existing_filenames a list of filenames that the generated filename must not be equal to
} {
    if {[exists_and_not_null party_id] 
	&& [string is integer $party_id] && ![exists_and_not_null existing_filenames]} {
	set existing_filenames [db_list get_parties_existing_filenames {}]
    }
    set filename [util_text_to_url \
		      -text ${title} -replacement "_"]
    set output_filename "${filename}.${extension}"
    set num 1
    while {[lsearch $existing_filenames $output_filename] >= 0} {
	set output_filename "${filename}${num}.${extension}"
	incr num
    }
    return $output_filename
}

ad_proc -private contact::util::get_file_extension {
    {-filename:required}
} {
    get the file extension from a file
} {
    return [lindex [split $filename "."] end]
}

ad_proc -private contact::util::update_person_attributes {
} {
    Updates the person attributes first_names, last_name, email for people who have not been entered using contacts
} {
    db_foreach persons {select latest_revision as object_id, first_names, last_name, email from persons, parties,cr_items where person_id = party_id and person_id = item_id} {
	ams::attribute::save::text -object_id $object_id -attribute_name "first_names" -value "$first_names" -object_type "person"
	ams::attribute::save::text -object_id $object_id -attribute_name "last_name"  -value "$last_name" -object_type "person"
	ams::attribute::save::text -object_id $object_id -attribute_name "email" -value "$email" -object_type "person"
    }
}


ad_proc -public contact::util::get_ams_list_ids {
    {-user_id ""}
    {-package_id ""}
    {-privilege:required}
    {-object_type "party"}
} {
    Get a list of ams_list_ids that the user has the provided privilege on for the provided object_type

    @return List of ams list ids the provided user has the privilege for
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }
    if { $user_id eq "" } {
	set user_id [ad_conn user_id]
    }
    if { [lsearch [list party organization person user] $object_type] < 0 } {
	error "You supplied an invalid object_type to contact::util::get_ams_list_ids"
    }
    if { $object_type eq "user" } {
	set object_type "person"
    }

    set list_ids [list]
    set group_ids [list]
    foreach group [contact::groups_list -package_id $package_id] {
	lappend group_ids [lindex $group 0]
    }
    # since contact::groups_list doesn't get the default_groups
    # we have to add them here
    set group_ids [concat $group_ids [contacts::default_groups -package_id $package_id]]

    foreach group_id $group_ids {
	if { ![permission::permission_p -object_id $group_id -party_id $user_id -privilege $privilege] } {
	    continue
	}
	if { $object_type ne "organization" } {
	    set list_id [ams::list::get_list_id \
			     -package_key "contacts" \
			     -object_type "person" \
			     -list_name "${package_id}__${group_id}"]
	    if { $list_id ne "" } {
		lappend list_ids $list_id
	    }
	}
	if { $object_type ne "person" } {
	    set list_id [ams::list::get_list_id \
			     -package_key "contacts" \
			     -object_type "organization" \
			     -list_name "${package_id}__${group_id}"]
	    if { $list_id ne "" } {
		lappend list_ids $list_id
	    }
	}
    }
    return $list_ids

}



ad_proc -public contact::salutation {
    {-party_id:required}
    {-type salutation}
} {
    Get salutation string.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-12-12
    @param party_id The ID of the party whose information you wish to retrieve.
    @param type either salutation or letter

    @return salutation / sticker salutation string.
} {
    return [util_memoize [list ::contact::salutation_not_cached -party_id $party_id -type $type]]
}

ad_proc -private contact::salutation_not_cached {
    {-party_id:required}
    {-type salutation}
} {
    Get salutation string.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-12-12
    @param party_id The ID of the party whose information you wish to retrieve.
    @param type either salutation or letter

    @return salutation / sticker salutation string.
} {
    # Check if ID belongs to a person
    if {![person::person_p -party_id $party_id]} {
	if {$type == "salutation"} {
	    # standard salutation
	    return "Sehr geehrte Damen und Herren"
	} else {
	    # empty sticker salutation for organizations
	    return
	}
    }

    set locale [lang::user::site_wide_locale -user_id $party_id]
    set revision_id [content::item::get_best_revision -item_id $party_id]
    foreach attribute [list "first_names" "last_name" "salutation" "person_title"] {
	set value($attribute) [string trim [ams::value -object_id $revision_id -attribute_name $attribute -locale $locale]]
    }

    if {$type == "salutation"} {
	# long salutation (though still without the first name)
	return "$value(salutation) [string trim "$value(person_title) $value(last_name)"]"
    } else {
	# short sticker salutation
	set name [string trim "$value(first_names) $value(last_name)"]
	return "- [string trim "$value(person_title) $name"] -"
    }
}


ad_proc -private contact::flush {
    {-party_id:required}
} {
    Flush memorized information related to this contact
} {
    util_memoize_flush "acs_object_type $party_id"
    util_memoize_flush_regexp "contact(.*?)${party_id}"
    # in order to flush person::name and any other
    # procs that may show up there we also flush person
    # procs for this party_id
    util_memoize_flush_regexp "person(.*?)${party_id}"
}

ad_proc -public contact::name {
    {-party_id:required}
    {-reverse_order:boolean}
} {
    this returns the contact's name. Cached
} {
    return [util_memoize [list ::contact::name_not_cached -party_id $party_id -reverse_order_p $reverse_order_p]]
}

ad_proc -public contact::name_not_cached {
    {-party_id:required}
    {-reverse_order_p:required}
} {
    this returns the contact's name
} {
    if {[person::person_p -party_id $party_id]} {
	if {$reverse_order_p} {
	    set person_info [db_string get_person_name {select last_name || ', ' || first_names from persons where person_id = :party_id} -default ""]
	} else {
	    set person_info [person::name -person_id $party_id]
	}
	return $person_info
    } else {
	# if there is an org the name is returned otherwise we search for a grou,
	# if there is no group null is returned
	set name [db_string get_org_name {select name from organizations where organization_id = :party_id} -default ""]
	if { [empty_string_p $name] } {
	    set name [db_string get_group_name {select group_name from groups where group_id = :party_id} -default {}]
	} else {
	    return $name
	}

    }
}

ad_proc -public contact::email {
    {-party_id:required}
} {
    this returns the contact's name. Cached
} {
    return [util_memoize [list ::contact::email_not_cached -party_id $party_id]]
}

ad_proc -public contact::email_not_cached {
    {-party_id:required}
} {
    this returns the contact's name
} {
    # we should use party::email here but 
    # we need to wait for the new version of
    # acs-subsite to be release to remove
    # the dependence on contacts which
    # would cause an infinit loop
    set email [cc_email_from_party $party_id]
    if { ![exists_and_not_null email] } {
	# we check if there is an ams_attribute_valued email address for this party
	set attribute_id [attribute::id -object_type "party" -attribute_name "email"]
	set revision_id [contact::live_revision -party_id $party_id]
	if { [exists_and_not_null revision_id] } {
	    set email [ams::value -object_id $revision_id -attribute_id $attribute_id]
	}
    }
    return $email
}

ad_proc -public contact::link {
    {-party_id:required}
} {
    this returns the contact's name. Cached
} {
    set contact_name [contact::name -party_id $party_id]
    if { ![empty_string_p $contact_name] } {
        set contact_url [contact::url -party_id $party_id]
        return "<a href=\"${contact_url}\">${contact_name}</a>"
    } else {
        return {}
    }
}

ad_proc -public contact::type {
    {-party_id:required}
} {
    returns the contact type
} {
    set object_type [util_memoize [list acs_object_type $party_id]]
    if { [lsearch [list person user organization] $object_type] >= 0 } {
	return $object_type
    } else {
	return ""
    }
}

ad_proc -public contact::exists_p {
    {-party_id:required}
} {
    does this contact exist?
} {
    # persons can be organizations so we need to do the check this way
    set object_type [contact::type -party_id $party_id]
    if { [lsearch [list person user organization] $object_type] >= 0 } {
	return 1
    } else {
	return 0
    }
}

ad_proc -public contact::user_p {
    {-party_id:required}
} {
    is this party a user? Cached
} {
    if { [contact::type -party_id $party_id] == "user" } {
	return 1
    } else {
	return 0
    }
}

ad_proc -public contact::require_visiblity {
    {-party_id:required}
    {-package_id ""}
} {
} {
    if { [string is false [contact::visible_p -party_id $party_id -package_id $package_id]] } {
	# we return not found because we cannot sepecify whether or
        # not the contact exists to the user for privacy reasons
        # locations such as hospitals, etc.
	ns_returnnotfound
	ad_script_abort
    }
}

ad_proc -public contact::visible_p {
    {-party_id:required}
    {-package_id ""}
} {
    Is the contact visible to the specified package. Cached.
} {
    if { [string is false [exists_and_not_null package_id]] } {
	set package_id [ad_conn package_id]
    }
    return [util_memoize [list ::contact::visible_p_not_cached -party_id $party_id -package_id $package_id]]
}

ad_proc -private contact::visible_p_not_cached {
    {-party_id:required}
    {-package_id:required}
} {
    Is the contact visible to the specified package.
} {
    if { [db_0or1row get_contact_visible_p {}] } {
	return 1
    } else {
	return 0
    }
}

ad_proc -public contact::url {
    {-party_id:required}
    {-package_id ""}
} {
    create a contact revision
} {
    if { [exists_and_not_null package_id] } {
	return "[apm_package_url_from_id $package_id]${party_id}/"
    } else {
	return "[ad_conn package_url]${party_id}/"
    }
}

ad_proc -public contact::revision::new {
    {-party_id:required}
    {-party_revision_id ""}
} {
    create a contact revision
} {
    set extra_vars [ns_set create]
    oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list {party_id party_revision_id}
    return [package_instantiate_object \
		-extra_vars $extra_vars contact_party_revision]
}

ad_proc -public contact::live_revision {
    {-party_id:required}
} {
    create a contact revision
} {
    if {[db_0or1row revision_exists_p {select 1 from cr_items where item_id = :party_id}]} {
	return [item::get_live_revision $party_id]
    } else {
	return ""
    }
}

ad_proc -public contact::subsite_user_group {
    {-party_id:required}
} {
    create a contact revision
} {
    if {[db_0or1row revision_exists_p {select 1 from cr_items where item_id = :party_id}]} {
	return [item::get_live_revision $party_id]} else {
	    return ""
	}
}

ad_proc -public contact::spouse_id_not_cached {
    {-party_id:required}
    {-package_id ""}
} {
    this returns the contact's spouse_id, if and only if
    the special spousal relationship exists. It also automatically
    deletes multiple spouse records leaving the longest established
    one - should the contact have more than one spousal relationship set
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }
    set spouse_id [db_list get_spouse_id {}]

    # we do not allow for more than one spouse at a time since
    # this system is not programmed to deal with polygamy situations
    # we automatically delete the newer spousal relationship
    if { [llength $spouse_id] > 1 } {
	set active_p 0
	foreach spouse $spouse_id {
	    if { [contact::visible_p -party_id $spouse -package_id $package_id] } {
		 # they are visible to this instance, we do not delete
		 # if they are the first contact in this instance that
		 # is visible
		 if { [string is true $active_p] } {
		     db_list delete_rel {}
		     set spouse_name [contact::name -party_id $spouse]
		     util_user_message -message [_ contacts.lt_This_system_no_polygamy]
		     util_user_message -message [_ contacts.lt_Removing_spouse_name_as_spouse]
		 } else {
		     set active_p 1
		     set spouse_id $spouse
		 }
	     }
	}
    } elseif { [lindex $spouse_id 0] ne "" } {
	if { ![contact::visible_p -party_id [lindex $spouse_id 0] -package_id $package_id] } {
	    set spouse_id {}
	}
    }

    if { $spouse_id eq $party_id } {
	util_user_message -message [_ contacts.lt_No_marrying_yourself]
	# this is set here for the delete query
	set spouse $spouse_id
	db_list delete_rel {}
	set spouse_id {}
    }
    return $spouse_id
}

ad_proc -private contact::person_upgrade_to_user {
    {-person_id ""}
    {-no_perm_check "f"}
} {
    Upgrade a person to a user. This proc does not send an email to the newly created user.
} {
    contact::flush -party_id $person_id
    set user_id $person_id
    set username [contact::email -party_id $person_id]
    set authority_id [auth::authority::local]


    # Make sure that we do not upgrade an already existing user
    if {![contact::user_p -party_id $person_id]} {
	db_transaction {
	    db_dml upgrade_user {update acs_objects set object_type = 'user' where object_id = :user_id;
		
		insert into users
		(user_id, authority_id, username, email_verified_p)
		values
		(:user_id, :authority_id, :username, 't');
		
	    }

	    # Make sure that we we did not store user preferences before
	    if {![db_string user_prefs_p "select 1 from user_preferences where user_id = :user_id" -default "0"]} {
		db_dml update_user_prefs {insert into user_preferences
		    (user_id)
		    values
		    (:user_id);
		}
	    }
	    
	    # we reset the password in admin mode. this means that an email
	    # will not automatically be sent.
	    auth::password::reset -authority_id [auth::authority::local] -username $username -admin
	    if { [string is true $no_perm_check] } {
		group::add_member \
		    -no_perm_check \
		    -group_id "-2" \
		    -user_id $person_id \
		    -rel_type "membership_rel"
	    } else {
		group::add_member \
		    -group_id "-2" \
		    -user_id $person_id \
		    -rel_type "membership_rel"
	    }
	    # Grant the user to update the password on himself
	    permission::grant -party_id $user_id -object_id $user_id -privilege write

	    return 1
	} on_error {
	    error "There was an error in contact::person_upgrade_to_user: $errmsg"
	    return 0
	}
    }
}

ad_proc -private contact::group::new {
    {-group_id ""}
    {-email ""}
    {-url ""}
    -group_name:required
    {-join_policy "open"}
    {-context_id:required}
} {
    this creates a new group for use with contacts (and the permissions system)
} {
    set creation_user [ad_conn user_id]
    set creation_ip [ad_conn peeraddr]
    set group_name [lang::util::convert_to_i18n -prefix "group" -text "$group_name"]

    return [db_string create_group {}]
}

ad_proc -public contact::group::map {
    -group_id:required
    {-package_id ""}
    {-default_p "f"}
} {
    this creates a new group for use with contacts (and the permissions system)
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    db_dml map_group {}
}

ad_proc -public contact::group::parent {
    -group_id:required
} {
    returns the group_id for which this group is a component, if none then it return null
} {
    return [db_string get_parent {} -default {}]
}

ad_proc -public contact::groups_list {
    {-package_id ""}
} {
    Retrieve a list of all groups currently in the system
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }
    return [util_memoize [list contact::groups_list_not_cached -package_id $package_id]]
}

ad_proc -public contact::groups_list_not_cached {
    -package_id:required
} {
    Retrieve a list of all groups currently in the system
} {
    # Filter clause
    # set filter_clause ""
    set dotlrn_installed_p [apm_package_installed_p dotlrn]
    if { $dotlrn_installed_p } {
        set filter_clause "and groups.group_id not in (select community_id from dotlrn_communities_all)"
    } else {
        set filter_clause ""
    }
    return [db_list_of_lists get_groups {}]
}

ad_proc -public contact::groups {
    {-expand "all"}
    {-indent_with "..."}
    {-privilege_required "read"}
    {-output "list"}
    {-all:boolean}
    {-no_member_count:boolean}
    {-package_id ""}
} {
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }
    set user_id [ad_conn user_id]
    set group_list [list]
    foreach one_group [contact::groups_list -package_id $package_id] {
	util_unlist $one_group group_id group_name member_count component_count mapped_p default_p
	# We check if the group has the required privilege 
	# specified on privilege_required switch, if not then
	# we just simple continue with the next one
	if { ![permission::permission_p -object_id $group_id -party_id $user_id -privilege $privilege_required] } {
	    continue
	}

        if { $mapped_p || $all_p} {
            lappend group_list [list [lang::util::localize $group_name] $group_id $member_count "1" $mapped_p $default_p]
            if { $component_count > 0 && ( $expand == "all" || $expand == $group_id ) } {
                db_foreach get_components {} {
		    if { $mapped_p || $all_p} {
			lappend group_list [list "$indent_with$group_name" $group_id $member_count "2" $mapped_p $default_p]
		    }
		}
            }
        }
    }

    switch $output {
        list {
            set list_output [list]
            foreach group $group_list {
		if {$no_member_count_p} {
		    lappend list_output [list [lindex $group 0] [lindex $group 1]]
		} else {
		    lappend list_output [list [lindex $group 0] [lindex $group 1] [lindex $group 2]]
		}
            }
            return $list_output
        }
        ad_form {
            set ad_form_output [list]
            foreach group $group_list {
                lappend ad_form_output [list [lindex $group 0] [lindex $group 1]]
            }
	    return $ad_form_output
        }
        default {
            return $group_list
        }
    }
}

ad_proc -public contacts::person::new {
    {-first_names:required}
    {-last_name:required}
    {-email:required}
    {-contacts_package_id ""}
} {
    Insert a new person into contacts
    This will add them to the default group and add the ams attributes.
} {

    if {[string eq "" $contacts_package_id]} {
	set contacts_package_id [ad_conn package_id]
    } 

    # Create the new person
    set person_id [person::new -first_names $first_names -last_name $last_name -email $email]

    # Add to default group
    set default_group_id [contacts::default_group -package_id $contacts_package_id]
    group::add_member \
	-group_id $default_group_id \
	-user_id $person_id \
	-rel_type "membership_rel"

    # Store the AMS attribute
    set object_id [contact::revision::new -party_id $person_id]
    ams::attribute::save::text -object_id $object_id -attribute_name "first_names" -value "$first_names" -object_type "person"
    ams::attribute::save::text -object_id $object_id -attribute_name "last_name"  -value "$last_name" -object_type "person"
    ams::attribute::save::text -object_id $object_id -attribute_name "email" -value "$email" -object_type "person"
    
    return $person_id
}


ad_proc -public contacts::get_values {
    {-attribute_name ""}
    {-group_name ""}
    {-group_id ""}
    {-contacts_package_id ""}
    {-party_id:required}
    {-object_type:required}
} {
    If attribute_name is provided return the value of the attribute for the party, otherwise return an array with all elements for this party
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-09
    
    @param attribute_name If attribute name is provided, return the value of the attribute for the user. Otherwise return an array with all attributes.

    @param group_name Name of the group that contains the value of the attribute (e.g. #acs-kernel.Registered_Users)

    @param group_id Instead of group_name you can specify the group_id directly

    @param contacts_package_id The package_id of the contacts package that contains the element. 

    @return 
    
    @error 
} {
    
    if {[empty_string_p $contacts_package_id]} {
	set contacts_package_id [ad_conn package_id]
    }

    if {[empty_string_p $group_id]} {
	if {![db_0or1row get_group_id "select group_id from groups where group_name = :group_name"]} {
	    ad_return_error "ERROR" "[_ contacts.lt_Unable_to_retrieve_gr]"
	}
    }
    
    set list_name "${contacts_package_id}__${group_id}"
    set revision_id [contact::live_revision -party_id $party_id]
    set values [ams::values -package_key "contacts" -object_type $object_type -list_name $list_name -object_id $revision_id]
    array set return_array [list]

    # Never forget to localize the values retrieved from ams.
    foreach {section attribute pretty_name value} $values {
	set return_array($attribute) [lang::util::localize $value]
    }

    if {![empty_string_p $attribute_name]} {
	return $return_array($attribute_name) 
    } else {
	return [array get return_array]
    }
}

