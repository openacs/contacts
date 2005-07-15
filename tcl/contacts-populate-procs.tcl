# packages/contacts/tcl/contacts-populate.tcl

ad_library {

    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-05
    @arch-tag: 81868d37-99f5-48b1-8336-88e22c0e9001
}

namespace eval contacts::populate {}

ad_proc -private -callback contacts::populate::organization::customer_attributes {
    {-list_id:required}
} {
}

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

    set registered_user_group_id [contacts::default_group -package_id $package_id]


    # This is a check for the customer and supplier id if P/O is installed.
    if {[apm_package_enabled_p intranet-core]} {
	set supplier_id [db_string freelancer_group "select group_id from groups where group_name = 'Freelancers'"]
	set customers_id [db_string customers_group "select group_id from groups where group_name = 'Customers'"]
    } else {
	set supplier_id [group::new \
			     -group_name "Supplier" "group"]
	set customers_id [group::new \
			  -group_name "Customers" "group"]

    }
    
    contact::group::map -group_id $supplier_id -package_id $contacts_package_id
    contact::group::map -group_id $customers_id -package_id $contacts_package_id

    # Hopefully all is now setup to map the groups accordingly.

    # We already have the registered users lists setup, so we only need
    # the list_id..  Actually we should never have to extend registered
    # users, but what the heck...

    # Person:: Registered Users

    set list_id [ams::list::get_list_id \
		     -package_key "contacts" \
		     -object_type "person" \
		     -list_name "${contacts_package_id}__${registered_user_group_id}"
		]

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "first_names" \
			  -datatype "string" \
			  -pretty_name "First Name(s)" \
			  -pretty_plural "First Name(s)" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "0" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "type_specific" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "f"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "10" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "last_name" \
			  -datatype "string" \
			  -pretty_name "Last Name" \
			  -pretty_plural "Last Names" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "0" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "type_specific" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "f"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "20" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "salutation" \
			  -datatype "string" \
			  -pretty_name "Salutation" \
			  -pretty_plural "Salutations" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
		       -option "Dear Mr. "]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Dear Mrs. "]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Dear Ms. "]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Dear "]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Dear Professor"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Dear Dr."]

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "person_title" \
			  -datatype "string" \
			  -pretty_name "Title" \
			  -pretty_plural "Titles" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -pretty_name "Home Address" \
			  -pretty_plural "Home Addresses" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -pretty_name "Home Phone" \
			  -pretty_plural "Home Phones" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -attribute_name "private_fax" \
			  -datatype "string" \
			  -pretty_name "Private Fax No." \
			  -pretty_plural "Private Fax Numbers" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -attribute_name "private_mobile_phone" \
			  -datatype "string" \
			  -pretty_name "Private Mobile No." \
			  -pretty_plural "Private Mobile Numbers" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "telecom_number" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "80" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "party" \
			  -attribute_name "email" \
			  -datatype "string" \
			  -pretty_name "Email Address" \
			  -pretty_plural "Email Addresses" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "0" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "type_specific" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "email" \
	-dynamic_p "f"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "84" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "birthdate" \
			  -datatype "date" \
			  -pretty_name "Birthdate" \
			  -pretty_plural "Birthdates" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -pretty_name "Notes About Person" \
			  -pretty_plural "Notes About Person" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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

    # ORGA - REG

    set list_id [ams::list::get_list_id \
		     -package_key "contacts" \
		     -object_type "organization" \
		     -list_name "${contacts_package_id}__${registered_user_group_id}"
		]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "name" \
			  -datatype "string" \
			  -pretty_name "Company Name" \
			  -pretty_plural "Organization Names" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -object_type "organization" \
			  -attribute_name "short_name" \
			  -datatype "string" \
			  -pretty_name "Short Company Name" \
			  -pretty_plural "Short Company Names" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "15" \
	-required_p "f" \
	-section_heading ""


    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "company_name_ext" \
			  -datatype "string" \
			  -pretty_name "Company Name Extensions" \
			  -pretty_plural "Company Name Extensions" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -object_type "organization" \
			  -attribute_name "company_address" \
			  -datatype "string" \
			  -pretty_name "Company Address" \
			  -pretty_plural "Company Addresses" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "postal_address" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "30" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "company_url" \
			  -datatype "url" \
			  -pretty_name "Company URL" \
			  -pretty_plural "Company URLs" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "url" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "40" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "company_phone" \
			  -datatype "string" \
			  -pretty_name "Company Phone No." \
			  -pretty_plural "Company Phone Numbers" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "telecom_number" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "50" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "company_fax" \
			  -datatype "string" \
			  -pretty_name "Company Fax No." \
			  -pretty_plural "Company Fax Numbers" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "telecom_number" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "55" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "industrysector" \
			  -datatype "string" \
			  -pretty_name "Industry Sector" \
			  -pretty_plural "Industry Sectors" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "select" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "60" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Agency - Full Service"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Agency - Special"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Agency - PR"]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "company_notes" \
			  -datatype "text" \
			  -pretty_name "Notes on Company" \
			  -pretty_plural "Notes on Company" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textarea" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "70" \
	-required_p "f" \
	-section_heading ""

    # PERSON - SUPPLY

    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "person" \
		     -list_name "${contacts_package_id}__${supplier_id}" \
		     -pretty_name "Person - Supplier" \
		     -description "" \
		     -description_mime_type ""]

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "bankaccountnumber" \
			  -datatype "string" \
			  -pretty_name "Bank Account Number" \
			  -pretty_plural "Bank Account Numbers" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -pretty_name "Bank Code" \
			  -pretty_plural "Bank Codes" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -pretty_name "Name of Bank" \
			  -pretty_plural "Name of Banks" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -attribute_name "languages" \
			  -datatype "string" \
			  -pretty_name "Languages" \
			  -pretty_plural "Languages" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
		       -option "English:UK"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "English_US"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "French"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "German"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Spanish"]

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "availability" \
			  -datatype "text" \
			  -pretty_name "Availability" \
			  -pretty_plural "Availabilities" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -pretty_name "Subject Areas" \
			  -pretty_plural "Subject Areas" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
		       -option "Advertisement"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Computers - Webbased Technologies"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Engineering"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Law"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Public Relations"]

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "freelancernotes" \
			  -datatype "text" \
			  -pretty_name "Notes on Freelancer" \
			  -pretty_plural "Notes on Freelancer" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textarea" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "71" \
	-required_p "f" \
	-section_heading ""

    #  Organization - Supplier

    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "organization" \
		     -list_name "${contacts_package_id}__${supplier_id}" \
		     -pretty_name "Organization - Supplier" \
		     -description "" \
		     -description_mime_type ""]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "bankaccountnumber" \
			  -datatype "string" \
			  -pretty_name "Bank Account No." \
			  -pretty_plural "Bank Account Numbers*" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -pretty_name "Bank Code" \
			  -pretty_plural "Bank Codes*" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -pretty_name "Name of Bank" \
			  -pretty_plural "Name of Banks*" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -pretty_name "Specialized Languages" \
			  -pretty_plural "Speciliazed Languages*" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
		       -option "English_UK"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "English_US"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "French"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "German"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Spanish"]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "specializedsubjectareas" \
			  -datatype "string" \
			  -pretty_name "Specialized Subject Areas" \
			  -pretty_plural "Specialized Subject Areas*" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
		       -option "Advertisement"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Computers \
- Webbased Technologies"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Engineering"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Law"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Public Relations"]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "accountmgr_supplier" \
			  -datatype "string" \
			  -pretty_name "Account Manager Supplier" \
			  -pretty_plural "Account Managers Supplier" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textbox" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "6" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "collaboration_notes" \
			  -datatype "text" \
			  -pretty_name "Notes on Collaboration" \
			  -pretty_plural "Notes on Collaboration" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textarea" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "7" \
	-required_p "f" \
	-section_heading ""

    #     Organization - Customer

    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "organization" \
		     -list_name "${contacts_package_id}__${customers_id}" \
		     -pretty_name "Organization - Customer" \
		     -description "" \
		     -description_mime_type ""]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "clienttype" \
			  -datatype "string" \
			  -pretty_name "Type of Customer" \
			  -pretty_plural "Types of Customer" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "select" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "10" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "VIP Customer"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Good Customer"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Normal Customer"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Sporadic Customer"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "Follow-up Customer"]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "customer_since" \
			  -datatype "date" \
			  -pretty_name "Customer Since" \
			  -pretty_plural "Customers Since" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "date" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "20" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "keyaccountmanager" \
			  -datatype "string" \
			  -pretty_name "Key Account Manager" \
			  -pretty_plural "Key Account Managers" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
		       -option "GL"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "RW"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "TK"]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "customernotes" \
			  -datatype "text" \
			  -pretty_name "Notes on Customer" \
			  -pretty_plural "Notes on Customer" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "textarea" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "40" \
	-required_p "f" \
	-section_heading ""

    callback contacts::populate::organization::customer_attributes -list_id $list_id

    # Person - Customer

    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "person" \
		     -list_name "${contacts_package_id}__${customers_id}" \
		     -pretty_name "1247__1264" \
		     -description "" \
		     -description_mime_type ""]

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "department" \
			  -datatype "string" \
			  -pretty_name "Department" \
			  -pretty_plural "Departments" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -attribute_name "jobtitle" \
			  -datatype "string" \
			  -pretty_name "Job Title" \
			  -pretty_plural "Job Titles" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -attribute_name "directphoneno" \
			  -datatype "string" \
			  -pretty_name "Direct Phone No." \
			  -pretty_plural "Direct Phone Numbers" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "telecom_number" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "30" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "telephone_other" \
			  -datatype "string" \
			  -pretty_name "Other Tel. No." \
			  -pretty_plural "Other Tel. Numbers" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -object_type "person" \
			  -attribute_name "directfaxno" \
			  -datatype "string" \
			  -pretty_name "Direct Fax No." \
			  -pretty_plural "Direct Fax Numbers" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "telecom_number" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "50" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "mobile_phone" \
			  -datatype "string" \
			  -pretty_name "Mobile Phone No." \
			  -pretty_plural "Mobile Phones" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
			  -attribute_name "directemail" \
			  -datatype "email" \
			  -pretty_name "E-Mail Adress" \
			  -pretty_plural "E-Mail Adresses" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "email" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "70" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "delivery_address" \
			  -datatype "string" \
			  -pretty_name "Delivery Address" \
			  -pretty_plural "Delivery Addresses" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "postal_address" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "80" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "visitaddress" \
			  -datatype "string" \
			  -pretty_name "Visit Adress" \
			  -pretty_plural "Visit Addresses" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "postal_address" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "90" \
	-required_p "f" \
	-section_heading ""

    set attribute_id [attribute::new \
			  -object_type "person" \
			  -attribute_name "collaboration_notes" \
			  -datatype "text" \
			  -pretty_name "Notes on Collboration" \
			  -pretty_plural "Notes on Collboration" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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
    #   Contact Rels Employement 

    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "contact_rels_employment" \
		     -list_name "$contacts_package_id" \
		     -pretty_name "Contact Rels Employement" \
		     -description "" \
		     -description_mime_type ""]

    set attribute_id [attribute::new \
			  -object_type "contact_rels_employment" \
			  -attribute_name "employed_since" \
			  -datatype "string" \
			  -pretty_name "Employment Since" \
			  -pretty_plural "Employments since" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

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

    # Contact Rels Subsidiary

    set list_id [ams::list::new \
		     -package_key "contacts" \
		     -object_type "contact_rels_subsidiary" \
		     -list_name "$contacts_package_id" \
		     -pretty_name "Contact Rels Subsidiary" \
		     -description "" \
		     -description_mime_type ""]

    set attribute_id [attribute::new \
			  -object_type "contact_rels_subsidiary" \
			  -attribute_name "shares" \
			  -datatype "integer" \
			  -pretty_name "Shares" \
			  -pretty_plural "Shares" \
			  -table_name "" \
			  -column_name "" \
			  -default_value "" \
			  -min_n_values "1" \
			  -max_n_values "1" \
			  -sort_order "1" \
			  -storage "generic" \
			  -static_p "f" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "integer" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "1" \
	-required_p "f" \
	-section_heading ""
}
