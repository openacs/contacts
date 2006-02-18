-- 
-- packages/contacts/sql/postgresql/upgrade/upgrade-1.2b4-1.2b5.sql
-- 
-- @author Matthew Geddert (openacs@geddert.com)
-- @creation-date 2006-02-18
-- @arch-tag: 
-- @cvs-id $Id$
--

create function inline_0() returns integer as '
declare 
	v_labels_p   boolean;
begin
	v_labels_p := ''1'' from contact_message_types where message_type = ''label'';

        if v_labels_p is not true then 
	   insert into contact_message_types (message_type) values (''label'',''#contacts.Labels#'');
        end if;

     return 0;

end;' language 'plpgsql';

-- Calling and droping the function
select inline_0();
drop function inline_0();

