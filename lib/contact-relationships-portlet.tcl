set portlet_layout [parameter::get -parameter "DefaultPortletLayout"]

set relations_url "[site_node::get_package_url -package_key "contacts"]${party_id}/relationships"
