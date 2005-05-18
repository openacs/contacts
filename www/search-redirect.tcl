ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {query:notnull}
    {object_type:notnull}
    {all_any:notnull}
} -validate {
}
#ad_return_error "Error" $query
#ad_returnredirect [export_vars -base "search" -url {query object_type all_any}]
rp_internal_redirect search
ad_script_abort









