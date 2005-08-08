-- contacts-drop.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28
-- @cvs-id $Id$
--
--

drop table contact_search_conditions;
drop table contact_searches;
select drop_package('contact_search');
select acs_object__delete(search_id) from contact_searches;
select acs_object_type__drop_type('contact_search','t');

drop view contact_rel_types;
drop table contact_signatures;
drop table contact_groups;
drop table contact_rels;
drop table organization_rels;
drop table contact_complaint_tracking;

select content_type__drop_type ('contact_party_revision','t','t');
--drop table contact_party_revisions;
select acs_rel_type__drop_type('organization_rel','t');
select acs_rel_type__drop_type(object_type,'t') from acs_object_types where supertype = 'contact_rel';
select acs_rel_type__drop_type('contact_rel','t');

-- procedure drop_type
select drop_package('contact');
select drop_package('contact_rel');
select drop_package('contact_party_revision');
