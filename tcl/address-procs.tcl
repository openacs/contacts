ad_library {
    Address input widget and datatype for the OpenACS templating system.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
}

namespace eval template {}
namespace eval template::data {}
namespace eval template::data::transform {}
namespace eval template::data::validate {}
namespace eval template::util {}
namespace eval template::util::address {}
namespace eval template::widget {}

ad_proc -public template::util::address { command args } {
    Dispatch procedure for the address object
} {
    eval template::util::address::$command $args
}

ad_proc -public template::util::address::create {
    {contents {}}
    {format {}}
} {
    return [list $contents $format]
}

ad_proc -public template::util::address::acquire { type { value "" } } {
    Create a new address value with some predefined value
    Basically, create and set the address value
} {
  set address_list [template::util::address::create]
  return [template::util::address::set_property $type $address_list $value]
}

ad_proc -public template::util::address::formats {} {
    Returns a list of valid address formats
} {
    return { US CA DE }
}

ad_proc -public template::util::address::country_options {} {
    Returns the country list


    MGEDDERT NOTE: This should be pulled from the db and cached on restart


} {

    set countries_list [db_list_of_lists get_countries { select default_name, iso from countries order by default_name }]
    return $countries_list

#    return { 
#        {"United States" US}
#        {"Canada" CA}
#        {"Germany" DE}
#    }
}

ad_proc -public template::data::validate::address { value_ref message_ref } {

    upvar 2 $message_ref message $value_ref address_list

    set delivery_address [lindex $address_list 0]
    set municipality     [lindex $address_list 1]
    set region           [lindex $address_list 2]
    set postal_code      [lindex $address_list 3]
    set country_code     [lindex $address_list 4]

    if { $country_code == "US" } {
        if { ![db_0or1row validate_state { select 1 from us_states where abbrev = upper(:region) or state_name = upper(:region) } ] } {
            set message "\"$region\" is not a valid US State."
            return 0
        }
    }

    return 1
}    

ad_proc -public template::data::transform::address { element_ref } {

    upvar $element_ref element
    set element_id $element(id)

#    set contents [ns_queryget $element_id]
#    set format [ns_queryget $element_id.format]
    
    set delivery_address [ns_queryget $element_id]
    set municipality     [ns_queryget $element_id.municipality]
    set region           [ns_queryget $element_id.region]
    set postal_code      [ns_queryget $element_id.postal_code]
    set country_code     [ns_queryget $element_id.country_code]



    if { [empty_string_p $delivery_address] } {
        # We need to return the empty list in order for form builder to think of it 
        # as a non-value in case of a required element.
        return [list]
    } else {
        return [list [list $delivery_address $municipality $region $postal_code $country_code]]
    }
}

ad_proc -public template::util::address::set_property { what address_list value } {
    Set a property of the address datatype. 

    @param what One of
      <ul>
        <li>contents (synonyms content, text)</li>
        <li>format (synonym mime_type)</li>
      </ul>

    @param address_list the address list to modify
    @param value the new value

    @return the modified list
} {
    set contents [lindex $address_list 0]
    set format   [lindex $address_list 1]

    switch $what {
        contents - content - text {
            # Replace contents with value
            return [list $value $format]
        }
        format - mime_type {
            # Replace format with value
            return [list $contents $value]
        }
        default {
            error "Invalid property $what, valid properties are text (synonyms content, contents), mime_type (synonym format)."
        }
    }
}

ad_proc -public template::util::address::get_property { what address_list } {
    
    Get a property of the address datatype. Valid properties are: 
    
    @param what the name of the property. Must be one of:
    <ul>
    <li>delivery_address 
    <li>postal_code
    <li>municipality
    <li>region
    <ki>country_code
    </ul>
    @param address_list a address datatype value, usually created with ad_form.
} {
    set delivery_address [lindex $address_list 0]
    set municipality     [lindex $address_list 1]
    set region           [lindex $address_list 2]
    set postal_code      [lindex $address_list 3]
    set country_code     [lindex $address_list 4]


    switch $what {
        delivery_address - street_address {
            return $delivery_address
        }
        postal_code - zip_code - zip {
            return $postal_code
        }
        municipality - city - town {
            return $municipality
        }
        region - state - province {
            return $region
        }
        country_code - country {
            return $country_code
        }

        default {
            error "Parameter supplied to util::address::get_property 'what' must be one of: 'delivery_address', 'postal_code', 'municipality', 'region', 'country_code'. You specified: '$what'."
        }
    }
}

ad_proc -public template::widget::address { element_reference tag_attributes } {
    Implements the address widget.

    If the acs-templating.UseHtmlAreaForAddressP parameter is set to true (1), this will use the htmlArea WYSIWYG editor widget.
    Otherwise, it will use a normal textarea, with a drop-down to select a format. The available formats are:
    <ul>
    <li>Enhanced text = Allows HTML, but automatically inserts line and paragraph breaks.
    <li>Plain text = Automatically inserts line and paragraph breaks, and quotes all HTML-specific characters, such as less-than, greater-than, etc.
    <li>Fixed-width text = Same as plain text, but conserves spacing; useful for tabular data.
    <li>HTML = normal HTML.
    </ul>
    You can also parameterize the address widget with a 'htmlarea_p' attribute, which can be true or false, and which will override the parameter setting.
} {

  upvar $element_reference element

#  if { [info exists element(html)] } {
#    array set attributes $element(html)
#  }

#  array set attributes $tag_attributes

  if { [info exists element(value)] } {
      set delivery_address [template::util::address::get_property delivery_address $element(value)]
      set postal_code      [template::util::address::get_property postal_code $element(value)]
      set municipality     [template::util::address::get_property municipality $element(value)]
      set region           [template::util::address::get_property region $element(value)]
      set country_code     [template::util::address::get_property country_code $element(value)]
  } else {
      set delivery_address {}
      set postal_code      {}
      set municipality     {}
      set region           {}
      set country_code     {US}
  }
  
  set output {}

  if { [string equal $element(mode) "edit"] } {
      

      set attributes(id) \"address__$element(form_id)__$element(id)\"

      append output "
<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\">
  <tr>
    <td colspan=\"3\"><textarea name=\"$element(id)\" rows=\"2\" cols=\"50\" wrap=\"virtual\">[ad_quotehtml $delivery_address]</textarea></td>
  </tr>
  <tr>
    <td colspan=\"3\"><small>Street</small><br></td>
  </tr>
  <tr>
    <td><input type=\"text\" name=\"$element(id).municipality\" value=\"[ad_quotehtml $municipality]\" size=\"20\">&nbsp;&nbsp;</td>
    <td><input type=\"text\" name=\"$element(id).region\" value=\"[ad_quotehtml $region]\" size=\"10\">&nbsp;&nbsp;</td>
    <td><input type=\"text\" name=\"$element(id).postal_code\" value=\"[ad_quotehtml $postal_code]\" size=\"7\">&nbsp;&nbsp;</td>
  </tr>
  <tr>
    <td><small>City</small></td>
    <td><small>State/Province</small></td>
    <td><small>Zip/Postal Code</small></td>
  </tr>
  <tr>
    <td colspan=\"3\">[menu $element(id).country_code [template::util::address::country_options] $country_code attributes]</td>
  </tr>
  <tr>
    <td colspan=\"3\"><small>Country</small></td>
  </tr>
</table>

"

      
#      append output [textarea_internal "$element(id)" attributes $delivery_address]
#      append output "<br />City: <input type=\"text\" name=\"$element(id).municipality\" maxlength=\"100\" size=\"40\" />"
#      append output "<br />State: <input type=\"text\" name=\"$element(id).region\" maxlength=\"100\" size=\"40\" />"
#      append output "<br />Country: [menu "$element(id).country_code" [template::util::address::country_options] $country_code attributes]"
          
  } else {
      # Display mode
      if { [info exists element(value)] } {
          append output [template::util::address::get_property html_value $element(value)]
          append output "<input type=\"hidden\" name=\"$element(id)\" value=\"[ad_quotehtml $contents]\">"
          append output "<input type=\"hidden\" name=\"$element(id).format\" value=\"[ad_quotehtml $format]\">"
      }
  }
      
  return $output
}
