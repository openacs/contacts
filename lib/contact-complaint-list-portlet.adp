<master src="@portlet_layout@">
<property name="portlet_title">#contacts.Complaints#</property>

<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
           <include src="/packages/contacts/lib/contact-complaint-list"
	       customer_id="@customer_id@"
               elements="@elements@" />
        </td>
      </tr>
      <tr>
        <td>
        <form action="/contacts/add-edit-complaint">
        #contacts.Add_complaint_to#: @select_menu;noquote@
             <input type="hidden" name="customer_id" value="@customer_id@">
             <input type="submit" value="#contacts.Add_1#">
        </form>
	<br />
        </td>
      </tr> 
    </table>
  </td>
</tr>
</table>


