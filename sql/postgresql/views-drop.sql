-- views-drop.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28
-- @cvs-id $Id$
--
--

drop table contact_view_names;
drop table contact_views;

delete from acs_objects where object_type = 'contact_view';
create function inline_0 ()
returns integer as '
begin

  PERFORM acs_object_type__drop_type (''contact_view'',''f'');

  return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();
