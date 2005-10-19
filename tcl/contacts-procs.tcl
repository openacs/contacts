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
namespace eval contact::special_attributes:: {}
namespace eval contact::rels:: {}
namespace eval contact::employee {}


ad_proc -public contacts::default_group {
    {-package_id ""}
} {
    returns the group_id for which this group is a component, if none then it return null
} {
    if {[string is false [exists_and_not_null package_id]]} {
        set package_id [ad_conn package_id]
    }
#    return [db_string get_default_group {select group_id from contact_groups where package_id = :package_id and default_p} -default {}]
#    return [db_string get_default_group {select group_id from
# application_groups where package_id = :package_id } -default {}]
    return "-2"
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

 ad_proc -public contact::util::get_employees {
    {-organization_id:required}
} {
    get employees of an organization
} {
    set contact_list {}
    db_foreach select_employee_ids {
	select CASE WHEN object_id_one = :organization_id
                    THEN object_id_two
                    ELSE object_id_one END as other_party_id
	from acs_rels, acs_rel_types
	where acs_rels.rel_type = acs_rel_types.rel_type
	and ( object_id_one = :organization_id or object_id_two = :organization_id )
	and acs_rels.rel_type = 'contact_rels_employment'
    } {
	lappend contact_list $other_party_id
    }

    return $contact_list
}

ad_proc -public contact::util::get_employers {
    {-employee_id:required}
} {
    Get employers of an employee

    @author Al-Faisal El-Dajani (faisal.dajani@gmail.com)
    @param employee_id The ID of the employee whom you want to know his/her employer
    @creation-date 2005-10-17
    @return List of lists, each containing the ID and name of an employer, or an empty list if no employers exist.
} {
    set contact_list [list]
    db_foreach select_employer_ids {
	select CASE WHEN object_id_one = :employee_id
                    THEN object_id_two
                    ELSE object_id_one END as other_party_id
	from acs_rels, acs_rel_types
	where acs_rels.rel_type = acs_rel_types.rel_type
	and ( object_id_one = :employee_id or object_id_two = :employee_id )
	and acs_rels.rel_type = 'contact_rels_employment'
    } {
	set organization_name [contact::name -party_id $other_party_id]
	lappend contact_list [list $other_party_id $organization_name]
    }

    return $contact_list
}

ad_proc -public contact::employee::get {
    {-employee_id:required}
    {-array:required}
    {-organization_id}
} {
    Get full employee information. If employee does not have a phone number, fax number, or an e-mail address, the employee will be assigned the corresponding employer value, if an employer exists.

    @author Al-Faisal El-Dajani (faisal.dajanim@gmail.com)
    @creation-date 2005-10-18
    @param employee_id The ID of the employee whose information you wish to retrieve.
    @param array Name of array to upvar contents into.
    @param organization_id ID of the organization whose information should be returned <I> if </I> the employee_id is an employee at this organization. If not specified, defaults to first employer relationship found, if any.
    @return 1 if user exists, 0 otherwise.
} {
    ns_log notice "start processing"
    upvar $array local_array
    set employer_exist_p 0
    set employee_attributes [list "first_names" "last_name" "salutation" "person_title" "home_phone" "private_fax" "email"]
    set employer_attributes [list "name" "company_phone" "company_fax" "email"]

    # Check if ID belongs to an employee, if not return 0
    if {![person::person_p -party_id $employee_id]} {
	ns_log notice "The ID specified does not belong to an employee"
	return 0
    }

    # Get employers, if any
    set employers [list]
    set employers [contact::util::get_employers -employee_id $employee_id]

    # If employer(s) exist
    if {[llength $employers] > 0} {
	if {[exists_and_not_null organization_id]} {
	    # If user sepcified to get information for a certain employer, check if the specified employer exists. If employer specified is not an employer, no organization info will be returned.
	    foreach single_employer $employers {
		if {$organization_id == [lindex $single_employer 0]} {
		    set employer $single_employer
		    set employer_exist_p 1
		    break
		}
	    }
	} else {
	    # If user didn't specify a certain employer, get first employer.
	    set employer [lindex $employers 0]
	    set employer_exist_p 1
	}
	# Get best/last revision
	set employee_id [content::item::get_best_revision -item_id $employee_id]
	set employer_id [content::item::get_best_revision -item_id [lindex $employer 0]]
    }

    # Set the attributes
    foreach attribute $employee_attributes {
	set value [ams::value \
		       -object_id $employee_id \
		       -attribute_name $attribute
		  ]
	set local_array($attribute) $value
    }
    if {$employer_exist_p} {
	foreach attribute $employer_attributes {
	    set value [ams::value \
			   -object_id $employer_id \
			   -attribute_name $attribute
		      ]
	    set $attribute $value
	}

	# Check if employee email, phone, and fax exist. If not, set them to employer values.
	if {![exists_and_not_null $local_array(email)]} {
	    set local_array(email) $email
	}
	if {![exists_and_not_null $local_array(home_phone)]} {
	    set local_array(home_phone) $company_phone
	}
	if {![exists_and_not_null $local_array(private_fax)]} {
	    set local_array(private_fax) $company_fax
	}
    }

    set local_array(company_name) $name
    set address_id [attribute::id -object_type "organization" -attribute_name "company_address"]
    contacts::postal_address::get -address_id $address_id -array address_array
    set local_array(company_address) $address_array(delivery_address)
    set local_array(company_municipality) $address_array(municipality)
    set local_array(company_region) $address_array(region)
    set local_array(company_postal_code) $address_array(postal_code)
    set local_array(company_country_code) $address_array(country_code)

    return 1
}

ad_proc -public contact::util::get_employee_organization {
    {-employee_id:required}
} {
    get organization of an employee
} {
    set contact_list {}
    db_foreach select_employee_ids {
	select CASE WHEN object_id_one = :employee_id
                    THEN object_id_two
                    ELSE object_id_one END as other_party_id
	from acs_rels, acs_rel_types
	where acs_rels.rel_type = acs_rel_types.rel_type
	and ( object_id_one = :employee_id or object_id_two = :employee_id )
	and acs_rels.rel_type = 'contact_rels_employment'
    } {
	lappend contact_list $other_party_id
    }

    return $contact_list
}

ad_proc -private contact::flush {
    {-party_id:required}
} {
    Flush memorized information related to this contact
} {
    util_memoize_flush "::contact::email_address_exists_p_not_cached -party_id $party_id"
    util_memoize_flush "::contact::mailing_address_exists_p_not_cached -party_id $party_id"
    util_memoize_flush "::contact::name_not_cached -party_id $party_id"
    util_memoize_flush "::contact::email_not_cached -party_id $party_id"
}

ad_proc -public contact::name {
    {-party_id:required}
} {
    this returns the contact's name. Cached
} {
    return [util_memoize [list ::contact::name_not_cached -party_id $party_id]]
}

ad_proc -public contact::name_not_cached {
    {-party_id:required}
} {
    this returns the contact's name
} {
    if {[person::person_p -party_id $party_id]} {
	set person_info [person::name -person_id $party_id]
	set ok [parameter::get -parameter DisplayEmployersP -package_id [apm_package_id_from_key "contacts"]]
	if {$ok} {
	    set organizations [contact::util::get_employers -employee_id $party_id]
	    if {[llength $organizations] > 0} {
		append person_info " ("
		foreach organization $organizations {
		    set organization_url [contact::url -party_id [lindex $organization 0]]
		    set organization_name [lindex $organization 1]
		    append person_info "<a href=\"$organization_url\">$organization_name</a>"
		    append person_info ", "
		}
		# for some reason the following line does not work
		set $person_info [string trimright $person_info ", "]
		append person_info ")"
	    }
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
    set email [db_string get_party_email { select email from parties where party_id = :party_id } -default {}]
    if { ![exists_and_not_null email] } {
	# we check if these is an ams_attribute_valued email address for this party
	set attribute_id [contact::email_attribute_id]
	set revision_id [contact::live_revision -party_id $party_id]
	if { [exists_and_not_null revision_id] } {
	    set email [db_string get_email { select ams_attribute_value__value(:attribute_id,value_id) from ams_attribute_values where object_id = :revision_id and attribute_id = :attribute_id } -default {}]
	    set email [ams::widget -widget email -request value_text -value $email]
	}
    }
    return $email
}

ad_proc -private contact::email_attribute_id {
} {
    this returns the email attributes attribute_id. cached
} {
    return [util_memoize [list ::contact::email_attribute_id]]
}

ad_proc -private contact::email_attribute_id {
} {
    this returns the email attributes attribute_id
} {
    return [db_string get_email_attribute_id { select attribute_id from acs_attributes where object_type = 'party' and attribute_name = 'email'}]
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
    if {[contact::user_p -party_id $party_id]} {
        return "user"
    } elseif {[person::person_p -party_id $party_id]} {
	return "person"
    } elseif {[organization::organization_p -party_id $party_id]} {
	return "organization"
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
    if {[person::person_p -party_id $party_id]} {
	return 1
    } elseif {[organization::organization_p -party_id $party_id]} {
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
    return [util_memoize [list ::contact::user_p_not_cached -party_id $party_id]]
}

ad_proc -public contact::user_p_not_cached {
    {-party_id:required}
} {
    is this party a person? Cached
} {
    if {[db_0or1row contact_user_exists_p {select '1' from users where user_id = :party_id}]} {
	return 1
    } else {
	return 0
    }
}

ad_proc -public contact::url {
    {-party_id:required}
} {
    create a contact revision
} {
    return "[apm_package_url_from_id [apm_package_id_from_key "contacts"]]$party_id/"
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

ad_proc -private contact::person_upgrade_to_user {
    {-person_id ""}
} {
    Upgrade a person to a user. This proc does not send an email to the newly created user.
} {
    contact::flush -party_id $person_id
    set user_id $person_id
    set username [contact::email -party_id $person_id]
    set authority_id [auth::authority::local]
    db_transaction {
	db_dml upgrade_user {update acs_objects set object_type = 'user' where object_id = :user_id;
	    
	    insert into users
	    (user_id, authority_id, username, email_verified_p)
	    values
	    (:user_id, :authority_id, :username, 't');
	    
	    insert into user_preferences
	    (user_id)
	    values
	    (:user_id);}
    
	# we reset the password in admin mode. this means that an email
	# will not automatically be sent.
	auth::password::reset -authority_id [auth::authority::local] -username $username -admin
	group::add_member \
	    -group_id "-2" \
	    -user_id $person_id \
	    -rel_type "membership_rel"
	
	# Grant the user to update the password on himself
	permission::grant -party_id $user_id -object_id $user_id -privilege write

	# add him to dotlrn (I'M LAZY)
	#dotlrn::user_add -user_id $user_id
	
    } on_error {
	error "There was an error in contact::person_upgrade_to_user: $errmsg"
    }

    # I'm too lazy to write 
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

ad_proc -public contact::groups {
    {-expand "all"}
    {-indent_with "..."}
    {-privilege_required "read"}
    {-output "list"}
    {-all:boolean}
    {-no_member_count:boolean}
} {
} {
    set user_id [ad_conn user_id]
    set group_list [list]
    # Filter clause
    # set filter_clause ""
    set filter_clause "and groups.group_id not in (select community_id from dotlrn_communities_all)"
    db_foreach get_groups {} {
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

ad_proc -public contact::special_attributes::ad_form_values {
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

ad_proc -public contact::special_attributes::ad_form_save {
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
