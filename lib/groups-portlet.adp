<master src="@portlet_layout@">
<property name="portlet_title">#contacts.Groups#</property>


<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
	    <include src="/packages/contacts/lib/groups" party_id="@party_id@"
	    hide_form_p="@hide_form_p@">
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>