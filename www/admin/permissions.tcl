ad_page_contract {
    Permissions for contacts and contact-attributes

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    object_id:integer
}
set object_name [db_string get_object_name {}]
set title "Permissions for $object_name"
set context [list $title]

