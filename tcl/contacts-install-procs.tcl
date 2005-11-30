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
	"[_ contacts.Contact_Relationship]" \
	"[_ contacts.lt_Contact_Relationships]" \
	"party" \
	"0" \
	"" \
	"party" \
	"0" \
	""

    rel_types::create_role -role "organization" -pretty_name "[_ contacts.Organization]" -pretty_plural "[_ contacts.Organizations]"

    rel_types::new -table_name "organization_rels" -create_table_p "f" \
	"organization_rel" \
	"[_ contacts.lt_Organization_Relation]" \
	"[_ contacts.lt_Organization_Relation_1]" \
	"group" \
	"0" \
	"" \
	"organization" \
	"0" \
	""

    rel_types::create_role -role "employee" -pretty_name "[_ contacts.Employee]" -pretty_plural "[_ contacts.Employees]"
    rel_types::create_role -role "employer" -pretty_name "[_ contacts.Employer]" -pretty_plural "[_ contacts.Employers]"
    rel_types::new -table_name "contact_rel_employment" -create_table_p "t" -supertype "contact_rel" -role_one "employee" -role_two "employer" \
	"contact_rels_employment" \
	"[_ contacts.lt_Contact_Rel_Employmen]" \
	"[_ contacts.lt_Contact_Rels_Employme]" \
	"person" \
	"0" \
	"" \
	"organization" \
	"0" \
	""

    # Creation of contact_complaint_track table
    content::type::new -content_type "contact_complaint" \
	-pretty_name "Contact Complaint" \
	-pretty_plural "Contact Complaints" \
	-table_name "contact_complaint_track" \
	-id_column "complaint_id"
    
    # now set up the attributes that by default we need for the complaints
    content::type::attribute::new \
	-content_type "contact_complaint" \
	-attribute_name "customer_id" \
	-datatype "integer" \
	-pretty_name "Customer ID" \
	-sort_order 1 \
	-column_spec "integer constraint contact_complaint_track_customer_fk
                                  references parties(party_id) on delete cascade"
    
    content::type::attribute::new \
	-content_type "contact_complaint" \
	-attribute_name "turnover" \
	-datatype "money" \
	-pretty_name "Turnover" \
	-sort_order 2 \
	-column_spec "float"
    
    content::type::attribute::new \
	-content_type "contact_complaint" \
	-attribute_name "percent" \
	-datatype "integer" \
	-pretty_name "Percent" \
	-sort_order 3 \
	-column_spec "integer"

    content::type::attribute::new \
	-content_type "contact_complaint" \
	-attribute_name "supplier_id" \
	-datatype "integer" \
	-pretty_name "Supplier ID" \
	-sort_order 4 \
	-column_spec "integer"
    
    content::type::attribute::new \
	-content_type "contact_complaint" \
	-attribute_name "paid" \
	-datatype "money" \
	-pretty_name "Paid" \
	-sort_order 5 \
	-column_spec "float"
    
    content::type::attribute::new \
	-content_type "contact_complaint" \
	-attribute_name "complaint_object_id" \
	-datatype "integer" \
	-pretty_name "Complaint Object ID" \
	-sort_order 6 \
	-column_spec "integer constraint contact_complaint_track_complaint_object_id_fk 
                                  references acs_objects(object_id) on delete cascade"
    
    content::type::attribute::new \
	-content_type "contact_complaint" \
	-attribute_name "state" \
	-datatype "string" \
	-pretty_name "State" \
	-sort_order 7 \
	-column_spec "varchar(7) constraint cct_state_ck
                                  check (state in ('valid','invalid','open'))"

    content::type::attribute::new \
	-content_type "contact_complaint" \
	-attribute_name "employee_id" \
	-datatype "integer" \
	-pretty_name "Employee ID" \
	-sort_order 8 \
	-column_spec "integer constraint contact_complaint_track_employee_fk
                                  references parties(party_id) on delete cascade"
    
    content::type::attribute::new \
	-content_type "contact_complaint" \
	-attribute_name "refund" \
	-datatype "money" \
	-pretty_name "Refund" \
	-sort_order 9 \
	-column_spec "float"
    
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
		     -pretty_name "[_ contacts.lt_Person_-_Registered_U]" \
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

ad_proc -public ::install::xml::action::contacts_pop_crm {
    node
} { 
    Procedure to register the populate crm for the install.xml
} {
    set url [apm_required_attribute_value $node url]
    array set sn_array [site_node::get -url $url]
    contacts::populate::crm -package_id $sn_array(object_id)
}


ad_proc -public contacts::install::package_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
    @creation-date 2005-10-05
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
	    1.0d18 1.0d19 {

		content::type::new -content_type "contact_complaint" \
		    -pretty_name "Contact Complaint" \
		    -pretty_plural "Contact Complaints" \
		    -table_name "contact_complaint_track" \
		    -id_column "complaint_id"
		
		# now set up the attributes that by default we need for the complaints
		content::type::attribute::new \
		    -content_type "contact_complaint" \
		    -attribute_name "customer_id" \
		    -datatype "integer" \
		    -pretty_name "Customer ID" \
		    -sort_order 1 \
		    -column_spec "integer constraint contact_complaint_track_customer_fk
                                  references parties(party_id) on delete cascade"
		
		content::type::attribute::new \
		    -content_type "contact_complaint" \
		    -attribute_name "turnover" \
		    -datatype "money" \
		    -pretty_name "Turnover" \
		    -sort_order 2 \
		    -column_spec "float"

		content::type::attribute::new \
		    -content_type "contact_complaint" \
		    -attribute_name "percent" \
		    -datatype "integer" \
		    -pretty_name "Percent" \
		    -sort_order 3 \
		    -column_spec "integer"

		content::type::attribute::new \
		    -content_type "contact_complaint" \
		    -attribute_name "supplier_id" \
		    -datatype "integer" \
		    -pretty_name "Supplier ID" \
		    -sort_order 4 \
		    -column_spec "integer"
		
		content::type::attribute::new \
		    -content_type "contact_complaint" \
		    -attribute_name "paid" \
		    -datatype "money" \
		    -pretty_name "Paid" \
		    -sort_order 5 \
		    -column_spec "float"

		content::type::attribute::new \
		    -content_type "contact_complaint" \
		    -attribute_name "complaint_object_id" \
		    -datatype "integer" \
		    -pretty_name "Complaint Object ID" \
		    -sort_order 6 \
		    -column_spec "integer constraint contact_complaint_track_complaint_object_id_fk 
                                  references acs_objects(object_id) on delete cascade"
		
		content::type::attribute::new \
		    -content_type "contact_complaint" \
		    -attribute_name "state" \
		    -datatype "string" \
		    -pretty_name "State" \
		    -sort_order 7 \
		    -column_spec "varchar(7) constraint cct_state_ck
                                  check (state in ('valid','invalid','open'))"
		
		# Now we need to copy all information on contact_complaint_tracking table (the one we are taking out)
		# into the new one called contact_complaint_track with the new fields. This is simple since
		# all the collumns have the same datatype, just changed some names.
		
		db_dml insert_data {
		    insert into 
		    contact_complaint_track 
		    (complaint_id,customer_id,turnover,percent,supplier_id,paid,complaint_object_id,state) 
		    select * from contact_complaint_tracking
		}
		
		# Now we just delete the table contact_complaint_tracking
		db_dml drop_table { drop table contact_complaint_tracking } 
	    }
	    
	    1.0d21 1.0d22 {

		content::type::attribute::new \
		    -content_type "contact_complaint" \
		    -attribute_name "employee_id" \
		    -datatype "integer" \
		    -pretty_name "Employee ID" \
		    -sort_order 8 \
		    -column_spec "integer constraint contact_complaint_track_employee_fk
                                  references parties(party_id) on delete cascade"

		content::type::attribute::new \
		    -content_type "contact_complaint" \
		    -attribute_name "refund_amount" \
		    -datatype "money" \
		    -pretty_name "Refund" \
		    -sort_order 9 \
		    -column_spec "float"

	    }
	}
}