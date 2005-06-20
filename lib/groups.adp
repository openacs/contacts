<if @hide_form_p@ false>
<if @no_more_available_p@ nil>
<formtemplate id="add_to_group" style="../../../contacts/resources/forms/inline"></formtemplate>
</if>
<else>
<p>#contacts.lt_You_cannot_add_this_c#</p>
</else>
</if>
<if @groups:rowcount@ gt 0>
<h3 class="contact-title"><a href="./groups">#contacts.Groups#</a></h3>
<ul>
<multiple name="groups">
<if @groups.sub_p@>(</if><else><li></else>
@groups.group;noquote@
<if @groups.sub_p@>)</if>
</multiple>
</ul>
</if>
<else>
<strong>#contacts.lt_This_contact_is_not_p#</strong>
</else>

