ad_library {

  Support procs for the contacts package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

}


namespace eval contacts::view:: {

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

