<if @hide_form_p@ false>
<if @no_more_available_p@ nil>
<formtemplate id="add_to_group" style="../../../contacts/resources/forms/inline"></formtemplate>
</if>
<else>
<p>You cannot add this contact to more groups.</p>
</else>
</if>
<if @groups:rowcount@ gt 0>
<h3 class="contact-title">Groups</h3>
<ul>
<multiple name="groups">
<if @groups.sub_p@>(</if><else><li></else>
@groups.group;noquote@
<if @groups.sub_p@>)</if>
</multiple>
</ul>
</if>
<else>
<strong>This contact is not part of any groups - this is a problem.</strong>
</else>
