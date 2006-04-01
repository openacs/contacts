<master src="/packages/contacts/lib/contacts-master" />

<p><formtemplate id="search" style="../../../contacts/resources/forms/inline"></formtemplate></p>
<if @aggregated_p@>
   <include src="../lib/contacts-aggregated" 
	base_url="@package_url@" 
	attr_id=@aggregate_attribute_id@ 
	search_id=@search_id@
	extend_id=@aggregate_extend_id@
	>
</if>
<else>
   <include src="../lib/contacts" 
	base_url="@package_url@" 
	extend_p="@extend_p@" 
	extend_values="@extend_values@"
	search_id="@search_id@"
   >
</else>
