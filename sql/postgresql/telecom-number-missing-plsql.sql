-- telecom-number-missing-plsql.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28
-- @cvs-id $Id$
--


create function inline_0 () 
returns integer as '  
declare
    v_telecom_number_p     boolean;
begin 
    v_telecom_number_p := ''1'' from acs_object_types where object_type = ''telecom_number'';

    if v_telecom_number_p then
    else
    PERFORM acs_object_type__create_type (  
      ''telecom_number'', -- object_type  
      ''Telecom Number'', -- pretty_name 
      ''Telecom Number'',  -- pretty_plural 
      ''acs_object'',   -- supertype 
      ''telecom_numbers'',  -- table_name 
      ''number_id'', -- id_column 
      ''telecom_number'', -- package_name 
      ''f'', -- abstract_p 
      null, -- type_extension_table 
      null -- name_method 
  ); 
    end if;
 
  return 0;  
end;' language 'plpgsql'; 

select inline_0 (); 

drop function inline_0 ();
