ad_page_contract {
     
    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {attribute_id:integer,multiple}
    {object_id:integer,notnull}
}


db_0or1row get_latest_sort_order {select sort_order from contact_attribute_object_map order by sort_order limit 1 }

foreach attribute_id $attribute_id {
    db_dml unmap_the_attribute {
        delete from contact_attribute_object_map where object_id = :object_id and attribute_id = :attribute_id
    }
}

ad_returnredirect "object-map?object_id=$object_id"
ad_script_abort
