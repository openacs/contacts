ad_library {

    Contact search widget for the OpenACS templating system.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2006-03-24
    @cvs-id $Id$

}

namespace eval template {}
namespace eval template::data {}
namespace eval template::data::transform {}
namespace eval template::data::validate {}
namespace eval template::widget {}

ad_proc -public template::widget::contact_search { element_reference tag_attributes } {

    A widget that searches for contacts (persons and organizations) and lets
    the user select one from the search results.

    <p>

    By default it searchs only for persons unless the type is specified as organization or party (in which case both are looked for).

    @author Matthew Geddert
} {

    upvar $element_reference element

    if { ![info exists element(html)] } {
	set element(html) [list]
    }

    if { ![info exists element(options)] } {
	if { [lsearch $element(html) size] < 0 } {
	    lappend element(html) size 20
	}        
	if { [lsearch $element(html) maxlength] < 0 } {
	    lappend element(html) maxlength 255
	}        
        # initial submission or no data (no options): a text box
        set output [input text element $tag_attributes]

    } else {

        set output "<input type=\"hidden\" name=\"$element(id):select\" value=\"t\" />"
        append output "<input type=\"hidden\" name=\"$element(id):query\" value=\"$element(query)\" />"

        if { ![info exists element(confirmed_p)] } {
            append output "<input type=\"hidden\" name=\"$element(id):confirmed_p\" value=\"t\" />"
        }
        
	if { [lsearch $element(html) size] < 0 } {
	    lappend element(html) size 7
	}        
        append output [select $element_reference $tag_attributes]
    }
    return $output
}

ad_proc -public template::data::validate::contact_search { value_ref message_ref } {
    return 1
}

ad_proc -public template::data::transform::contact_search { element_ref } {

    upvar $element_ref element
    set element_id $element(id)

    set value [string trim [ns_queryget $element_id]]
    set is_optional [info exists element(optional)]

    if { [empty_string_p $value] } {
        if { [string is true $is_optional] } {
	    return ""
	} else {
	    template::element::set_error $element(form_id) $element_id "[_ contacts.Enter_a_query]"
	    return [list]
	}
    }

    if { [string equal $value ":search:"] } {
        # user has selected 'search again' previously
        template::element::set_error $element(form_id) $element_id "[_ contacts.Enter_a_query]"
        return [list]
    }
     
    if { [ns_queryexists $element_id:search_string] } {
        # request comes from a page with a select widget and the
        # search string has been passed as hidden value
        set query [ns_queryget $element_id:query]
        set element(query) $query

        # the value to be returned
        set value [ns_queryget $element_id]
    } else {
        # request is an initial search
        set query $value
        set element(query) $value
    }


    if { [info exists element(search)] } {
	set search $element(search)
    } else {
	set search "contacts"
    }

    switch $search {
	persons {
	    set persons_p 1
	    set orgs_p 0
	}
	organizations {
	    set persons_p 0
	    set orgs_p 1
	}
	contacts {
	    set persons_p 1
	    set orgs_p 1
	}
	default {
	    # this error will be caught by developers and does not need
	    # to be converted to an acs-lang message
	    error "The type of '$search' was specified and is not valid for the widget '$element_id', the only valid options are: persons, organizations and contacts (default)"
	}
    }


    if { [info exists element(package_id)] } {
	# the programmer specified a contacts
        # instance from which to search for contacts
	set package_id $element(package_id)
    } else {
	if { [ad_conn package_key] eq "contacts" } {
	    # we use the package_id from this contacts instance
	    set package_id [ad_conn package_id]
	} else {
	    error "You cannot use the contact_search widget without specifying a package_id of a contacts instance in which to search (done the same way you would specifiy html attributes)"
	}
    }
    set persons [list]
    set orgs [list]
    # search in persons
    if { $persons_p } {
	set persons [db_list_of_lists search_persons {}]
    }
    # search in orgs
    if { $orgs_p } {
	set orgs [db_list_of_lists search_orgs {}]
    }

    if { [llength $persons] == 0 && [llength $orgs] == 0 } {
        # no search results so return text entry back to the user

        catch { unset element(options) }
        template::element::set_error $element(form_id) $element_id [_ contacts.lt_not_matches_for_-query-]

    } else {
        # we need to return a select list

        set options [list]

        if { [llength $persons] > 0 } {
	    if { [llength $persons] > 50 } {
		set options [list [list [_ contacts.lt_Search_again_over_50_people] ":search:"]]
		template::element::set_error $element(form_id) $element_id [_ contacts.lt_To_many_people_found_search_again]
	    } else {
		set options [concat [list [list [_ contacts.--select_a_person--] ""]] $persons]
	    }
        }
        if { [llength $orgs] > 0 } {
	    if { [llength $orgs] > 50 } {
		if { [llength $options] == "0" } {
		    set options [concat $options [list [list [_ contacts.lt_Search_again_over_50_orgs] ":search:"]]]
		} else {
		    set options [concat $options [list [list "---" ""]]]
		    set options [concat $options [list [list [_ contacts.lt_Search_again_over_50_orgs] ":search:"]]]
		}
		if { [llength $persons] > 50 || [llength $persons] == 0 } {
		    template::element::set_error $element(form_id) $element_id [_ contacts.Search_again]
		} else {
		    template::element::set_error $element(form_id) $element_id [_ contacts.lt_To_many_orgs_found_search_again]
		}
	    } else {
		if { $persons_p } {
		    set options [concat $options [list [list "---" ""]]]
		}
		set options [concat $options [list [list [_ contacts.--select_an_organization--] ""]]]
		set options [concat $options $orgs]
	    }
        }
        set options [concat $options [list [list "---" ""]]]
        set element(options) [concat $options [list [list [_ contacts.Search_again] ":search:"]]]
        if { ![info exists value] } {
            # set value to first item
            set value [lindex [lindex $options 0] 1]
        }

        if { ![ns_queryexists $element_id:confirmed_p] && ![template::element::error_p $element(form_id) $element_id] } {
            template::element::set_error $element(form_id) $element_id [_ contacts.Please_choose_a_contact]
        }
    }

    if { [info exists element(result_datatype)] &&
         [ns_queryexists $element_id:select] } {
        set element(datatype) $element(result_datatype)
    }

    return $value
}
