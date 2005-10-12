set master_src [parameter::get -parameter "ContactMaster"]

if {![empty_string_p $project_id]} {
    if {[empty_string_p $customer_id]} {
        set customer_id [db_string get_customer_id "select p.customer_id from pm_projectsx p, cr_items i where p.item_id = :project_id and i.live_revision = p.revision_id"]
    }
    set object_id $project_id
}
