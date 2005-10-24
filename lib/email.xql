<?xml version="1.0"?>
<queryset>

<fullquery name="get_file_title">
    <querytext>
	select 
		title 
	from 
		cr_revisions 
	where 
		revision_id = :file
    </querytext>
</fullquery>

<fullquery name="get_attribute_id">
    <querytext>
	 select 
		attribute_id 
	from 
		ams_attributes 
	where 
		attribute_name = 'salutation';	
    </querytext>
</fullquery>

</queryset>