# packages/contacts/tcl/contacts-populate.tcl

ad_library {

    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-05
    @arch-tag: 81868d37-99f5-48b1-8336-88e22c0e9001
}

namespace eval contacts::populate {}

ad_proc -public contacts::populate::crm {
    {-package_id ""}
} {
    Procedure to install ams Attributes for a good CRM solution (at
    least in our idea).

    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-05

    @return

    @error
} {

    ams::widgets_init

    if {[empty_string_p $package_id]} {
	array set sn_array [site_node::get \
				-url /contacts]
	set contacts_package_id $sn_array(object_id)
    } else {
	set contacts_package_id $package_id
    }

    set registered_user_group_id "-2"

    set customers_id [group::new \
			  -group_name "Customers" "group"]
    contact::group::map -group_id $customers_id -package_id $contacts_package_id

    set supplier_id [group::new \
			 -group_name "Supplier" "group"]
    contact::group::map -group_id $supplier_id -package_id $contacts_package_id

    # Hopefully all is now setup to map the groups accordingly.


    # We already have the registered users lists setup, so we only
    # need the list_id..
    # Actually we should never have to extend registered users, but
    # what the heck...


    ############################
    #
    # Person:: Registered Users
    #
    ############################

    set list_id [ams::list::get_list_id \
		     -package_key "contacts" \
		     -object_type "person" \
		     -list_name "${contacts_package_id}__${registered_user_group_id}"
		]

    ns_log Notice "reg_list_id:: $list_id"

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "salutation" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_salutation#" \
			  -pretty_plural "#acs-translations.person_salutation_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_salutation "Salutation"
    lang::message::register en_US acs-translations person_salutation_plural "Salutations"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "select" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "30" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_salutation_Dear_Mr_#"]

    lang::message::register en_US acs-translations person_salutation_Dear_Mr_ "Dear Mr. "

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_salutation_Dear_Mrs_#"]

    lang::message::register en_US acs-translations person_salutation_Dear_Mrs_ "Dear Mrs. "

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_salutation_Dear_Ms_#"]

    lang::message::register en_US acs-translations person_salutation_Dear_Ms_ "Dear Ms. "

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_salutation_Dear_#"]

    lang::message::register en_US acs-translations person_salutation_Dear_ "Dear "

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_salutation_Dear_Professor#"]

    lang::message::register en_US acs-translations person_salutation_Dear_Professor "Dear Professor"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_salutation_Dear_Dr#"]

    lang::message::register en_US acs-translations person_salutation_Dear_Dr "Dear Dr."

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "person_title" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_title#" \
			  -pretty_plural "#acs-translations.person_title_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_title "Title"
    lang::message::register en_US acs-translations person_title_plural "Titles"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "40" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "home_address" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_home_address#" \
			  -pretty_plural "#acs-translations.person_home_address_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_home_address "Home Address"
    lang::message::register en_US acs-translations person_home_address_plural "Home Addresses"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "postal_address" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "50" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "home_phone" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_home_phone#" \
			  -pretty_plural "#acs-translations.person_home_phone_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_home_phone "Home Phone"
    lang::message::register en_US acs-translations person_home_phone_plural "Home Phones"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "telecom_number" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "60" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "mobile_phone" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_mobile_phone#" \
			  -pretty_plural "#acs-translations.person_mobile_phone_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_mobile_phone "Mobile Phone"
    lang::message::register en_US acs-translations person_mobile_phone_plural "Mobile Phones"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "telecom_number" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "70" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "privateemail" \
			  -datatype "email" \
			  -pretty_name "#acs-translations.person_privateemail#" \
			  -pretty_plural "#acs-translations.person_privateemail_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_privateemail "Private E-Mail Address"
    lang::message::register en_US acs-translations person_privateemail_plural "Private E-Mail Addresses"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "email" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "80" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "birthdate" \
			  -datatype "date" \
			  -pretty_name "#acs-translations.person_birthdate#" \
			  -pretty_plural "#acs-translations.person_birthdate_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_birthdate "Birthdate"
    lang::message::register en_US acs-translations person_birthdate_plural "Birthdates"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "date" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "90" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "personnotes" \
			  -datatype "text" \
			  -pretty_name "#acs-translations.person_personnotes#" \
			  -pretty_plural "#acs-translations.person_personnotes_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_personnotes "Notes About Person"
    lang::message::register en_US acs-translations person_personnotes_plural "Notes About Person"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textarea" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "100" \
	-required_p "f" \
	-section_heading ""

    #####################
    #
    # Person: Suppliers
    #
    #####################

    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "person" \
		     -list_name "${contacts_package_id}__${supplier_id}" \
		     -pretty_name "#${contacts_package_id}__${supplier_id}#" \
		     -description "" \
		     -description_mime_type ""]

    ns_log Notice "reg_list_id:: $list_id"

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "bankaccountnumber" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_bankaccountnumber#" \
			  -pretty_plural "#acs-translations.person_bankaccountnumber_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_bankaccountnumber "Bank Account Number"
    lang::message::register en_US acs-translations person_bankaccountnumber_plural "Bank Account Numbers"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "10" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "bankcode" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_bankcode#" \
			  -pretty_plural "#acs-translations.person_bankcode_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_bankcode "Bank Code"
    lang::message::register en_US acs-translations person_bankcode_plural "Bank Codes"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "20" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "bankname" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_bankname#" \
			  -pretty_plural "#acs-translations.person_bankname_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_bankname "Name of Bank"
    lang::message::register en_US acs-translations person_bankname_plural "Name of Banks"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "30" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "accountowner" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_accountowner#" \
			  -pretty_plural "#acs-translations.person_accountowner_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_accountowner "Owner of Account"
    lang::message::register en_US acs-translations person_accountowner_plural "Owners of Account"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "40" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "languages" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_languages#" \
			  -pretty_plural "#acs-translations.person_languages_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_languages "Languages"
    lang::message::register en_US acs-translations person_languages_plural "Languages"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "multiselect" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "50" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_languages_EnglishUK#"]

    lang::message::register en_US acs-translations person_languages_EnglishUK "English:UK"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_languages_English_US#"]

    lang::message::register en_US acs-translations person_languages_English_US "English_US"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_languages_French#"]

    lang::message::register en_US acs-translations person_languages_French "French"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_languages_German#"]

    lang::message::register en_US acs-translations person_languages_German "German"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_languages_Spanish#"]

    lang::message::register en_US acs-translations person_languages_Spanish "Spanish"

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "availability" \
			  -datatype "text" \
			  -pretty_name "#acs-translations.person_availability#" \
			  -pretty_plural "#acs-translations.person_availability_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_availability "Availability"
    lang::message::register en_US acs-translations person_availability_plural "Availabilities"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textarea" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "60" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "subjectarea" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_subjectarea#" \
			  -pretty_plural "#acs-translations.person_subjectarea_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_subjectarea "Subject Area"
    lang::message::register en_US acs-translations person_subjectarea_plural "Subject Areas"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "multiselect" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "70" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_subjectarea_Advertisement#"]

    lang::message::register en_US acs-translations person_subjectarea_Advertisement "Advertisement"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_subjectarea_lt_Computers_-_Webbased_#"]

    lang::message::register en_US acs-translations person_subjectarea_lt_Computers_-_Webbased_ "Computers - Webbased Technologies"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_subjectarea_Engineering#"]

    lang::message::register en_US acs-translations person_subjectarea_Engineering "Engineering"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_subjectarea_Law#"]

    lang::message::register en_US acs-translations person_subjectarea_Law "Law"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.person_subjectarea_Public_Relations#"]

    lang::message::register en_US acs-translations person_subjectarea_Public_Relations "Public Relations"


    # For registered users we already setup the organizations list

    set list_id [ams::list::get_list_id \
		     -package_key "contacts" \
		     -object_type "organization" \
		     -list_name "${contacts_package_id}__${registered_user_group_id}"
		]
    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "company_address" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.organization_company_address#" \
			  -pretty_plural "#acs-translations.organization_company_address_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_company_address "Company Address"
    lang::message::register en_US acs-translations organization_company_address_plural "Company Addresses"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "postal_address" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "20" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "organization_url" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.person_organization_url#" \
			  -pretty_plural "#acs-translations.person_organization_url_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations person_organization_url "Organization URL"

    lang::message::register en_US acs-translations person_organization_url_plural "Organization URLs"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "url" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "30" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "company_phone" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.organization_company_phone#" \
			  -pretty_plural "#acs-translations.organization_company_phone_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_company_phone "Company Phone Number"
    lang::message::register en_US acs-translations organization_company_phone_plural "Company Phone Numbers"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "telecom_number" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "40" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "industrysector" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.organization_industrysector#" \
			  -pretty_plural "#acs-translations.organization_industrysector_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_industrysector "Industry Sector"
    lang::message::register en_US acs-translations organization_industrysector_plural "Industry Sectors"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "select" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "50" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_industrysector_lt_Agency_-_Full_Service#"]

    lang::message::register en_US acs-translations organization_industrysector_lt_Agency_-_Full_Service "Agency - Full Service"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_industrysector_Agency_-_Special#"]

    lang::message::register en_US acs-translations organization_industrysector_Agency_-_Special "Agency - Special"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_industrysector_Agency_-_PR#"]

    lang::message::register en_US acs-translations organization_industrysector_Agency_-_PR "Agency - PR"

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "company_notes" \
			  -datatype "text" \
			  -pretty_name "#acs-translations.organization_company_notes#" \
			  -pretty_plural "#acs-translations.organization_company_notes_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_company_notes "Notes on Company"
    lang::message::register en_US acs-translations organization_company_notes_plural "Notes on Company"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textarea" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "51" \
	-required_p "f" \
	-section_heading ""

    #################################
    #
    # Organization: Customers
    #
    ##################################
    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "organization" \
		     -list_name "${contacts_package_id}__${customers_id}" \
		     -pretty_name "#${contacts_package_id}__${customers_id}#" \
		     -description "" \
		     -description_mime_type ""]

#    callback contacts::populate::customer_attributes -list_id $list_id 

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "clienttype" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.organization_clienttype#" \
			  -pretty_plural "#acs-translations.organization_clienttype_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]


    lang::message::register en_US acs-translations organization_clienttype "Type of Customer"
    lang::message::register en_US acs-translations organization_clienttype_plural "Types of Customer"


    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "select" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "1" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_clienttype_VIP_Customer#"]

    lang::message::register en_US acs-translations organization_clienttype_VIP_Customer "VIP Customer"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_clienttype_Good_Customer#"]

    lang::message::register en_US acs-translations organization_clienttype_Good_Customer "Good Customer"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_clienttype_Normal_Customer#"]

    lang::message::register en_US acs-translations organization_clienttype_Normal_Customer "Normal Customer"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_clienttype_Sporadic_Customer#"]

    lang::message::register en_US acs-translations organization_clienttype_Sporadic_Customer "Sporadic Customer"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_clienttype_Follow-up_Customer#"]

    lang::message::register en_US acs-translations organization_clienttype_Follow-up_Customer "Follow-up Customer"

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "customer_since" \
			  -datatype "date" \
			  -pretty_name "#acs-translations.organization_customer_since#" \
			  -pretty_plural "#acs-translations.organization_customer_since_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_customer_since "Customer Since"
    lang::message::register en_US acs-translations organization_customer_since_plural "Customers Since"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "date" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "2" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "customernotes" \
			  -datatype "text" \
			  -pretty_name "#acs-translations.organization_customernotes#" \
			  -pretty_plural "#acs-translations.organization_customernotes_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_customernotes "Notes on Customer"
    lang::message::register en_US acs-translations organization_customernotes_plural "Notes on Customer"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textarea" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "3" \
	-required_p "f" \
	-section_heading ""
    
    ###########################
    #
    # Organization: Suppliers
    #
    ###########################

    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "organization" \
		     -list_name "${contacts_package_id}__${supplier_id}" \
		     -pretty_name "#${contacts_package_id}__${supplier_id}#" \
		     -description "" \
		     -description_mime_type ""]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "bankaccountnumber" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.organization_bankaccountnumber#" \
			  -pretty_plural "#acs-translations.organization_bankaccountnumber_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_bankaccountnumber "Bank Account No.o"
    lang::message::register en_US acs-translations organization_bankaccountnumber_plural "Bank Account Numbers*"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "1" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "bankcode" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.organization_bankcode#" \
			  -pretty_plural "#acs-translations.organization_bankcode_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_bankcode "Bank Codeo"
    lang::message::register en_US acs-translations organization_bankcode_plural "Bank Codes*"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "2" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "bankname" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.organization_bankname#" \
			  -pretty_plural "#acs-translations.organization_bankname_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_bankname "Name of Banko"
    lang::message::register en_US acs-translations organization_bankname_plural "Name of Banks*"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "3" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "speciliazedlanguages" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.organization_speciliazedlanguages#" \
			  -pretty_plural "#acs-translations.organization_speciliazedlanguages_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_speciliazedlanguages "Speciliazed Languageso"
    lang::message::register en_US acs-translations organization_speciliazedlanguages_plural "Speciliazed Languages*"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "multiselect" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "4" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_speciliazedlanguages_English_UK#"]

    lang::message::register en_US acs-translations organization_speciliazedlanguages_English_UK "English_UK"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_speciliazedlanguages_English_US#"]

    lang::message::register en_US acs-translations organization_speciliazedlanguages_English_US "English_US"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_speciliazedlanguages_French#"]

    lang::message::register en_US acs-translations organization_speciliazedlanguages_French "French"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_speciliazedlanguages_German#"]

    lang::message::register en_US acs-translations organization_speciliazedlanguages_German "German"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_speciliazedlanguages_Spanish#"]

    lang::message::register en_US acs-translations organization_speciliazedlanguages_Spanish "Spanish"

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "specializedsubjectareas" \
			  -datatype "string" \
			  -pretty_name "#acs-translations.organization_specializedsubjectareas#" \
			  -pretty_plural "#acs-translations.organization_specializedsubjectareas_plural#" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    lang::message::register en_US acs-translations organization_specializedsubjectareas "Specialized Subject Areaso"
    lang::message::register en_US acs-translations organization_specializedsubjectareas_plural "Specialized Subject Areas*"

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "multiselect" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "5" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_specializedsubjectareas_Advertisement#"]

    lang::message::register en_US acs-translations organization_specializedsubjectareas_Advertisement "Advertisement"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_specializedsubjectareas_lt_Computers_-_Webbased_#"]

    lang::message::register en_US acs-translations organization_specializedsubjectareas_lt_Computers_-_Webbased_ "Computers - Webbased Technologies"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_specializedsubjectareas_Engineering#"]

    lang::message::register en_US acs-translations organization_specializedsubjectareas_Engineering "Engineering"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_specializedsubjectareas_Law#"]

    lang::message::register en_US acs-translations organization_specializedsubjectareas_Law "Law"

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "#acs-translations.organization_specializedsubjectareas_Public_Relations#"]

    lang::message::register en_US acs-translations organization_specializedsubjectareas_Public_Relations "Public Relations"

    # Register Relationships

    rel_types::create_role -role "parent_company" -pretty_name "Parent Company" -pretty_plural "Parent Companies"
    rel_types::create_role -role "subsidiary" -pretty_name "Subsidiary" -pretty_plural "Subsidiaries"
    rel_types::new -table_name "contact_rels_subsidiary" -create_table_p "t" -supertype "contact_rel" -role_one "parent_company" -role_two "subsidiary" \
	"contact_rels_subsidiary" \
	"Contact Rel Subsidiary" \
	"Contact Rels Subsidiary" \
	"organization" \
	"0" \
	"" \
	"organization" \
	"0" \
	""

}