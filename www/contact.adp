<master src="/packages/contacts/lib/contact-master">
<property name="party_id">@party_id@</property>

<table width="100%">
  <tr>
    <td valign="top" width="70%">

      <formtemplate id="party_ae" style="proper"></formtemplate>

<!--      <include src="/packages/tasks/lib/tasks" party_id="@party_id@" hide_form_p="t"> -->

    </td>
    <td valign="top" width="30%" style="padding: 0px 0px 0px 15px;" class="summaries">

      <include src="/packages/contacts/lib/groups" party_id="@party_id@" hide_form_p="t">

      <include src="/packages/contacts/lib/relationships" party_id="@party_id@">

      <include src="/packages/contacts/lib/comments" party_id="@party_id@" limit="3" truncate_len="100" size="small" recent_on_top_p="1">

    </td>
  </tr>
</table>
<if @update_date@ not nil><p style="padding-top: 0px; margin-top: 0px;"><small>Last updated: @update_date@</small></p></if>


<if @admin_url@ not nil>
@admin_url;noquote@
</if>
