<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<include src="/packages/contacts/lib/contact-complaint-form" 
	complaint_id=@complaint_id@ 
	supplier_id=@supplier_id@ 
	customer_id=@customer_id@ 
	return_url=@return_url@ 
	complaint_object_id=@object_id@ 
	mode=@mode@>