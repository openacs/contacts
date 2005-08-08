<? xml version="1.0" ?>

<queryset>

<fullquery name="contact::complaint::new.insert_complaint">
    <querytext>
	insert into
		contact_complaint_tracking 
		(complaint_id,customer_id,turnover,percent,supplier_id,paid,object_id,state)
		values
		(:complaint_id,:customer_id,:turnover,:percent,:supplier_id,:paid,:object_id,:state)
    </querytext>
</fullquery>

<fullquery name="contact::complaint::new.get_item_id">
    <querytext>
	select
		item_id
	from 
		cr_revisions
	where
		revision_id = :complaint_id
    </querytext>
</fullquery>

</queryset>

