-- contacts-search-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28
-- @cvs-id $Id$
--
--

create table contact_searches (
        search_id               integer
                                constraint contact_searches_id_fk references acs_objects(object_id) on delete cascade
                                constraint contact_searches_id_pk primary key,
        title                   varchar(255),
        owner_id                integer
                                constraint contact_searches_owner_id_fk references acs_objects(object_id) on delete cascade
                                constraint contact_searches_owner_id_nn not null,
        all_or_any              varchar(20)
                                constraint contact_searches_and_or_all_nn not null,
        object_type             varchar(1000)
                                constraint contact_searches_object_type_nn not null
);

-- create the content type
select acs_object_type__create_type (
   'contact_search',              -- content_type
   'Contacts Search',             -- pretty_name 
   'Contacts Searches',           -- pretty_plural
   'acs_object',                  -- supertype
   'contact_searches',            -- table_name (should this be pm_task?)
   'search_id',                   -- id_column 
   'contact_search',              -- package_name
   'f',                           -- abstract_p
   NULL,                          -- type_extension_table
   NULL                           -- name_method
);

create table contact_search_conditions (
   condition_id                   integer
                                  constraint contact_search_conditions_id_pk primary key,
   search_id                      integer
                                  constraint contact_search_conditions_search_id_fk references contact_searches(search_id) on delete cascade
                                  constraint contact_search_conditions_search_id_nn not null,
   type                           varchar(255)
                                  constraint contact_search_conditions_type_nn not null,
   var_list                       text
                                  constraint contact_search_conditions_var_list_nn not null
);


select define_function_args ('contact_search__new', 'search_id,title,owner_id,all_or_any,object_type,creation_date,creation_user,creation_ip,context_id');

create or replace function contact_search__new (integer,varchar,integer,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
    p_search_id                     alias for $1;
    p_title                         alias for $2;
    p_owner_id                      alias for $3;
    p_all_or_any                    alias for $4;
    p_object_type                   alias for $5;
    p_creation_date                 alias for $6;
    p_creation_user                 alias for $7;
    p_creation_ip                   alias for $8;
    p_context_id                    alias for $9;
    v_search_id                     contact_searches.search_id%TYPE;
begin
    v_search_id := acs_object__new(
        p_search_id,
        ''contact_search'',
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        coalesce(p_context_id, p_owner_id)
    );

    insert into contact_searches
    (search_id,title,owner_id,all_or_any,object_type)
    values
    (p_search_id,p_title,p_owner_id,p_all_or_any,p_object_type);

    return v_search_id;

end;' language 'plpgsql';

