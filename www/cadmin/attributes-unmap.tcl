ad_page_contract {
     
    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {attribute_id:integer,multiple}
    {object_id:integer,notnull}
}


db_0or1row get_latest_sort_order {}

foreach attribute_id $attribute_id {
    db_dml unmap_attribute {}
}

ad_returnredirect "object-map?object_id=$object_id"
ad_script_abort
