ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28


} {
    {orderby "name"}
}

set title "Contact Administration"
set context {}
set package_id [ad_conn package_id]


# db_multirow categories select_categories { select * from contact_categories where parent_id is null }


set organization_object_id [contacts::util::organization_object_id]
set person_object_id [contacts::util::person_object_id]



ad_return_template
