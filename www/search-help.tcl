ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
} -validate {
}
set admin_p [permission::permission_p -party_id [ad_conn user_id] -object_id [ad_conn package_id] -privilege admin]
#set default_group_id [contacts::default_group_id]
set title "[_ contacts.Search_Help]"
set context [list $title]

