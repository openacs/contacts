ad_library {

    Contacts install library

    Procedures that deal with installing, instantiating, mounting.

    @creation-date 2005-05-26
    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
}

namespace eval contacts::install {}


ad_proc -public contacts::install::package_install {
} {
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-04

    @return

    @error
} {

    # Register Relationships

    rel_types::new -table_name "contact_rels" -create_table_p "f" \
	"contact_rel" \
	"Contact Relationship" \
	"Contact Relationships" \
	"party" \
	"0" \
	"" \
	"party" \
	"0" \
	""

    rel_types::create_role -role "organization" -pretty_name "Organization" -pretty_plural "Organizations"

    rel_types::new -table_name "organization_rels" -create_table_p "f" \
	"organization_rel" \
	"Organization Relationship" \
	"Organization Relationships" \
	"group" \
	"0" \
	"" \
	"organization" \
	"0" \
	""

    rel_types::create_role -role "employee" -pretty_name "Employee" -pretty_plural "Employees"
    rel_types::create_role -role "employer" -pretty_name "Employer" -pretty_plural "Employers"
    rel_types::new -table_name "contact_rel_employment" -create_table_p "t" -supertype "contact_rel" -role_one "employee" -role_two "employer" \
	"contact_rels_employment" \
	"Contact Rel Employment" \
	"Contact Rels Employment" \
	"person" \
	"0" \
	"" \
	"organization" \
	"0" \
	""
}

ad_proc -public contacts::install::package_instantiate {
    {-package_id:required}
} {

    # We want to instantiate the contacts package so that registered

    # users have some attributes mapped by default. This could be extended in custom packages.

    set default_group [contacts::default_group -package_id $package_id]
    ams::widgets_init
    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "person" \
		     -list_name "${package_id}__$default_group" \
		     -pretty_name "Person - Registered Users" \
		     -description "" \
		     -description_mime_type ""]

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "first_names" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_first_names#" \
			  -pretty_plural "#acs-translations.person_first_names_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "0" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "type_specific" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_last_name "First Names"
    lang::message::register en_US acs-translations person_last_name_plural "First Names"

    ams::attribute::new -attribute_id $attribute_id -widget "textbox" -dynamic_p "f"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "1" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "last_name" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_last_name#" \
			  -pretty_plural "#acs-translations.person_last_name_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "0" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "type_specific" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_first_names "Last Name"
    lang::message::register en_US acs-translations person_first_names_plural "Last Names"

    ams::attribute::new -attribute_id $attribute_id -widget "textbox" -dynamic_p "f"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "2" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "party" \
			  -attribute_name "email" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.party_email#" \
			  -pretty_plural "#acs-translations.party_email_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "0" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "type_specific" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations party_email "Email Address"
    lang::message::register en_US acs-translations party_email_plural "Email Addresses"

    ams::attribute::new -attribute_id $attribute_id -widget "email" -dynamic_p "f"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "3" \
	-required_p "f" \
	-section_heading ""

    # ORGANIZATIONS

    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "organization" \
		     -list_name "${package_id}__$default_group" \
		     -pretty_name "Organization - Registered Users" \
		     -description "" \
		     -description_mime_type ""]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "name" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.organization_name#" \
			  -pretty_plural "#acs-translations.organization_name_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_name "Organization Name"
    lang::message::register en_US acs-translations organization_name_plural "Organization Names"

    ams::attribute::new -attribute_id $attribute_id -widget "textbox" -dynamic_p "t"

    ams::list::attribute::map \
 	-list_id $list_id \
 	-attribute_id $attribute_id \
 	-sort_order "1" \
 	-required_p "f" \
 	-section_heading ""

    # Make the registered users group mapped by default

    contacts::insert_map -group_id "$default_group" -default_p "t" -package_id $package_id
}

ad_proc -public contacts::install::package_mount {
    -package_id
    -node_id
} {
    
    Actions to be executed after mounting the contacts package

    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-04

    @return

    @error
} {
    contacts::populate::crm -package_id $package_id
}

ad_proc -public contacts::insert_map {
    {-group_id:required}
    {-default_p:required}
    {-package_id:required}
} {
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-03

    @param group_id

    @param default_p

    @param package_id

    @return

    @error
} {
    db_dml insert_map {
        insert into contact_groups
        (group_id,default_p,package_id)
        values
        (:group_id,:default_p,:package_id)}
}

