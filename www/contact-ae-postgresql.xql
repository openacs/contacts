<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_organization_type_id">
      <querytext>

 	select organization_type_id
	  from contact_attribute_options cao,
               organization_types ot
	 where cao.option = ot.type
	   and cao.option_id  = :option_id_temp

      </querytext>
</fullquery>


<fullquery name="create_org">
      <querytext>

	select organization__new (
				null,
				:contact_attribute__organization_name,
				null,
				:party_id,
				:organization_type_id,
				null,
				null,
				null,
				:creation_user,
				:creation_ip,
				null
				) as party_id

      </querytext>
</fullquery>


<fullquery name="create_person">
      <querytext>

	select person__new (
			:party_id,
			'person',
			now(),
			:creation_user,
			:creation_ip,
			null,
			null,
			:contact_attribute__first_names,
			:contact_attribute__last_name,
			null
			) as party_id

      </querytext>
</fullquery>


</queryset>
