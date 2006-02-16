ad_library {
    
    Callback procs for contacts
    
    @author Matthew Geddert (openacs@geddert.com)
    @creation-date 2006-02-06
    @arch-tag: 
    @cvs-id $Id$
}

ad_proc -public -callback contacts::redirect -impl labels {
    {-party_id ""}
    {-action ""}
} {
    redirect the contact to the correct pdf stuff
} {
    set url [ad_conn url]
    if { [regexp {^/contacts/pdfs/} $url match] } {
	# this is a pdf url
	if { $url == "/contacts/pdfs/" } {
	    rp_internal_redirect "/packages/contacts/lib/pdfs"
	} else {
	    set filename [lindex [ad_conn urlv] end]
	    if { ![regsub "^contacts_labels_[ad_conn user_id](.*).pdf$" $filename {} bogus] || ![file exists "/tmp/${filename}"] } {
		ad_return_error "No Permission" "You do not have permission to view this file, or the temporary file has been deleted."
	    } else {
		ns_returnfile 200 "application/pdf" "/tmp/${filename}"
	    }
	}
    }

}

