<if @hide_form_p@ false>
<if @no_more_available_p@ nil>
<formtemplate id="add_to_group" style="../../../contacts/resources/forms/inline"></formtemplate>
</if>
<else>
<p>#contacts.lt_You_cannot_add_this_c#</p>
</else>
</if>
<if @groups:rowcount@ gt 0>
<h3 class="contact-title"><if @hide_form_p@ true><a href="./groups"></if>#contacts.Groups#<if @hide_form_p@ true></a></if></h3>
<ul>
<multiple name="groups">
<if @groups.sub_p@>(</if><else><li></else>
@groups.group;noquote@ <a href="@groups.remove_url@"><img src="/resources/acs-subsite/Delete16.gif" width="16" height="16" border="0" alt="#contacts.Delete_from# @groups.group;noquote@"></a>
<if @groups.sub_p@>)</if>
</multiple>
</ul>
</if>
<else>
<if @hide_form_p@ true><h3 class="contact-title"><a href="./groups">#contacts.Groups#</a></h3></if>
</else>

<if @hide_form_p@ false and @delete_p@>
<h3>#contacts.Other_Options#</h3>
<ul class="action-links">
  <li><a href="@remove_url@">#contacts.lt_Delete_this_contact#</a>
<if @upgrade_url@ not nil>
  <li><a href="@upgrade_url@">#contacts.lt_Upgrade_this_person_to_a_user#</a>
</if>
</ul>
</if>
