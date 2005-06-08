ad_library {

    Init file for contacts

    @author Matthew Geddert (openacs@geddert.com)
    @creation-date 2004-08-16
}

if {[empty_string_p [info procs callback]]} {
    ad_proc -public callback {
	-catch:boolean
	{-impl *}
	callback
	args
    } {
	Placeholder for contacts to work on 5.1
    } {
    }
}
