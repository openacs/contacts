-- contacts-package-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28


create function inline_1 ()
returns integer as '
begin

  PERFORM acs_object_type__create_type (
    ''contact_object_type'',
    ''Contact Object Type'',
    ''Contact Object Types'',
    ''acs_object'',
    ''contact_object_types'',
    ''object_id'',
    null,
    ''f'',
    null,
    ''contact__object_type_name''
  );

  return 0;

end;' language 'plpgsql';
select inline_1 ();
drop function inline_1 ();




create or replace function contact__object_type_create (integer,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
        p_object_id       alias for $1;
        p_object_type     alias for $2;
        p_creation_date   alias for $3;
        p_creation_user   alias for $4;
        p_creation_ip     alias for $5;
        p_context_id      alias for $6;
        v_object_id       integer;
begin

        v_object_id := acs_object__new (
                p_object_id,
                ''contact_object_type'',
                p_creation_date,
                p_creation_user,
                P_creation_ip,
                p_context_id
        );


        insert into contact_object_types
               (object_id,object_type)
        values
               (v_object_id,p_object_type);

        return v_object_id;
end;' language 'plpgsql';



create or replace function contact__object_type_name (integer)
returns varchar as '
declare
        p_object_id   alias for $1;
        v_name        varchar;
begin
        v_name := object_type from contact_object_types where object_id = p_object_id;
        return v_name;
end;' language 'plpgsql';






create or replace function contact__party_email (integer)
returns varchar as '
declare
  email__party_id        alias for $1;
begin

  return email from parties where party_id = email__party_id;

end;' language 'plpgsql' stable strict;

create or replace function contact__party_url (integer)
returns varchar as '
declare
  url__party_id          alias for $1;
begin

  return url from parties where party_id = url__party_id;

end;' language 'plpgsql' stable strict;

create or replace function contact__status (integer)
returns varchar as '
declare
  p_party_id           alias for $1;
  v_archived_p         boolean;
begin

  v_archived_p := ''1'' from contact_archives where party_id = p_party_id;

  if v_archived_p then
        return ''archived'';
  else
        return ''current'';
  end if;

end;' language 'plpgsql' stable strict;


create or replace function contact__person_is_user_p (integer)
returns boolean as '
declare
  p_person_id          alias for $1;
  v_result             boolean;
begin

  v_result := ''1'' from users where user_id = p_person_id;

  if v_result then
        return ''t'';
  else
        return ''f'';
  end if;

end;' language 'plpgsql' stable strict;
