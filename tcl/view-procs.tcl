ad_library {

  Support procs for the contacts package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

}


namespace eval contacts::view:: {

    ad_proc -public create {
        {-src}
        {-privilege_required "read"}
        {-privilege_object_id}
        {-contact_object_type}
        {-package_id ""}
        {-sort_order ""}
        {-creation_user ""}
        {-creation_ip ""}
        {-context_id ""}
    } {
        this code returns 1 if the view_id exists for this object_type
    } {
        if { ![exists_and_not_null package_id]    } { set package_id [ad_conn package_id] }
        if { ![exists_and_not_null sort_order]    } {
            db_0or1row select_last_sort_order_value {
                select sort_order from contact_views where contact_object_type = :contact_object_type order by sort_order desc limit 1 
            }
            if { [exists_and_not_null sort_order] } {
                incr sort_order
            } else {
                set sort_order "1"
            }
        }

        db_1row create_contact_view {
            select contact__view_create(
                                        null,
                                        :src,
                                        :privilege_required,
                                        :privilege_object_id,
                                        :contact_object_type,
                                        :package_id,
                                        :sort_order,
                                        now(),
                                        :creation_user,
                                        :creation_ip,
                                        :context_id) as view_id
        }
        return $view_id

    }

    ad_proc -public name {
        {-view_id}
        {-locale "en_US"}
        {-name}
    } {
        this code returns 1 if the view_id exists for this object_type
    } {
        db_1row create_contact_view {
            select contact__view_name_save(
                                           :view_id,
                                           :locale,
                                           :name
                                           )
        }

    }

    ad_proc -private init {} {
        initialize views
    } {

        if { ![db_0or1row views_exist_p { select '1' from contact_views limit 1 } ] } {

            db_1row get_package_id { select package_id from apm_packages where package_key = 'contacts' }

            set view_id [contacts::view::create -src "/packages/contacts/www/view/contact-view" \
                             -privilege_required "read" \
                             -privilege_object_id $package_id \
                             -contact_object_type "organization" \
                             -package_id $package_id \
                             -sort_order "1"]
            contacts::view::name -view_id $view_id -name "Contact Info"
            
            set view_id [contacts::view::create -src "/packages/contacts/www/view/comments-view" \
                             -privilege_required "read" \
                             -privilege_object_id $package_id \
                             -contact_object_type "organization" \
                             -package_id $package_id \
                             -sort_order "1"]
            contacts::view::name -view_id $view_id -name "Comments"

            set view_id [contacts::view::create -src "/packages/contacts/www/view/contact-view" \
                             -privilege_required "read" \
                             -privilege_object_id $package_id \
                             -contact_object_type "person" \
                             -package_id $package_id \
                             -sort_order "1"]
            contacts::view::name -view_id $view_id -name "Contact Info"

            set view_id [contacts::view::create -src "/packages/contacts/www/view/comments-view" \
                             -privilege_required "read" \
                             -privilege_object_id $package_id \
                             -contact_object_type "person" \
                             -package_id $package_id \
                             -sort_order "1"]
            contacts::view::name -view_id $view_id -name "Comments"

        }

    }

    ad_proc -public exists_p {
        {-object_type ""}
        view_id
    } {
        this code returns 1 if the view_id exists for this object_type
    } {
        return [db_0or1row exists_p_select { select 1 from contact_views where view_id = :view_id and contact_object_type = :object_type }]
    }

    ad_proc -public get {
        {-locale ""}
        view_id
    } {
        get the info on the view
    } {

	db_0or1row get_view_info { 
            select *
              from contact_views
             where view_id = :view_id
        }

        if { ![exists_and_not_null locale] } {
            set locale [lang::conn::locale -site_wide]        
        }
        set view_name [contacts::view::get::name -locale $locale $view_id]

        set view_info [ns_set create]
        ns_set put $view_info src                 $src                 
        ns_set put $view_info privilege_required  $privilege_required  
        ns_set put $view_info privilege_object_id $privilege_object_id 
        ns_set put $view_info contact_object_type $contact_object_type 
        ns_set put $view_info sort_order          $sort_order          
        ns_set put $view_info view_name           $view_name                

        # Now, set the variables in the caller's environment
        ad_ns_set_to_tcl_vars -level 2 $view_info
        ns_set free $view_info

    }



}


namespace eval contacts::view::get:: {

    ad_proc -public name {
        {-locale ""}
        view_id
    } {
        get the view name
    } {

        if { ![exists_and_not_null locale] } {
            set locale [lang::conn::locale -site_wide]        
        }

        db_0or1row get_view_name {
            select name from contact_view_names where view_id = :view_id and locale = :locale
        }

        if { ![exists_and_not_null name] } {
            set locale "en_US"
            db_0or1row get_view_name {
                select name from contact_view_names where view_id = :view_id and locale = :locale
            }
        }
        
        return $name

    }
}

