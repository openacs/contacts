ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {orderby "name"}
}

set title "Contact Administration"
set context {}
set package_id [ad_conn package_id]




set organization_object_id [contacts::util::organization_object_id]
set person_object_id [contacts::util::person_object_id]



ad_return_template
