ad_page_contract {

    Update sort order

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    sort_key:array
    object_id:integer,notnull
}


set count 0

# first we get rid of the old sort order
db_dml delete_previous_sort_orders {}
db_foreach get_attributes {} {
    if {[info exists sort_key($attribute_id)]} {
        set sort_order_temp $sort_key($attribute_id)
        db_dml update_sort_order {}
    }
}

ad_returnredirect "object-map?object_id=$object_id"
