-- attributes-drop.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28
-- @cvs-id $Id$
--
--

drop table contact_attribute_object_map;
drop table contact_attribute_values;
drop table contact_attribute_option_map;
drop table contact_attribute_option_map_ids;
drop table contact_attribute_options;
drop table contact_attribute_names;
drop table contact_attributes;
drop table contact_widgets;
drop table contact_storage_types;

drop sequence contact_widget_id_seq;
drop sequence contact_attribute_options_id_seq;
drop sequence contact_attribute_option_map_id_seq;

delete from acs_objects where object_type = 'contact_attribute';
create function inline_0 ()
returns integer as '
begin

  PERFORM acs_object_type__drop_type (''contact_attribute'',''f'');

  return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();
