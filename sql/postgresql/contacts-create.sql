-- contacts-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28
-- @cvs-id $Id$
--
--


-- all contacts are parties. we are making parties content repository items,
-- so we need party revisions

create table contact_party_revisions (
        party_revision_id       integer
                                constraint contact_party_revisions_id_fk references cr_revisions(revision_id)
                                constraint contact_party_revisions_id_pk primary key
);

-- create the content type
select content_type__create_type (
   'contact_party_revision',      -- content_type
   'content_revision',            -- supertype    
   '#contacts.Party_Revision#',   -- pretty_name 
   '#contacts.Party_Revisions#',  -- pretty_plural
   'contact_party_revisions',     -- table_name
   'party_revision_id',           -- id_column 
   'contact_party_revision__name' -- name_method
);

-- i need to create the content_folder contact_parties, it is not bound to a package_id
-- since the package_id is not used by contacts - which uses the groups system for package
-- maintenance.


-- contrary to "most" packages that use the content repository, we will not be 
-- specifying new item_ids. Since all contacts are parties, we are going to set
-- all parties that use the contacts system to have an content_items(item_id)
-- that is equal to the parties(party_id).



-- since all contacts are parties we already have good "group" mechanisms built into the core
-- however, we do not want people to view all groups at once, so the calendar instance
-- administrator can selectively give certain calendar instances access to certain groups
-- 
-- by default each new contacts instance will be given access to its subsite's group. For
-- example: all users on a default openacs install are memembers of the "Main Site Members"
-- group. If a calendar instance were mounted under that subsite, all "Main Site Members"
-- would be accessible to that calendar instance.
--
-- just as is the case with the calendar package all "users" of contacts (i.e. users that
-- have write access to at least one contacts instance will be assigned a private calendar)
--
-- which calendars can be viewed by which calendar instance is handled via parameters - unlike
-- many packages. This allows for more flexable instance and sharing management - where
-- one instances shared calendar can also be accesible to another instance.

create table contact_groups (
        group_id                integer
                                constraint contact_groups_id_fk references groups(group_id)
                                constraint contact_groups_id_nn not null,
        default_p               boolean default 'f'
                                constraint contact_groups_default_p_nn not null,
        package_id              integer
                                constraint contact_groups_package_id_fk references apm_packages(package_id)
                                constraint contact_groups_package_id_nn not null,
        unique(group_id,package_id)
);

create table contact_groups_allowed_rels (
        group_id                integer
                                constraint contact_groups_id_fk references groups(group_id)
                                constraint contact_groups_id_nn not null,
        rel_type                varchar(100)
                                constraint contact_groups_allowed_rels_type_fk references acs_rel_types(rel_type),
        package_id              integer
                                constraint contact_groups_package_id_fk references apm_packages(package_id)
                                constraint contact_groups_package_id_nn not null,
        unique(group_id,package_id)
);


create table contact_signatures (
        signature_id            integer
                                constraint contact_signatures_id_pk primary key,
        title                   varchar(255)
                                constraint contact_signatures_title_nn not null,
        signature               varchar(1000)
                                constraint contact_signatures_signature_nn not null,
        default_p               boolean default 'f'
                                constraint contact_signatures_default_p_nn not null,
        party_id                integer
                                constraint contact_signatures_party_id_fk references parties(party_id)
                                constraint contact_signatures_party_id_nn not null,
        unique(party_id,title,signature)
);

-- this view greatly simplifies getting available roles for various contact types
create view contact_rel_types as 
(    select rel_type,
            object_type_one as primary_object_type,
            role_one as primary_role,
            object_type_two as secondary_object_type,
            role_two as secondary_role
       from acs_rel_types
      where rel_type in ( select object_type from acs_object_types where supertype = 'contact_rel')
)
UNION
(    select rel_type,
            object_type_two as primary_object_type,
            role_two as primary_role,
            object_type_one as secondary_object_type,
            role_one as secondary_role
       from acs_rel_types
      where rel_type in ( select object_type from acs_object_types where supertype = 'contact_rel')
)
;

create table contact_rels (
        rel_id           integer
                         constraint contact_rels_rel_id_fk references acs_rels(rel_id) on delete cascade
                         constraint contact_rels_rel_id_pk primary key
);

create table organization_rels (
        rel_id           integer
                         constraint organization_rels_rel_id_fk references membership_rels(rel_id) on delete cascade
                         constraint organization_rels_rel_id_pk primary key
);


\i contacts-package-create.sql
\i contacts-search-create.sql
\i contacts-messages-create.sql


