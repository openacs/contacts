ad_page_contract {
    Permissions for contacts and contact-attributes

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28

} {
    object_id:integer
}
db_1row get_object_name { select acs_object__name(:object_id) as object_name }
set title "Permissions for $object_name"
set context [list $title]

