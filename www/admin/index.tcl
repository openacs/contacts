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
set ams_parameter_url [export_vars -base "/shared/parameters" {{package_id "[apm_package_id_from_key ams]"} {return_url "[ad_conn url]"}}]
template::list::create \
    -name "groups" \
    -multirow "groups" \
    -row_pretty_plural "[_ contacts.groups]" \
    -elements {
        edit {
	    label {}
	    display_template {
		<if @groups.dotlrn_community_p;literal@ false><a href="@groups.edit_url@"><img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border= "0" alt="[_ acs-kernel.common_Edit]"></a></if>
	    }
	}
        group_name {
            label {Group}
	    display_col group_name
        }
        member_count {
            label {[_ contacts.Contacts]}
	    display_template {
		<a href="../?search_id=@groups.group_id@">@groups.member_count@</a>
	    }
        }
        mapped {
            label {Mapped}
            display_template {
                <if @groups.mapped_p;literal@ true>
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
                <if @groups.dotlrn_community_p;literal@ false>
                <if @groups.default_p;literal@ true>
                  <img src="/resources/acs-subsite/checkboxchecked.gif" border="0" height="13" width="13" alt="[_ contacts.True]">
                </if>
                <else>
                  <if @groups.mapped_p;literal@ true and @groups.level@ eq 1>
                  <a href="group-map?action=makedefault&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkbox.gif" border="0" height="13" width="13" alt="[_ contacts.False]"></a>
                  </if>
                  <else>
                  </else>
                </else>
                </if>
            }
        }
        notifications {
            label {Notifications}
            display_template {
                <if @groups.dotlrn_community_p@ false and @groups.mapped_p@ and @groups.level@ eq 1>
                <if @groups.notifications_p;literal@ true>
                  <a href="group-map?action=notificationsoff&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkboxchecked.gif" border="0" height="13" width="13" alt="[_ contacts.True]"></a>
                </if>
                <else>
                  <a href="group-map?action=notificationson&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkbox.gif" border="0" height="13" width="13" alt="[_ contacts.False]"></a>
                </else>
                </if>
            }
        }
        user_change {
            label {User Change}
            display_template {
                <if @groups.dotlrn_community_p;literal@ false>
                <if @groups.user_change_p;literal@ true>
                  <a href="group-user-change?action=disallow&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkboxchecked.gif" border="0" height="13" width="13" alt="[_ contacts.True]"></a>
                </if>
                <else>
                  <a href="group-user-change?action=allow&group_id=@groups.group_id@"><img src="/resources/acs-subsite/checkbox.gif" border="0" height="13" width="13" alt="[_ contacts.False]"></a>
                </else>
                </if>
            }
        }
        person_form {
            display_template {
                <if @groups.dotlrn_community_p;literal@ false>
                <a href="@groups.ams_person_url@" class="button">[_ contacts.Person_Form]</a>
                </if>
            }
        }
        org_form {
            display_template {
                <if @groups.dotlrn_community_p;literal@ false>
                <a href="@groups.ams_org_url@" class="button">[_ contacts.Organization_Form]</a>
                </if>
            }
        }
	categories {
	    display_template {
                <if @groups.dotlrn_community_p;literal@ false>
		<a href="@groups.categories_url@" class="button">[_ contacts.Manage_group_categories]</a>
                </if>
	    }
	}
	actions {
	    display_template {
                <if @groups.dotlrn_community_p;literal@ false>
		<if @groups.level@ eq 1><a href="permissions?group_id=@groups.group_id@" class="button">[_ contacts.Permissions]</a></if>
                </if>
                <else>
                #contacts.dotLRN_Managed#
                </else>
	    }
        }
    } -filters {
    } -orderby {
    }


multirow create groups group_id group_name group_url ams_person_url ams_org_url member_count level mapped_p default_p categories_url edit_url user_change_p dotlrn_community_p notifications_p

set return_url [ad_conn url]
foreach group [contact::groups -indent_with "..." -expand "all" -output "all" -privilege_required "admin" -all -include_dotlrn_p "1"] {
    util_unlist $group group_name group_id member_count level mapped_p default_p user_change_p dotlrn_community_p

    set notifications_p [contact::group::notifications_p -group_id $group_id]

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

    # The edit_url allows you to change the name of a group. As this is stored in I18N format, we change it accordingly there
    set edit_url [export_vars -base "/acs-lang/admin/edit-localized-message" {{package_key acs-translations} {locale "[ad_conn locale]"} {message_key "group_title_${group_id}"} {return_url [ad_return_url]}}]

    set categories_url [export_vars -base "/categories/cadmin/object-map" -url {{object_id $group_id}}]
    multirow append groups [lindex $group 1] [lindex $group 0] "../?group_id=${group_id}" $ams_person_url $ams_org_url $member_count $level $mapped_p $default_p $categories_url $edit_url $user_change_p $dotlrn_community_p $notifications_p


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
if {[attribute::id -object_type "organization" -attribute_name "short_name"] eq ""} {
    set populate_url [export_vars -base "populate" -url {{populate_type "crm"}}]
} else {
    set populate_url ""
}
