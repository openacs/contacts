ad_page_contract {


    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {attribute_id:integer,multiple}
    {object_id:integer,notnull}
}


foreach attribute_id $attribute_id {
    db_dml map_the_attribute {
        update contact_attribute_object_map set required_p = 'f' where object_id = :object_id and attribute_id = :attribute_id
    }
}

ad_returnredirect "object-map?object_id=$object_id"
ad_script_abort
