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
<property name="party_id">@party_ids@</property>
</else>
<property name="focus">comment_add.comment</property>

<formtemplate id="message"></formtemplate>

