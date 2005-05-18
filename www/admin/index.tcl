ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
}


set orderby "name"
set title "Contact Administration"
set context {}
set package_id [ad_conn package_id]

template::list::create \
    -name "groups" \
    -multirow "groups" \
    -row_pretty_plural "groups" \
    -elements {
        edit {
	    label {}
	    display_template {
		<a href="group-ae?group_id=@groups.group_id@"><img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border= "0" alt="Edit"></a>
	    }
	}
        group_name {
            label {Group}
	    display_col group_name
        }
        member_count {
            label {\# Contacts}
	    display_col member_count
            link_url_eval $group_url
        }
        mapped {
            label {Mapped}
            display_template {
                <if @groups.mapped_p@>
                  <a href="group-map?action=unmap&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkboxchecked.gif" border="0" height="13" width="13" alt="True"></a>
                </if>
                <else>
                  <a href="group-map?action=map&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkbox.gif" border="0" height="13" width="13" alt="False"></a>
                </else>
            }
        }
        default {
            label {Default}
            display_template {
                <if @groups.default_p@>
                  <img src="/resources/acs-subsite/checkboxchecked.gif" border="0" height="13" width="13" alt="True">
                </if>
                <else>
                  <if @groups.mapped_p@ and @groups.level@ eq 1>
                  <a href="group-map?action=makedefault&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkbox.gif" border="0" height="13" width="13" alt="False"></a>
                  </if>
                  <else>
                  </else>
                </else>
            }
        }
        person_form {
            display_template {
                <a href="@groups.ams_person_url@" class="button">Person Form</a>
            }
        }
        org_form {
            display_template {
                <a href="@groups.ams_org_url@" class="button">Organization Form</a>
            }
        }
	actions {
	    display_template {
		<if @groups.level@ eq 1><a href="permissions?group_id=@groups.group_id@" class="button">Permissions</a></if>
	    }
        }
    } -filters {
    } -orderby {
    }

#ad_return_error "ERROR" [contact::groups -indent_with "..." -expand "all" -output "all" -privilege_required "admin"]

multirow create groups group_id group_name group_url ams_person_url ams_org_url member_count level mapped_p default_p

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
                          -return_url [ad_conn url] \
                          -return_url_label "Return to \"$title\""]
    set ams_org_url [ams::list::url \
                          -package_key "contacts" \
                          -object_type "organization" \
                          -list_name "${package_id}__${group_id}" \
                          -pretty_name "${package_id}__${group_id}" \
                          -return_url [ad_conn url] \
                          -return_url_label "Return to \"$title\""]
    multirow append groups [lindex $group 1] [lindex $group 0] "../?group_id=${group_id}" $ams_person_url $ams_org_url $member_count $level $mapped_p $default_p


}





ad_return_template
