-- contacts/sql/postgresql/contacts-messages-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2005-06-29
-- @cvs-id $Id$
--
--

create table contact_message_types (
	message_type             varchar(20)
                                 constraint contact_message_types_pk primary key,
        pretty_name              varchar(100)
                                 constraint contact_message_types_pretty_name_nn not null
);
insert into contact_message_types (message_type,pretty_name) values ('email','#contacts.Email#');
insert into contact_message_types (message_type,pretty_name) values ('letter','#contacts.Letter#');


create table contact_message_items (
	item_id                 integer
                                constraint contact_message_items_id_fk references cr_items(item_id)
                                constraint contact_message_items_id_pk primary key,
        owner_id                integer
                                constraint contact_message_items_owner_id_fk references acs_objects(object_id) on delete cascade
                                constraint contact_message_items_owner_id_nn not null,
        message_type            varchar(20)
                                constraint contact_message_items_message_type_fk references contact_message_types(message_type)
                                constraint contact_message_items_message_type_nn not null
);

create view contact_messages as 
    select cmi.item_id, 
           cmi.owner_id,
           cmi.message_type,
           cr.title,
           cr.description,
           cr.content,
           cr.mime_type as content_format
      from contact_message_items cmi, cr_items ci, cr_revisions cr
     where cmi.item_id = cr.item_id
       and ci.publish_status not in ( 'expired' )
       and ci.live_revision = cr.revision_id
;


create table contact_message_log (
        message_id              integer
                                constraint contact_message_log_message_id_pk primary key,
        message_type            varchar(20)
                                constraint contact_message_log_message_type_fk references contact_message_types(message_type)
                                constraint contact_message_log_message_type_nn not null,
        sender_id               integer
                                constraint contact_message_sender_id_fk references users(user_id)
                                constraint contact_message_sender_id_nn not null,
        recipient_id            integer
                                constraint contact_message_recipient_id_fk references parties(party_id)
                                constraint contact_message_recipient_id_nn not null,
        sent_date               timestamptz
                                constraint contact_message_sent_date_nn not null,
        title                   varchar(1000),
        content                 text
                                constraint contact_message_log_content_nn not null,
        content_format          varchar(200)
                                constraint contact_message_log_content_format_fk references cr_mime_types(mime_type)
                                constraint contact_message_log_content_format_nn not null
);

