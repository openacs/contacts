ad_library {

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
    @creation-date 2005-09-08
}

namespace eval contact::extend:: {}

ad_proc -public contact::extend::delete {
    -extend_id:required
} {
    Deletes one contact extend option
    @param extend_id The extend_id to delete
} {
    db_dml extend_delete { }
}

ad_proc -public contact::extend::new {
    -extend_id:required
    -var_name:required
    -pretty_name:required
    -subquery:required
    {-description ""}
} {
    Creates a new contact extend option
} {
    set var_name [string tolower $var_name]
    db_dml new_extend_option { }
}


ad_proc -public contact::extend::update {
    -extend_id:required
    -var_name:required
    -pretty_name:required
    -subquery:required
    {-description ""}
} {
    Updates one contact extend option
} {
    set var_name [string tolower $var_name]
    db_dml update_extend_option { }
}

ad_proc -public contact::extend::var_name_check {
    -var_name:required
} {
    Checks if the name is already present on the contact_extend_options table or not
} {
    set var_name [string tolower $var_name]
    return [db_string check_name { } -default "0"]
}

ad_proc -public contact::extend::get_options { 
    {-ignore_extends ""}
    -search_id:required
} {
    Returns a list of the form { pretty_name extend_id } of all available extend options in
    contact_extend_options, if search_id is passed then ignore the extends in
    contact_search_extend_map

    @param ignore_extends A list of extend_id's to ignore on the result
} {
    set extra_query "where extend_id not in (select extend_id from contact_search_extend_map where search_id = $search_id)"
    if { ![empty_string_p $ignore_extends] } {
	set ignore_extends [join $ignore_extends ","]
	append extra_query "and extend_id not in ($ignore_extends)"
    }

    return [db_list_of_lists get_options " "]
}

ad_proc -public contact::extend::option_info { 
    -extend_id:required
} {
    Returns a list of the form { var_name pretty_name subquery description } of the extend_id
} {
    return [db_list_of_lists get_options { }]
}