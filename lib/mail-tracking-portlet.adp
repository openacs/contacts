<master src="@portlet_layout@">
<property name="portlet_title">#contacts.MailTracking#</property>

<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
	    <include
      		src="/packages/mail-tracking/lib/messages"
      		recipient_id="@party_id@"
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>