ad_library {

  Support procs for attributes in the contacts package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

}

namespace eval contacts::attribute {

    ad_proc -private create {
        {-widget_id:required}
        {-label:required}
        {-help_text ""}
        {-help_p ""}
        {-html ""}
        {-format ""}
    } {
        this code creates a new attributes
    } {
        set creation_user [ad_conn user_id]
        set creation_ip [ad_conn peeraddr]
        return [db_exec_plsql create_attributes { select contact__attribute_create (
                                                                            null,
                                                                            :widget_id,
                                                                            :label,
                                                                            :help_text,
                                                                            :help_p,
                                                                            :html,
                                                                            :format,
                                                                            now(),
                                                                            :creation_user,
                                                                            :creation_ip
                                                                            ) }]
    }


    ad_proc -private delete {
        {-attribute_id:required}
    } {
        this code deletes an attribute
    } {
        return [db_exec_plsql delete_attribute { select contact__attribute_delete (
                                                                                   :attribute_id
                                                                                   ) } ]
    }


    ad_proc -public name {
        {-locale ""}
        attribute_id
    } {
        this code returns the name of an attribute
    } {

        if { ![exists_and_not_null locale] } {
            set locale [lang::conn::locale -site_wide]        
        }

        db_0or1row get_view_name {
            select name from contact_attribute_names where attribute_id = :attribute_id and locale = :locale
        }

        if { ![exists_and_not_null name] } {
            set locale "en_US"
            db_0or1row get_view_name {
                select name from contact_view_names where attribute_id = :attribute_id and locale = :locale
            }
        }
        
        return $name

    }




}


namespace eval contacts::attribute::value {

   ad_proc -private save {
        {-party_id:required}
        {-attribute_id:required}
        {-option_map_id ""}
        {-address_id ""}
        {-number_id ""}
        {-time ""}
        {-value ""}
        {-deleted_p "f"}
    } {
        this code creates a new attributes
    } {
        set creation_user [ad_conn user_id]
        set creation_ip [ad_conn peeraddr]
        return [db_exec_plsql create_attributes { select contact__attribute_value_save (
                                                                            :party_id,
                                                                            :attribute_id,
                                                                            :option_map_id,
                                                                            :address_id,
                                                                            :number_id,
                                                                            :time,
                                                                            :value,
                                                                            :deleted_p,
                                                                            now(),
                                                                            :creation_user,
                                                                            :creation_ip
                                                                            ) }]
    }


}

namespace eval contacts::postal_address {


    ad_proc -private new {
        {-additional_text ""}
        {-country_code ""}
        {-delivery_address ""}
        {-municipality ""}
        {-postal_code ""}
        {-postal_type ""}
        {-region ""}
    } {
        this code saves a contact's address
    } {
        set creation_user [ad_conn user_id]
        set creation_ip [ad_conn peeraddr]

        return [db_exec_plsql save_address { select postal_address__new (
                                                                         :additional_text,
                                                                         null,
                                                                         :country_code,
                                                                         :delivery_address,
                                                                         :municipality,
                                                                         null,
                                                                         :postal_code,
                                                                         :postal_type,
                                                                         :region,
                                                                         :creation_user,
                                                                         :creation_ip,
                                                                         null
                                                                         ) }]
    }

    ad_proc -public get {
        {-address_id:required}
        {-array:required}
    } {
        get the info from addresses
    } {
        upvar $array row

        db_1row select_address_info { select * from postal_addresses where address_id = :address_id } -column_array row
    }

}




namespace eval contacts::telecom_number {

    ad_proc -private new {
        {-area_city_code ""}
        {-best_contact_time ""}
        {-extension ""}
        {-itu_id ""}
        {-location ""}
        {-national_number ""}
        {-sms_enabled_p ""}
        {-subscriber_number ""} 
    } {
        this code saves a contact's phone_number
    } {
        set creation_user [ad_conn user_id]
        set creation_ip [ad_conn peeraddr]

        return [db_exec_plsql save_telecom_number { select telecom_number__new (
                             :area_city_code,
                             :best_contact_time,
                             :extension,
                             :itu_id,
                             :location,
                             :national_number,
                             null,
                             null,
                             null,
                             :sms_enabled_p,
                             :subscriber_number,
                             :creation_user,
                             :creation_ip,
                             null
                             ) }]
    }



    ad_proc -public get {
        {-number_id:required}
        {-array:required}
    } {
        get the variables from phone_numbers
    } {
        upvar $array row
        db_0or1row select_phone_info { select * from telecom_numbers where number_id = :number_id } -column_array row
    }

}


namespace eval contacts::date {

    ad_proc -private sqlify {
        {-date:required}
    } {
        this turns a form date into a timestamp postgresql likes
    } {
        set year [template::util::date::get_property year $date]
        set month [template::util::date::get_property month $date]
        set day [template::util::date::get_property day $date]
        set hours [template::util::date::get_property hours $date]
        set minutes [template::util::date::get_property minutes $date]
        
        set date "$year-$month-$day $hours:$minutes"
        if { $date == "-- :" } {
            set date ""
        }
	return $date
    }


}










