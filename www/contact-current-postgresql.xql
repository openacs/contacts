<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="unarchive_contact">
      <querytext>

	delete from contact_archives where party_id = :party_id

      </querytext>
</fullquery>


</queryset>
