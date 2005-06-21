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

ad_proc -public contacts::default_group {
    {-package_id ""}
} {
    returns the group_id for which this group is a component, if none then it return null
} {
    if {[string is false [exists_and_not_null package_id]]} {
        set package_id [ad_conn package_id]
    }
    return [db_string get_default_group {select group_id from contact_groups where package_id =:package_id and default_p} -default {}]
}

ad_proc -private contact::util::interpolate {
    {-values:required}
    {-text:required}
} {
    Interpolates a set of values into a string. This is directly copied from the bulk mail package

    @param values a list of key, value pairs, each one consisting of a
    target string and the value it is to be replaced with.
    @param text the string that is to be interpolated

    @return the interpolated string
} {
    foreach pair $values {
        regsub -all [lindex $pair 0] $text [lindex $pair 1] text
    }
    return $text
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

ad_proc -private contact::util::get_employees {
    {-organization_id:required}
} {
    get employees of an organization
} {
    set contact_list $organization_id

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

ad_proc -public contact::name {
    {-party_id:required}
} {
    this returns the contact's name
} {
    if {[contact::person_p \
	     -party_id $party_id]} {
	return [person::name \
		    -person_id $party_id]
    } else {

	# if there is an org the name is returned otherwise null is
	# returned

        return [db_string get_org_name {select name from organizations where organization_id = :party_id} -default {}]
    }
}

ad_proc -public contact::type {
    {-party_id:required}
} {
    this returns the contact's name
} {
    if {[contact::person_p \
	     -party_id $party_id]} {
	return "person"
    } elseif {[contact::organization_p \
		   -party_id $party_id]} {
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

    if {[contact::person_p \
	     -party_id $party_id]} {
	return 1
    } elseif {[contact::organization_p \
		   -party_id $party_id]} {
	return 1
    } else {
	return 0
    }
}

ad_proc -public contact::person_p {
    {-party_id:required}
} {
    this returns the contact's name
} {
    if {[db_0or1row contact_person_exists_p {select '1' from persons where person_id = :party_id}]} {
	return 1} else {
	    return 0
	}
}

ad_proc -public contact::organization_p {
    {-party_id:required}
} {
    this returns the contact's name
} {
    if {[contact::person_p \
	     -party_id $party_id]} {
	return 0
    } else {
	if {[db_0or1row contact_org_exists_p {select '1' from organizations where organization_id = :party_id}]} {
	    return 1} else {
		return 0
	    }
    }
}

ad_proc -public contact::url {
    {-party_id:required}
} {
    create a contact revision
} {
    return "[ad_conn package_url]$party_id/"
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
	return [item::get_live_revision $party_id]} else {
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
    db_foreach get_groups {} {
        if {$mapped_p 
	    || $all_p} {
            lappend group_list [list [lang::util::localize $group_name] $group_id $member_count "1" $mapped_p $default_p]
            if {$component_count > 0 
		&& ( $expand == "all" || $expand == $group_id ) } {
                db_foreach get_components {} {
		    if {$mapped_p || $all_p} {
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
    set object_type [contact::type \
			 -party_id $party_id]

    db_1row get_extra_info {
	select email, url
	from parties
	where party_id = :party_id}
    set element_list [list email url]

    if {$object_type == "person" } {

	array set person [person::get \
			      -person_id $party_id]
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
    set object_type [contact::type \
			 -party_id $party_id]
    set element_list [list email url]
    if {$object_type == "person" } {
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
    if {$object_type == "person" } {

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
	set contacts_package_id [ad_conn contacts_package_id]
    }

    if {[empty_string_p $group_id]} {
	if {![string match "#*#" $group_name]} {
	    set group_name [lang::util::convert_to_i18n -prefix "group" $group_name]
	}
	if {![db_0or1row get_group_id "select group_id from groups where group_name = :group_name"]} {
	    ad_return_error "ERROR" "[_ contacts.lt_Unable_to_retrieve_gr]"
	}
    }
    
    set list_name "${contacts_package_id}__${group_id}"
    set revision_id [contact::live_revision -party_id $party_id]
    set values [ams::values -package_key "contacts" -object_type $object_type -list_name $list_name -object_id $revision_id]
    array set return_array [list]
    foreach {section attribute pretty_name value} $values {
	set return_array($attribute) $value 
    }
    if {![empty_string_p $attribute_name]} {
	return $return_array($attribute_name) 
    } else {
	return [array get return_array]
    }
}
