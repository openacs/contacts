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
namespace eval contact::employee {}
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

ad_proc -public contact::util::get_employees {
    {-organization_id:required}
    {-package_id ""}
} {
    get employees of an organization
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }
    return [util_memoize [list ::contact::util::get_employees_not_cached -organization_id $organization_id -package_id $package_id]]
}

ad_proc -public contact::util::get_employees_not_cached {
    {-organization_id:required}
    {-package_id:required}
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
	if { [contact::visible_p -party_id $other_party_id -package_id $package_id] } {
	    lappend contact_list $other_party_id
	}
    }

    return $contact_list
}

ad_proc -public contact::util::get_employees_list_of_lists {
    {-organization_id:required}
    {-package_id ""}
} {
    get employees of an organization in a list of list suitable for inclusion in options
    the list is made up of employee_name and employee_id. Cached
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }
    return [util_memoize [list ::contact::util::get_employees_list_of_lists_not_cached -organization_id $organization_id -package_id $package_id]]
}

ad_proc -private contact::util::get_employees_list_of_lists_not_cached {
    {-organization_id:required}
    {-package_id:required}
} {
    get employees of an organization in a list of list suitable for inclusion in options
    the list is made up of employee_name and employee_id
} {
    set contact_list [list]
    db_foreach select_employee_ids {
	select CASE WHEN object_id_one = :organization_id
                    THEN object_id_two
                    ELSE object_id_one END as other_party_id
	from acs_rels, acs_rel_types
	where acs_rels.rel_type = acs_rel_types.rel_type
	and ( object_id_one = :organization_id or object_id_two = :organization_id )
	and acs_rels.rel_type = 'contact_rels_employment'
    } {
	if { [contact::visible_p -party_id $other_party_id -package_id $package_id] } {
	    lappend contact_list [list [person::name -person_id $other_party_id] $other_party_id]
	}
    }

    return $contact_list
}

ad_proc -public contact::util::get_employers {
    {-employee_id:required}
    {-package_id ""}
} {
    Get employers of an employee

    @return List of lists, each containing the ID and name of an employer, or an empty list if no employers exist.
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }
    return [util_memoize [list ::contact::util::get_employers_not_cached -employee_id $employee_id -package_id $package_id]]
}

ad_proc -private contact::util::get_employers_not_cached {
    {-employee_id:required}
    {-package_id:required}
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
	if { [contact::visible_p -party_id $other_party_id -package_id $package_id] } {
	    set organization_name [contact::name -party_id $other_party_id]
	    lappend contact_list [list $other_party_id $organization_name]
	}
    }

    return $contact_list
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

ad_proc -public contact::employee::get {
    {-employee_id:required}
    {-array:required}
    {-organization_id ""}
    {-package_id ""}
} {
    Get full employee information. If employee does not have a phone number, fax number, or an e-mail address, the employee will be assigned the corresponding employer value, if an employer exists. Cached.

    @author Al-Faisal El-Dajani (faisal.dajanim@gmail.com)
    @creation-date 2005-10-18
    @param employee_id The ID of the employee whose information you wish to retrieve.
    @param array Name of array to upvar contents into.
    @param organization_id ID of the organization whose information should be returned <I> if </I> the employee_id is an employee at this organization. If not specified, defaults to first employer relationship found, if any.
    @return 1 if user exists, 0 otherwise.

    @return Array-list of data.
    @return first_names First Name of the person
    @return last_name 
    @return salutation Salutation of the person
    @return salutation_letter Salutation for a letterhead
    @return person_title
    @return direct_phoneno Direct phone number of the person, use company one if non existing
    @return directfaxno Direct Fax number, use company one if non existing
    @return email email of the person or the company (if there is no email for this person) 
    @return organization_id of the company (if there is an employing company)
    @return name name of the company (if there is an employing company)
    @return company_name_ext Name extension of the company (if there is one)
    @return address Street of the person (or company)
    @return municipality
    @return region
    @return postal_code
    @return country_code
    @return country Name of the country in the user's locale
    @return town_line TownLine in the format used in the country of the party
    @return locale Locale of the employee
    @return jobtitle Job Title of the person

} {
    upvar $array local_array
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }
    set values [util_memoize [list ::contact::employee::get_not_cached -employee_id $employee_id -organization_id $organization_id -package_id $package_id]]

    if {![empty_string_p $values]} {
	array set local_array $values
	return 1
    } else {
	return 0
    }
}

ad_proc -private contact::employee::get_not_cached {
    {-employee_id:required}
    {-organization_id}
    {-package_id:required}
} {
    @author Malte Sussdorff (malte.sussdorff@cognovis.de)
    Get full employee information. If employee does not have a phone number, fax number, or an e-mail address, the employee will be assigned the corresponding employer value, if an employer exists. Uncached.
    @param employee_id The ID of the employee whose information you wish to retrieve.
    @param organization_id ID of the organization whose information should be returned <I> if </I> the employee_id is an employee at this organization. If not specified, defaults to first employer relationship found, if any.

} {
    # ons_log notice "start processing"
    set employer_exist_p 0
    set employee_attributes [list "first_names" "last_name" "person_title" "directphoneno" "directfaxno" "email" "jobtitle" "person_title"]
    set employer_attributes [list "name" "company_phone" "company_fax" "email" "company_name_ext"]

    # Check if ID belongs to an employee, if not return the company information
    if {![person::person_p -party_id $employee_id]} {
	set employer_id $employee_id
	set employer_rev_id [content::item::get_best_revision -item_id $employer_id]
	foreach attribute $employer_attributes {
	    set value [ams::value \
			   -object_id $employer_rev_id \
			   -attribute_name $attribute
		      ]
	    switch $attribute {
		company_phone { set attribute "directphoneno" }
		company_fax   { set attribute "directfaxno" }
	    }
	    set local_array($attribute) $value
	}

	set local_array(salutation) "#contacts.lt_dear_ladies_and#"
	set local_array(salutation_letter) "" 
	if {[contacts::postal_address::get -attribute_name "company_address" -party_id $employer_id -array address_array]} {
	    set local_array(address) $address_array(delivery_address)
	    set local_array(municipality) $address_array(municipality)
	    set local_array(region) $address_array(region)
	    set local_array(postal_code) $address_array(postal_code)
	    set local_array(country_code) $address_array(country_code)
            set local_array(country) $address_array(country)
            set local_array(town_line) $address_array(town_line)
	    set company_address_p 1
	}
	return [array get local_array]
    }

    set employee_rev_id [content::item::get_best_revision -item_id $employee_id]

    # Get employers, if any
    set employers [list]
    set employers [contact::util::get_employers -employee_id $employee_id -package_id $package_id]

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
	set employer_id [lindex $employer 0]
	set employer_rev_id [content::item::get_best_revision -item_id $employer_id]
	
	# set the info
	set local_array(organization_id) $employer_id
    }

    set company_address_p 0
    if {$employer_exist_p} {
	foreach attribute $employer_attributes {
	    set value [ams::value \
			   -object_id $employer_rev_id \
			   -attribute_name $attribute
		      ]
	    switch $attribute {
		company_phone { set attribute "directphoneno" }
		company_fax   { set attribute "directfaxno" }
	    }
	    set local_array($attribute) $value
	}

	if {[contacts::postal_address::get -attribute_name "company_address" -party_id $employer_id -array address_array]} {
	    set local_array(address) $address_array(delivery_address)
	    set local_array(municipality) $address_array(municipality)
	    set local_array(region) $address_array(region)
	    set local_array(postal_code) $address_array(postal_code)
	    set local_array(country_code) $address_array(country_code)
            set local_array(country) $address_array(country)
            set local_array(town_line) $address_array(town_line)
	    set company_address_p 1
	}
    }
    
    # Set the attributes
    # This will overwrite company's attributes
    foreach attribute $employee_attributes {
	set value [ams::value \
		       -object_id $employee_rev_id \
		       -attribute_name $attribute
		  ]
	set local_array($attribute) $value
    }

    # Set the salutation
    set local_array(salutation) [contact::salutation_not_cached -party_id $employee_id -type salutation]
    set local_array(salutation_letter) [contact::salutation_not_cached -party_id $employee_id -type letter]

    # As we are asking for employee information only use home_address if there is no company_address
    if {$company_address_p == 0} {
	if {[contacts::postal_address::get -attribute_name "home_address" -party_id $employee_id -array home_address_array]} {
	    set local_array(address) $home_address_array(delivery_address)
	    set local_array(municipality) $home_address_array(municipality)
	    set local_array(region) $home_address_array(region)
	    set local_array(postal_code) $home_address_array(postal_code)
	    set local_array(country_code) $home_address_array(country_code)
            set local_array(country) $home_address_array(country)
            set local_array(town_line) $home_address_array(town_line)
	}
    }

    # message variables. if the employee does not have 
    # a viable mailing address for this package it will
    # look for a viable mailing address for its employers
    set local_array(mailing_address) [contact::message::mailing_address -party_id $employee_id -package_id $package_id]
    set local_array(email_address) [contact::message::email_address -party_id $employee_id -package_id $package_id]


    # Get the locale
    set local_array(locale) [lang::user::site_wide_locale -user_id $employee_id]

    return [array get local_array]
}

ad_proc -public contact::util::get_employee_organization {
    {-employee_id:required}
    {-package_id ""}
} {
    get organization of an employee
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }
    return [util_memoize [list ::contact::util::get_employee_organization_not_cached -employee_id $employee_id -package_id $package_id]]
}

ad_proc -public contact::util::get_employee_organization_not_cached {
    {-employee_id:required}
    {-package_id:required}
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
	if { [contact::visible_p -party_id $other_party_id -package_id $package_id] } {
	    lappend contact_list $other_party_id
	}
    }

    return $contact_list
}

ad_proc -private contact::flush {
    {-party_id:required}
} {
    Flush memorized information related to this contact
} {
    util_memoize_flush_regexp "contact(.*?)${party_id}"
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
} {
} {
    set user_id [ad_conn user_id]
    set group_list [list]
    foreach one_group [contact::groups_list] {
	util_unlist $one_group group_id group_name member_count component_count mapped_p default_p
	# We check if the group has the required privilege 
	# specified on privilege_required switch, if not then
	# we just simple continue with the next one
	if { ![permission::permission_p -object_id $group_id -party_id $user_id -privilege $privilege_required] } {
	    continue
	}

        if { $mapped_p || $all_p} {
            lappend group_list [list $group_name $group_id $member_count "1" $mapped_p $default_p]
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

