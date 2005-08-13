<?xml version="1.0"?>
<queryset>

<fullquery name="contact::util::generate_filename.get_parties_existing_filenames">
  <querytext>
    select name
      from cr_items
     where parent_id = :party_id
  </querytext>
</fullquery>

<fullquery name="contact::groups.get_groups">
  <querytext>
    select groups.group_id,
           groups.group_name,
           ( select count(distinct gamm.member_id) from group_approved_member_map gamm where gamm.group_id = groups.group_id ) as member_count,
           ( select count(distinct gcm.component_id) from group_component_map gcm where gcm.group_id = groups.group_id) as component_count,
           CASE WHEN package_id is not null THEN '1' ELSE '0' END as mapped_p,
           CASE WHEN default_p THEN '1' ELSE '0' END as default_p
      from groups left join contact_groups on ( groups.group_id = contact_groups.group_id )
     where groups.group_id not in ('-1','[contacts::default_group]')
       and groups.group_id not in ( select gcm.component_id from group_component_map gcm where gcm.group_id != -1 )
       $filter_clause
     order by mapped_p desc, CASE WHEN contact_groups.default_p THEN '000000000' ELSE upper(groups.group_name) END
  </querytext>
</fullquery>

<fullquery name="contact::groups.get_components">
  <querytext>
            select groups.group_id,
                   groups.group_name,
                   ( select count(distinct gamm.member_id) from group_approved_member_map gamm where gamm.group_id = groups.group_id ) as member_count,
                   CASE WHEN package_id is not null THEN '1' ELSE '0' END as mapped_p,
                   CASE WHEN default_p THEN '1' ELSE '0' END as default_p
              from groups left join contact_groups on ( groups.group_id = contact_groups.group_id ), group_component_map
             where group_component_map.group_id = :group_id
               and group_component_map.component_id = groups.group_id
             order by upper(groups.group_name)
  </querytext>
</fullquery>

<fullquery name="contact::group::parent.get_parent">
  <querytext>
            select group_id
              from group_component_map
             where component_id = :group_id
               and group_id != '-1'
  </querytext>
</fullquery>

<fullquery name="contact::group::new.create_group">
  <querytext>
	select acs_group__new (
                :group_id,
                'group',
                now(),
                :creation_user,
                :creation_ip,
                :email,
                :url,
                :group_name,
                :join_policy,
                :context_id
        )
  </querytext>
</fullquery>

<fullquery name="contact::group::map.map_group">
  <querytext>
        insert into contact_groups
        (group_id,default_p,package_id)
        values
        (:group_id,:default_p,:package_id)
  </querytext>
</fullquery>

</queryset>
