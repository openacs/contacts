<p>
    <formtemplate id="search" style="../../resources/forms/inline"></formtemplate>
</p>
<if @aggregated_p@>
   <include src="/packages/contacts/lib/contacts-aggregated" 
	base_url="/contacts/" 
	attr_id="@aggregate_attribute_id@"
	search_id="@search_id@">
</if>
<else>
   <include src="/packages/contacts/lib/contacts" 
	base_url="/contacts/" 
	extend_p="@extend_p@" 
	extend_values="@extend_values@"
   >
</else>
        


