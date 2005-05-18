<if @hide_form_p@ false>
<if @addable_groups:rowcount@ gt 0>
<form name="add_to_group" method="post" action="group-party-add">
<input type="hidden" name="party_id" value="@party_id@" />
<table cellpadding="0" cellspacing="0" border="0">
<tr><td>
<select name="group_id" >
 <option value="">-- select a group --</option>
<multiple name="addable_groups">
  <option value="@addable_groups.group_id@">@addable_groups.group@</option>
</multiple>
</select>
</td>
<td><input type="submit" name="formbutton:create" value="Add to Group" class="button" /></td>
</tr>
</table>
</if>
<else>
<p>You cannot add this contact to more groups.</p>
</else>
</if>
<if @groups:rowcount@ gt 0>
<div class="groups">
<h3>Groups</h3>
<ul>
<multiple name="groups">
<if @groups.sub_p@>(</if><else><li></else>
@groups.group;noquote@
<if @groups.sub_p@>)</if>
</multiple>
</ul>
</div>
</if>
<else>
<strong>This contact is not part of any groups - this is a problem.</strong>
</else>
