-- attributes-package-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28


create function inline_1 ()
returns integer as '
begin

  PERFORM acs_object_type__create_type (
    ''contact_attribute'',
    ''Contact Attribute'',
    ''Contact Attributes'',
    ''acs_object'',
    ''contact_attributes'',
    ''attribute_id'',
    null,
    ''f'',
    null,
    ''contact__attribute_name''
  );

  return 0;

end;' language 'plpgsql';
select inline_1 ();
drop function inline_1 ();



create or replace function contact__widget_create (varchar,varchar,varchar,varchar,boolean,varchar,varchar,boolean,boolean)
returns integer as '
declare
        p_storage_column  alias for $1;
        p_description     alias for $2; 
        p_widget          alias for $3;
        p_datatype        alias for $4;
        p_help_p          alias for $5; 
        p_html            alias for $6;  
        p_format          alias for $7;
        p_multiple_p      alias for $8;
        p_nospell_p       alias for $9;
        v_widget_id       integer;
begin
        v_widget_id := nextval(''contact_widget_id_seq'');

        insert into contact_widgets
               (widget_id,storage_column,description,widget,datatype,help_p,html,format,multiple_p,nospell_p)
        values
               (v_widget_id,p_storage_column,p_description,p_widget,p_datatype,p_help_p,p_html,p_format,p_multiple_p,p_nospell_p);

        return v_widget_id;
end;' language 'plpgsql';





create or replace function contact__attribute_create (integer,varchar,integer,boolean,timestamptz,integer,varchar,integer)
returns integer as '
declare
        p_attribute_id   alias for $1;
        p_attribute      alias for $2;
        p_widget_id      alias for $3;
        p_depreciated_p  alias for $4;
        p_creation_date  alias for $5;
        p_creation_user  alias for $6; 
        p_creation_ip    alias for $7;
        p_context_id     alias for $8; 
        v_attribute_id   integer;
begin
        v_attribute_id := acs_object__new (
                p_attribute_id,
                ''contact_attribute'',
                p_creation_date,
                p_creation_user,
                P_creation_ip,
                p_context_id
        );

        insert into contact_attributes
                (attribute_id,attribute,widget_id,depreciated_p)
        values
                (v_attribute_id,p_attribute,p_widget_id,p_depreciated_p);

        return v_attribute_id;
end;' language 'plpgsql';

create or replace function contact__attribute_name_save(integer,varchar,varchar,varchar)
returns integer as '
declare
        p_attribute_id   alias for $1;
        p_locale         alias for $2;
        p_name           alias for $3;
        p_help_text      alias for $4;
begin

        delete from contact_attribute_names where attribute_id = p_attribute_id and locale = p_locale;

        insert into contact_attribute_names
                (attribute_id,locale,name,help_text)
        values
                (p_attribute_id,p_locale,p_name,p_help_text);

        return ''1'';
end;' language 'plpgsql';










create or replace function contact__attribute_object_map_save(integer,integer,integer,boolean,varchar)
returns integer as '
declare
        p_object_id      alias for $1;
        p_attribute_id   alias for $2;
        p_sort_order     alias for $3;
        p_required_p     alias for $4;
        p_heading        alias for $5;
begin

        delete from contact_attribute_object_map where attribute_id = p_attribute_id and object_id = p_object_id;

        insert into contact_attribute_object_map
                (object_id,attribute_id,sort_order,required_p,heading)
        values
                (p_object_id,p_attribute_id,p_sort_order,p_required_p,p_heading);

        return ''1'';
end;' language 'plpgsql';





create or replace function contact__attribute_name (integer)
returns varchar as '
declare
        p_attribute_id  alias for $1;
        v_name        varchar;
begin
        v_name := attribute from contact_attributes where attribute_id = p_attribute_id;         
        return v_name;
end;' language 'plpgsql';

create or replace function contact__attribute_delete (integer)
returns integer as '
declare
        p_attribute_id  alias for $1;
begin
        update contact_attributes set deleted_p = ''t'' where attribute_id = p_attribute_id;
        return 0;
end;' language 'plpgsql';

--         raise NOTICE ''v_count: %'', v_count;


create or replace function contact__attribute_value_save (integer,integer,integer,integer,integer,timestamptz,text,boolean,timestamptz,integer,varchar)
returns integer as '
declare
        p_party_id      alias for $1;
        p_attribute_id    alias for $2;
        p_option_map_id   alias for $3;
        p_address_id      alias for $4;
        p_number_id       alias for $5;
        p_time            alias for $6;
        p_value           alias for $7;
        p_deleted_p       alias for $8;
        p_creation_date   alias for $9;
        p_creation_user   alias for $10;
        p_creation_ip     alias for $11;
        v_count           integer;
        v_option_map_id   integer;
        v_address_id      integer;
        v_number_id       integer;
        v_time            timestamptz;
        v_value           text;
        v_edit_p          boolean;
begin

        v_count := count(*) from contact_attribute_values where party_id = p_party_id and attribute_id = p_attribute_id and not deleted_p;

        if v_count = ''0'' then

                if p_option_map_id is not null
                   or p_address_id is not null
                   or p_number_id is not null
                   or p_time is not null
                   or p_value is not null
                then

                        insert into contact_attribute_values
                        (party_id,attribute_id,option_map_id,address_id,number_id,time,value,deleted_p,creation_date,creation_user,creation_ip)
                        values
                        (p_party_id,p_attribute_id,p_option_map_id,p_address_id,p_number_id,p_time,p_value,p_deleted_p,p_creation_date,p_creation_user,p_creation_ip);
                end if;

        else


         select option_map_id,
                address_id,
                number_id,
                time, 
                value
           into v_option_map_id,
                v_address_id,
                v_number_id,
                v_time,
                v_value
           from contact_attribute_values
          where party_id = p_party_id
            and attribute_id = p_attribute_id
            and not deleted_p;

                if p_option_map_id is null
                   and p_address_id is null
                   and p_number_id is null
                   and p_time is null
                   and p_value is null
                then

                   update contact_attribute_values set deleted_p = ''t'' where attribute_id = p_attribute_id and party_id = p_party_id;


                end if;

           
        
           if v_option_map_id != p_option_map_id
              or v_address_id != p_address_id
              or v_number_id != p_number_id
              or v_time != p_time
              or v_value != p_value
           then

              update contact_attribute_values set deleted_p = ''t'' where attribute_id = p_attribute_id and party_id = p_party_id;

              if p_option_map_id is not null
                 or p_address_id is not null
                 or p_number_id is not null
                 or p_time is not null
                 or p_value is not null
              then
                 insert into contact_attribute_values
                 (party_id,attribute_id,option_map_id,address_id,number_id,time,value,deleted_p,creation_date,creation_user,creation_ip)
                 values
                 (p_party_id,p_attribute_id,p_option_map_id,p_address_id,p_number_id,p_time,p_value,p_deleted_p,p_creation_date,p_creation_user,p_creation_ip);
              end if;

           end if;

        end if;




        return 0;
end;' language 'plpgsql';









create or replace function contact__attribute_option_create (integer,varchar,integer)
returns integer as '
declare
        p_attribute_id          alias for $1;
        p_option                alias for $2;
        p_sort_order            alias for $3;
        v_option_id             integer;
begin

        select nextval(''contact_attribute_options_id_seq'')
          into v_option_id;

        insert into contact_attribute_options
        (option_id,attribute_id,option,sort_order)
        values
        (v_option_id,p_attribute_id,p_option,p_sort_order);

return v_option_id;
end;' language 'plpgsql';

create or replace function contact__attribute_option_delete (integer)
returns integer as '
declare
        p_option_id             alias for $1;
begin
        update contact_attribute_options set deleted_p = ''t'' where option_id = p_option_id;
return 0;
end;' language 'plpgsql';


