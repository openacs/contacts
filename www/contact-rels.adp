<master src="/packages/contacts/lib/contact-master">
<property name="party_id">@party_id@</property>
<property name="focus">search.searchterm</property>


<p>
<formtemplate id="search" style="proper-inline"></formtemplate>
</p>

<if @query@ not nil>
<listtemplate name="contacts"></listtemplate>
</if>

<include src="/packages/contacts/lib/relationships" party_id="@party_id@">
