ad_page_contract {


    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {attribute_id:integer,multiple}
    {object_id:integer,notnull}
}


db_0or1row get_latest_sort_order {}

if { ![exists_and_not_null sort_order] } {
    set sort_order 0
}
foreach attribute_id $attribute_id {
    incr sort_order
    db_1row map_attribute {}
}

ad_returnredirect "object-map?object_id=$object_id"
ad_script_abort