-- views-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28
-- @cvs-id $Id$
--
--

create table contact_views (
        view_id                 integer
                                constraint contact_views_view_id_fk references acs_objects(object_id)
                                constraint contact_views_view_id_pk primary key,
        src                     varchar(255)
                                constraint contact_views_src_nn not null,
        privilege_required      varchar(100)
                                constraint contact_views_privilege_required_fk references acs_privileges(privilege)
                                constraint contact_views_privilege_required_nn not null,
        privilege_object_id     integer
                                constraint contact_views_privilege_object_id_fk references acs_objects(object_id)
                                constraint contact_views_privilege_object_id_nn not null,
        contact_object_type     varchar(100)
                                constraint contact_views_object_type_id_fk references contact_object_types(object_type)
                                constraint contact_views_object_type_id_nn not null, 
        package_id              integer
                                constraint contact_views_package_id_fk references apm_packages(package_id)
                                constraint contact_views_package_id_nn not null,
        sort_order              integer not null
);




create table contact_view_names (
        view_id                 integer not null
                                constraint contact_attribute_names_view_id_fk references contact_views(view_id),
        locale                  varchar(5) not null
                                constraint contact_attribute_names_locale_fk references ad_locales(locale),
        name                    varchar(100) not null,
        UNIQUE(view_id,locale)
);


create function inline_1 ()
returns integer as '
begin

    PERFORM acs_object_type__create_type (
	''contact_view'',       -- object_type
 	''Contacct View'',	-- pretty_name
	''Contact Views'',	-- pretty_plural
	''acs_object'',		-- supertype
	''contact_views'',	-- table_name
	''view_id'',            -- id_column
	null,			-- package_name
	''f'',			-- abstract_p
	null,			-- type_extension_table
	null			-- name_method
	);

  return 0;

end;' language 'plpgsql';

select inline_1 ();
drop function inline_1 ();


create or replace function contact__view_create (integer,varchar,varchar,integer,varchar,integer,integer,timestamptz,integer,varchar,integer)
returns integer as '
declare
        p_view_id               alias for $1;
        p_src                   alias for $2;
        p_privilege_required    alias for $3;
        p_privilege_object_id   alias for $4;
        p_contact_object_type   alias for $5;
        p_package_id            alias for $6;
        p_sort_order            alias for $7;
        p_creation_date         alias for $8;
        p_creation_user         alias for $9; 
        p_creation_ip           alias for $10;
        p_context_id            alias for $11; 
        v_view_id          integer;
begin
        v_view_id := acs_object__new (
                p_view_id,
                ''contact_view'',
                p_creation_date,
                p_creation_user,
                P_creation_ip,
                p_context_id
        );

        insert into contact_views
                (view_id,src,privilege_required,privilege_object_id,contact_object_type,package_id,sort_order)
        values
                (v_view_id,p_src,p_privilege_required,p_privilege_object_id,p_contact_object_type,p_package_id,p_sort_order);

        return v_view_id;
end;' language 'plpgsql';

create or replace function contact__view_delete (integer)
returns integer as '
declare
        p_view_id               alias for $1;
begin
        delete from contact_view_names where view_id = p_view_id;
        delete from contact_views where view_id = p_view_id;
        delete from acs_objects where object_id = view_id;

        return ''1'';
end;' language 'plpgsql';

create or replace function contact__view_name_save(integer,varchar,varchar)
returns integer as '
declare
        p_view_id   alias for $1;
        p_locale         alias for $2;
        p_name           alias for $3;
begin

        delete from contact_view_names where view_id = p_view_id and locale = p_locale;

        insert into contact_view_names
                (view_id,locale,name)
        values
                (p_view_id,p_locale,p_name);

        return ''1'';
end;' language 'plpgsql';



