ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
}


set orderby "name"
set title "[_ contacts.lt_Contact_Administratio]"
set context {}
set package_id [ad_conn package_id]
set parameter_url [export_vars -base "/shared/parameters" {package_id {return_url "[ad_conn url]"}}]
template::list::create \
    -name "groups" \
    -multirow "groups" \
    -row_pretty_plural "[_ contacts.groups]" \
    -elements {
        edit {
	    label {}
	    display_template {
		<a href="group-ae?group_id=@groups.group_id@"><img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border= "0" alt="[_ acs-kernel.common_Edit]"></a>
	    }
	}
        group_name {
            label {Group}
	    display_col group_name
        }
        member_count {
            label {[_ contacts.Contacts]}
	    display_col member_count
            link_url_eval $group_url
        }
        mapped {
            label {Mapped}
            display_template {
                <if @groups.mapped_p@>
                  <a href="group-map?action=unmap&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkboxchecked.gif" border="0" height="13" width="13" alt="[_ contacts.True]"></a>
                </if>
                <else>
                  <a href="group-map?action=map&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkbox.gif" border="0" height="13" width="13" alt="[_ contacts.False]"></a>
                </else>
            }
        }
        default {
            label {Default}
            display_template {
                <if @groups.default_p@>
                  <img src="/resources/acs-subsite/checkboxchecked.gif" border="0" height="13" width="13" alt="[_ contacts.True]">
                </if>
                <else>
                  <if @groups.mapped_p@ and @groups.level@ eq 1>
                  <a href="group-map?action=makedefault&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkbox.gif" border="0" height="13" width="13" alt="[_ contacts.False]"></a>
                  </if>
                  <else>
                  </else>
                </else>
            }
        }
        person_form {
            display_template {
                <a href="@groups.ams_person_url@" class="button">[_ contacts.Person_Form]</a>
            }
        }
        org_form {
            display_template {
                <a href="@groups.ams_org_url@" class="button">[_ contacts.Organization_Form]</a>
            }
        }
	categories {
	    display_template {
		<a href="@groups.categories_url@" class="button">[_ contacts.Manage_group_categories]</a>
	    }
	}
	actions {
	    display_template {
		<if @groups.level@ eq 1><a href="permissions?group_id=@groups.group_id@" class="button">[_ contacts.Permissions]</a></if>
	    }
        }
    } -filters {
    } -orderby {
    }


multirow create groups group_id group_name group_url ams_person_url ams_org_url member_count level mapped_p default_p categories_url

set return_url [ad_conn url]
foreach group [contact::groups -indent_with "..." -expand "all" -output "all" -privilege_required "admin" -all] {
    set group_id [lindex $group 1]
    set group_name [lindex $group 0]
    set member_count [lindex $group 2]
    set level [lindex $group 3]
    set mapped_p [lindex $group 4]
    set default_p [lindex $group 5]
    set ams_person_url [ams::list::url \
                          -package_key "contacts" \
                          -object_type "person" \
                          -list_name "${package_id}__${group_id}" \
                          -pretty_name "${package_id}__${group_id}" \
                          -return_url $return_url \
                          -return_url_label "[_ contacts.Return_to_title]"]
    set ams_org_url [ams::list::url \
                          -package_key "contacts" \
                          -object_type "organization" \
                          -list_name "${package_id}__${group_id}" \
                          -pretty_name "${package_id}__${group_id}" \
                          -return_url $return_url \
                          -return_url_label "[_ contacts.Return_to_title]"]
    set categories_url [export_vars -base "/categories/cadmin/object-map" -url {{object_id $group_id}}]
    multirow append groups [lindex $group 1] [lindex $group 0] "../?group_id=${group_id}" $ams_person_url $ams_org_url $member_count $level $mapped_p $default_p $categories_url


}

set default_group [contacts::default_group]

    set ams_person_url [ams::list::url \
                          -package_key "contacts" \
                          -object_type "person" \
                          -list_name "${package_id}__${default_group}" \
                          -pretty_name "${package_id}__${default_group}" \
                          -return_url $return_url \
                          -return_url_label "[_ contacts.Return_to_title]"]
    set ams_org_url [ams::list::url \
                          -package_key "contacts" \
                          -object_type "organization" \
                          -list_name "${package_id}__${default_group}" \
                          -pretty_name "${package_id}__${default_group}" \
                          -return_url $return_url \
                          -return_url_label "[_ contacts.Return_to_title]"]



ad_return_template
