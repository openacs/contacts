<master src="/packages/contacts/lib/contact-master" />
<property name="party_id">@party_id@</property>

<include src="/packages/mail-tracking/lib/messages" 
	recipient_id="@party_id@" 
	page="@page@" 
	page_size="25"
        />