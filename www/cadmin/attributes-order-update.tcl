ad_page_contract {

    Update sort order

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

} {
    sort_key:array
    object_id:integer,notnull
}


set count 0

# first we get rid of the old sort order
db_dml delete_sort_orders { update contact_attribute_object_map set sort_order = '-1' where object_id = :object_id }
db_foreach get_attributes { select attribute_id from contact_attribute_object_map where object_id = :object_id } {
    if {[info exists sort_key($attribute_id)]} {
        set sort_order_temp $sort_key($attribute_id)
        db_dml update_attribute_object_map {
            update contact_attribute_object_map set sort_order = :sort_order_temp where object_id = :object_id and attribute_id = :attribute_id
        }
    } else {
    }
}

ad_returnredirect "object-map?object_id=$object_id"
