<master src="/packages/contacts/lib/contacts-master" />

<formtemplate id="advanced_search" style="../../../contacts/resources/forms/inline"></formtemplate>


<if @query_code@ not nil and @sw_admin_p@>
<h3>#contacts.lt_Debugging_Code_-_Only#</h3>

@query_code;noquote@
</if>

