-- contacts-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28

create table contact_archives (
        party_id        integer
                        constraint contact_archives_party_id_fk references parties(party_id)
                        constraint contact_archives_party_id_pk primary key     
);

-- this is used to create forms for orgs and persons (since they need object_ids) to map to.
create table contact_object_types (
        object_id               integer not null
                                constraint contact_object_type_object_id_fk references acs_objects(object_id)
                                constraint contact_object_type_object_id_pk primary key,
        object_type             varchar(100) not null,
        UNIQUE(object_type)
);




\i contacts-package-create.sql



create view contacts as
  select organization_id as party_id,
         'organization' as object_type,
         name,
         name as organization_name,
         legal_name,
         reg_number,
         null as first_names,
         null as last_name,
         name as sort_first_names,
         name as sort_last_name,
         contact__party_email(organization_id) as email,
         contact__party_url(organization_id) as url,
         'f' as user_p,
         contact__status(organization_id) as status
    from organizations
union
  select person_id as party_id,
         'person' as object_type,
         first_names || ' ' || last_name as name,
         null as organization_name,
         null as legal_name,
         null as reg_number,
         first_names as first_names,
         last_name as last_name,
         first_names || ' ' || last_name as sort_first_names,
         last_name || ', ' || first_names as sort_last_name,
         contact__party_email(person_id) as email,
         contact__party_url(person_id) as url,
         contact__person_is_user_p(person_id) as user_p,
         contact__status(person_id) as status
    from persons
   where person_id != '0'
;


-- The attribute structure.
\i attributes-create.sql
\i attributes-package-create.sql

\i attributes-populate.sql

\i views-create.sql

\i telecom-number-missing-plsql.sql
