-- 
-- packages/contacts/sql/postgresql/upgrade/upgrade-1.2b26-1.2b27.sql
-- 
-- @author <yourname> (<your email>)
-- @creation-date 2007-01-23
-- @cvs-id $Id$
--

update acs_attributes set attribute_name = 'home_address' where attribute_name = 'visitaddress';
