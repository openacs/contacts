<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="archive_contact">
      <querytext>

        insert into contact_archives (party_id) values (:party_id)

      </querytext>
</fullquery>

 
</queryset>
