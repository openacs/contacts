<master src="/packages/contacts/lib/contact-master">
<property name="party_id">@party_id@</property>


<if @upload_count@ eq 1 and @files:rowcount@ gt 0>
<listtemplate name="files"></listtemplate>
</if>

<formtemplate id="upload_files" style="../../../contacts/resources/forms/file-upload"></formtemplate>

