ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
     
} {
    {attribute_id:integer,multiple}
}


foreach attribute_id $attribute_id {
    db_dml depreciate_the_attribute {
        update contact_attributes set depreciated_p = 'f' where attribute_id = :attribute_id
    }
}

ad_returnredirect "attributes"
ad_script_abort
