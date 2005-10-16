<master src="@portlet_layout@">
<property name="portlet_title">#contacts.Tasks#</property>


<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
	     <include
        	src="/packages/tasks/lib/tasks"
	        party_id="@party_id@"
                row_list="@row_list@"
                package_id="@package_id@"
        	hide_form_p="t" 
		page="@page@"
		tasks_orderby="@tasks_orderby@"
		page_flush_p="@page_flush_p@"
		page_size="@page_size@" />	
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>