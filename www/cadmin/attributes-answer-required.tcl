ad_page_contract {
     

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {attribute_id:integer,multiple}
    {object_id:integer,notnull}
}


foreach attribute_id $attribute_id {
    db_dml answer_required {}
}

ad_returnredirect "object-map?object_id=$object_id"
ad_script_abort