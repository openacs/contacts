<master src="@portlet_layout@">
<property name="portlet_title">#contacts.Working_project_tasks#</property>


<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
	    <include src="/packages/project-manager/lib/all-party-tasks"
                from_party_id="@from_party_id@"
		page="@page@"
		page_size="@page_size@"
		orderby_p="@orderby_p@"
		pt_orderby="@pt_orderby@"
		elements="@elements@"
	    />
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>