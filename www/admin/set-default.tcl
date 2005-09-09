#packages/contacts/www/admin/remove-default.tcl
ad_page_contract {
    Set the default extended options to one search_id
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Network www.viaro.net
    @creation-date 2005-09-08
} {
    extend_id:multiple,notnull
    search_id:integer,notnull
}

foreach value $extend_id {
    db_dml map_extend_id {
	insert into contact_search_extend_map (search_id,extend_id)
	values (:search_id, :value)
    }
}

ad_returnredirect [get_referrer]