-- contacts/sql/postgresql/upgrade/upgrade-1.0d3-1.0d4.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2005-07-06
-- @cvs-id $Id$
--
--

alter table contact_rels drop column comment; 
alter table contact_rels drop column comment_format;

-- create contact application groups

create or replace function contacts_upgrade_1d3_to_1d4 ()
returns integer as '
declare
  package                  record;
  member                   record;
  delete                   record;
begin

  FOR package IN select application_group__new (
                 acs_object_id_seq.nextval::integer,
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

        RAISE NOTICE ''NEW GROUP ID IS %'', package.new_group_id;
        FOR member IN select distinct member_id, acs_object__name(member_id) as name from group_member_map where group_id = ''-2''
        LOOP

              PERFORM membership_rel__new(
                    NULL,
                    ''contact_rel'',
                    package.new_group_id,
                    member.member_id,
                    ''approved'',
                    NULL,
                    NULL
              );
              RAISE NOTICE ''NEW USER IS % (%)'', member.name, member.member_id;

        END LOOP;

  END LOOP;

  FOR delete IN select rel_id, member_id, acs_object__name(member_id) as name from group_member_map where group_id = ''-2'' and member_id not in ( select user_id from users )
  LOOP

        PERFORM acs_rel__delete(delete.rel_id);
        RAISE NOTICE ''DELETE USER IS % (%)'', delete.name, delete.member_id;
    
  END LOOP;


  return ''1'';
  
end;' language 'plpgsql' stable strict;
select contacts_upgrade_1d3_to_1d4();
drop function contacts_upgrade_1d3_to_1d4();

-- create new relations
        
