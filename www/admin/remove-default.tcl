#packages/contacts/www/admin/remove-default.tcl
ad_page_contract {
    Remove the default extended options map to one search_id
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Network www.viaro.net
    @creation-date 2005-09-08
} {
    extend_id:multiple,notnull
    search_id:integer,notnull
}

foreach value $extend_id {
    db_dml unmap_extend_id {
	delete from contact_search_extend_map where search_id = :search_id and extend_id = :value
    }
}

ad_returnredirect [get_referrer]