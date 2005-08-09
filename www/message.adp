<if @party_count@ gt 1>
<master>
<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
    <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>
</if>
<else>
<master src="/packages/contacts/lib/contact-master">
<property name="party_id">@party_id@</property>
<if @party_ids@ eq "">
<p>@error_message;noquote@</p>
</if>
</else>
<property name="focus">comment_add.comment</property>

<if @party_ids@ ne "">
  <if @message_type@ eq "">
    <formtemplate id="message"></formtemplate>
  </if>
  <else>
    
    <include 
        src=/packages/contacts/lib/@message_type@
        return_url=@return_url@ 
        party_ids=@party_ids@ 
        file_ids=@file_ids@ 
	item_id=@item_id@
        signature_id=@signature_id@ 
        recipients=@recipients;noquote@
        footer_id=@footer_id@
        header_id=@header_id@
        >
  </else>
</if>
<if @party_count@ eq 1>
    <include src="/packages/mail-tracking/lib/messages" recipient_id="@party_id@">
</if>
