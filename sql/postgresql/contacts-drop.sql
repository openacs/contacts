-- contacts-drop.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28
-- @cvs-id $Id$
--
--


-- The view structure.
\i views-drop.sql

-- The attribute structure.
\i attributes-drop.sql


drop view contacts;
drop table contact_archives;
drop table contact_object_types;

select drop_package('contact');

delete from acs_objects where object_type = 'contact_object_type';
create function inline_0 ()
returns integer as '
begin

  PERFORM acs_object_type__drop_type (''contact_object_type'',''f'');

  return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

