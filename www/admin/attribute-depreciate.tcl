ad_page_contract {
     
    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {attribute_id:integer,multiple}
}


foreach attribute_id $attribute_id {
    db_dml depreciate_attribute {}
}

ad_returnredirect "attributes"
ad_script_abort
