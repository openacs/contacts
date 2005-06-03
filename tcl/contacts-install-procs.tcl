ad_library {

    Contacts install library

    Procedures that deal with installing, instantiating, mounting.

    @creation-date 2005-05-26
    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
}

namespace eval contacts::install {}

ad_proc -public -callback contact::contact_form {
    {-package_id:required}
    {-form:required}
    {-object_type:required}
} {
}

ad_proc -public -callback contact::contact_new_form {
    {-package_id:required}
    {-contact_id:required}
    {-form:required}
    {-object_type:required}
} {
}

ad_proc -public contacts::install::package_instantiate {
    {-package_id:required}
} {

    # We want to instantiate the contacts package so that registered
    # users have some attributes mapped by default. This could be
    # extended in custom packages.

    ams::widgets_init
    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "person" \
		     -list_name "${package_id}__-2" \
		     -pretty_name "Contacts-Person" \
		     -description "" \
		     -description_mime_type ""]


    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "first_names" \
			  -datatype "string" \
			  -pretty_name "#ams.person_first_names#" \
			  -pretty_plural "#ams.person_first_names_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "0" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "type_specific" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US ams person_last_name "First Names"
    lang::message::register en_US ams person_last_name_plural "First Names"

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
			  -pretty_name "#ams.person_last_name#" \
			  -pretty_plural "#ams.person_last_name_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "0" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "type_specific" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US ams person_first_names "Last Name"
    lang::message::register en_US ams person_first_names_plural "Last Names"

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
			  -pretty_name "#ams.party_email#" \
			  -pretty_plural "#ams.party_email_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "0" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "type_specific" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US ams party_email "Email Address"
    lang::message::register en_US ams party_email_plural "Email Addresses"

    ams::attribute::new	-attribute_id $attribute_id -widget "email" -dynamic_p "f"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "3" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "home_address" \
			  -datatype "string" \
			  -pretty_name "#ams.person_address#" \
			  -pretty_plural "#ams.person_address_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US ams person_address "Home Address"
    lang::message::register en_US ams person_address_plural "Home Address"

    ams::attribute::new	-attribute_id $attribute_id -widget "postal_address" -dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "4" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "home_phone" \
			  -datatype "string" \
			  -pretty_name "#ams.home_phone#" \
			  -pretty_plural "#ams.home_phone_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US ams home_phone "Home Phone"
    lang::message::register en_US ams home_phone_plural "Home Phone"

    ams::attribute::new	-attribute_id $attribute_id -widget "telecom_number" -dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "5" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "mobile_phone" \
			  -datatype "string" \
			  -pretty_name "#ams.mobile_phone#" \
			  -pretty_plural "#ams.mobile_phone_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US ams mobile_phone "Mobile Phone"
    lang::message::register en_US ams mobile_phone_plural "Mobile Phone"

    ams::attribute::new	-attribute_id $attribute_id -widget "telecom_number" -dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "6" \
	-required_p "f" \
	-section_heading ""

    ###################
    #
    # ORGANIZATIONS
    #
    ###################

    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "organization" \
		     -list_name "${package_id}__-2" \
		     -pretty_name "#contacts.Organization#" \
		     -description "" \
		     -description_mime_type ""]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "name" \
			  -datatype "string" \
			  -pretty_name "#ams.organization_name#" \
			  -pretty_plural "#ams.organization_name_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US ams organization_name "Organization Name"
    lang::message::register en_US ams organization_name_plural "Organization Names"

    ams::attribute::new -attribute_id $attribute_id -widget "textbox" -dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "1" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "organization_address" \
			  -datatype "string" \
			  -pretty_name "#ams.organization_address#" \
			  -pretty_plural "#ams.organization_address_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US ams organization_address "Address"
    lang::message::register en_US ams organization_address_plural "Address"

    ams::attribute::new	-attribute_id $attribute_id -widget "postal_address" -dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "2" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "organization_url" \
			  -datatype "string" \
			  -pretty_name "#ams.organization_url#" \
			  -pretty_plural "#ams.organization_url_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US ams organization_url "Website"
    lang::message::register en_US ams organization_url_plural "Website"

    ams::attribute::new	-attribute_id $attribute_id -widget "url" -dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "3" \
	-required_p "f" \
	-section_heading ""
    
    # Make the registered users group mapped by default 
    contacts::insert_map -group_id "-2" -default_p "t" -package_id $package_id
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
        (:group_id,:default_p,:package_id)
    }
}
