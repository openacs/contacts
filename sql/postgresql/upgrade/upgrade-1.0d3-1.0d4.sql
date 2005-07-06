-- contacts/sql/postgresql/upgrade/upgrade-1.0d3-1.0d4.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2005-07-06
-- @cvs-id $Id$
--
--


-- create contact application groups

create or replace function contacts_upgrade_1d3_to_1d4 ()
returns integer as '
declare
  package                  record;
  member                   record;
begin

  FOR package IN select application_group__new (
                 acs_object_id_seq.nextval,
                 ''application_group'',
                 now(),
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 ''#contacts.All_Contacts#'',
                 package_id,
                 package_id
                 ) as new_group_id, package_id from apm_packages where package_key = ''contacts''
  LOOP
      FOR member IN select distinct member_id from group_member_map where group_id = ''-2''
      LOOP
      END LOOP;


  END LOOP;

  return ''1'';
  
end;' language 'plpgsql' stable strict;

drop function contacts_upgrade_1d3_to_1d4();

-- create new relations
