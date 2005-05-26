ad_library {

    Contacts install library
    
    Procedures that deal with installing, instantiating, mounting.

    @creation-date 2005-05-26
    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
}

ad_proc -public -callback contact::contact_form {
    {-package_id:required}
    {-form:required}
    {-object_type:required}
} {
}

ad_proc -public -callback contact::contact_new_form {
    {-package_id:required}
    {-contact_id:required}
    {-form:required}
    {-object_type:required}
} {
}
