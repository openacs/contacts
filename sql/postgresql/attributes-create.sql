-- attributes-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28

create table contact_storage_types (
        storage_column    varchar(20)
                          constraint contact_storage_type_nn not null
                          constraint contact_storage_type_pk primary key
);

create sequence contact_widget_id_seq;
create table contact_widgets (
        widget_id               integer not null
                                constraint contact_widgets_attr_name_pk primary key,
        storage_column          varchar(20)
                                constraint contact_widgets_storage_type_fk references contact_storage_types(storage_column),
        description             varchar(1000) not null,
        widget	                varchar(20) not null,
        datatype                varchar(20) not null,
        help_p                  boolean default 'f',
        html                    varchar(255),
        format                  varchar(100),
        multiple_p              boolean default 'f',
        nospell_p               boolean default 'f'
);

-- there is the table to store contact_attributes, since import/exports and the like require
-- certain fields that are statically mapped by the tcl api we don't actually delete any 
-- attributes, we simple mark them deleted_p = 't'.

create table contact_attributes (
        attribute_id            integer not null
                                constraint contact_attributes_attribute_id_fk references acs_objects(object_id)
                                constraint contact_attributes_attribute_id_pk primary key,
        attribute               varchar(100) not null,
        widget_id               integer not null                        
                                constraint contact_attributes_widget_id_fk references contact_widgets (widget_id),
        depreciated_p           boolean default 'f' not null
);


-- create index contact_attributes_id on contact_attributes(attribute_id);

create table contact_attribute_names (
        attribute_id            integer not null
                                constraint contact_attribute_names_attribute_id_fk references contact_attributes(attribute_id),
        locale                  varchar(5) not null
                                constraint contact_attribute_names_locale_fk references ad_locales(locale),
        name                    varchar(100) not null,
        help_text               varchar(1000),
        UNIQUE(attribute_id,locale)
);

create table contact_attribute_object_map (
        object_id               integer not null
                                constraint contact_attribute_object_map_object_id_fk references acs_objects(object_id),
        attribute_id            integer not null
                                constraint contact_attribute_object_map_attribute_id_fk references contact_attributes(attribute_id),
        sort_order              integer not null,
        required_p              boolean default'f' not null,
        heading                 varchar(1000),
        UNIQUE(object_id,attribute_id)
);



create sequence contact_attribute_options_id_seq;

create table contact_attribute_options (
        attribute_id    integer 
                        constraint contact_choice_types_attr_id_nn not null 
                        constraint contact_choice_types_attr_id_fk references contact_attributes (attribute_id),
        option_id       integer
                        constraint contact_choice_types_id_nn not null
                        constraint contact_choice_types_id_nn primary key,
        option          varchar(1000)
                        constraint contact_choice_types_choice_nn not null,
        sort_order      integer
);

create sequence contact_attribute_option_map_id_seq;

create table contact_attribute_option_map_ids (
        option_map_id   integer
                        constraint contact_attribute_option_map_ids_option_map_id_pk primary key
);


create table contact_attribute_option_map (
        option_map_id   integer
                        constraint contact_attribute_option_map_option_map_id_nn not null,
        party_id        integer
                        constraint contact_attribute_option_map_party_id_fk references parties(party_id),
        option_id       integer
                        constraint contact_attribute_option_map_option_id_fk references contact_attribute_options(option_id)
);

CREATE or REPLACE FUNCTION contact__option_map_id_trigger_proc () RETURNS TRIGGER AS '
BEGIN
        delete from contact_attribute_option_map_ids where option_map_id = NEW.option_map_id;
        insert into contact_attribute_option_map_ids (option_map_id) values (NEW.option_map_id);
        RETURN NEW;
END;
' LANGUAGE 'plpgsql';
create trigger contact__option_map_id_trigger before insert or update on contact_attribute_option_map
   for each row execute procedure contact__option_map_id_trigger_proc();


-- create index contact_attr_choice_attr_id on contact_attribute_choices(attribute_id);
-- create index contact_attr_sort_order on contact_attribute_choices(sort_order);

create table contact_attribute_values (
        party_id                integer not null
                                constraint contact_attribute_values_party_id_fk references parties(party_id),
        attribute_id            integer not null
                                constraint contact_attribute_values_attribute_id_fk references contact_attributes(attribute_id),
        option_map_id           integer
                                constraint contact_attribute_values_option_id_fk references contact_attribute_option_map_ids(option_map_id),
        address_id              integer
                                constraint contact_attribute_values_address_id_fk references postal_addresses(address_id),
        number_id               integer
                                constraint contact_attribute_values_number_id_fk references telecom_numbers(number_id),
        time                    timestamptz,
        value                   text,
        value_format            character varying(50),
        deleted_p               boolean not null
                                default 'f',
        creation_date           timestamptz default now(),
        creation_user           integer not null
                                constraint contact_attribute_values_creation_user references users(user_id),
        creation_ip             varchar
);

-- create index contact_attribute_values_index on contact_attribute_values (party_id, attribute_id);
