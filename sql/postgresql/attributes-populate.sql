-- attributes-populate.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-07-28
-- @cvs-id $Id$
--
--


-- now we populate the database with standard info

create function inline_1 ()
returns integer as '
declare
        v_attribute_id            integer;
        v_package_id              integer;
        v_organization_object_id  integer;
        v_person_object_id        integer;
        v_widget_id               integer;
begin

v_package_id := package_id from apm_packages where package_key = ''contacts'';

v_organization_object_id := contact__object_type_create(null,''organization'',null,null,null,null);
v_person_object_id := contact__object_type_create(null,''person'',null,null,null,null);

insert into contact_storage_types ( storage_column ) values ( ''number_id'' );
insert into contact_storage_types ( storage_column ) values ( ''address_id'' );
insert into contact_storage_types ( storage_column ) values ( ''option_map_id'' );
insert into contact_storage_types ( storage_column ) values ( ''time'' );
insert into contact_storage_types ( storage_column ) values ( ''value'' );





v_widget_id := contact__widget_create (''address_id'',''Address'',''address'',''address'',null,null,null,null,null);
                  v_attribute_id := contact__attribute_create (null,
''home_address'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Home Address'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''140'',''f'',
''Personal Information'');

                  v_attribute_id := contact__attribute_create (null,
''organization_address'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Organization Address'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''210'',''f'',null);
                  PERFORM contact__attribute_object_map_save(
v_organization_object_id,v_attribute_id,
''50'',''f'',null);















v_widget_id := contact__widget_create (''number_id'',''Phone Number'',''text'',''text'',null,''size 12 maxlength 50'',null,null,null);

                  v_attribute_id := contact__attribute_create (null,
''home_phone'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Home Phone'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''80'',''f'',
''Phone Numbers'');

                  v_attribute_id := contact__attribute_create (null,
''home_fax'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Home Fax'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''90'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''personal_mobile_phone'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Personal Mobile Phone'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''100'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''work_phone'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Work Phone'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''110'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''work_fax'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Work Fax'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''120'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''work_mobile_phone'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Work Mobile Phone'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''130'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''organization_switchboard'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Organization Switchboard'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''220'',''f'',null);
                  PERFORM contact__attribute_object_map_save(
v_organization_object_id,v_attribute_id,
''60'',''f'',null);


                  v_attribute_id := contact__attribute_create (null,
''assistants_phone'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Assistant''''s Phone'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''260'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''managers_phone'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Manager''''s Phone'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''240'',''f'',null);









v_widget_id := contact__widget_create (''time'',''Date - MONTH DD, YYYY'',''date'',''date'',''t'',null,''MONTH DD, YYYY'',null,null);
                  v_attribute_id := contact__attribute_create (null,
''birthday'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Birthday'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''150'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''anniversary'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Anniversary'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''180'',''f'',null);






v_widget_id := contact__widget_create (''option_map_id'',''Choice - radio'',''radio'',''integer'',null,null,null,null,null);
                  v_attribute_id := contact__attribute_create (null,
''gender'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Gender'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''160'',''f'',null);
PERFORM contact__attribute_option_create(v_attribute_id,''Male'',''1'');
PERFORM contact__attribute_option_create(v_attribute_id,''Female'',''2'');


v_widget_id := contact__widget_create (''option_map_id'',''Choice - select'',''select'',''integer'',null,null,null,null,null);
v_widget_id := contact__widget_create (''option_map_id'',''Choice - checkbox'',''checkbox'',''integer'',null,null,null,''t'',null);
                  v_attribute_id := contact__attribute_create (null,
''organization_type'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Organization Type'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_organization_object_id,v_attribute_id,
''80'',''f'',null);
PERFORM contact__attribute_option_create(v_attribute_id,''Customer'',''1'');
PERFORM contact__attribute_option_create(v_attribute_id,''Other'',''2'');
PERFORM contact__attribute_option_create(v_attribute_id,''Prospect'',''3'');
PERFORM contact__attribute_option_create(v_attribute_id,''Vendor'',''4'');














v_widget_id := contact__widget_create (''value'',''Number - numeric small (i.e. decimals are okay)'',''text'',''numeric'',null,''size 3'',null,null,null);
v_widget_id := contact__widget_create (''value'',''Number - numeric large (i.e. decimals are okay)'',''text'',''numeric'',null,''size 10'',null,null,null);
v_widget_id := contact__widget_create (''value'',''Number - integer small'',''text'',''integer'',null,''size 3'',null,null,null);
v_widget_id := contact__widget_create (''value'',''Number - integer large'',''text'',''integer'',null,''size 10'',null,null,null);
v_widget_id := contact__widget_create (''value'',''Textbox - tiny'',''text'',''text'',null,''size 3'',null,null,null);
v_widget_id := contact__widget_create (''value'',''Textbox - small'',''text'',''text'',null,''size 20'',null,null,null);
v_widget_id := contact__widget_create (''value'',''Textbox - medium'',''text'',''text'',null,''size 35'',null,null,null);

                  v_attribute_id := contact__attribute_create (null,
''first_names'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''First Name(s)'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''10'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''middle_names'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Middle Name(s)'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''20'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''last_name'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Last Name'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''30'',''f'',null);




                  v_attribute_id := contact__attribute_create (null,
''spouse'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Spouse'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''170'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''organization_name'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Organization'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''200'',''f'',''Work Information'');
                  PERFORM contact__attribute_object_map_save(
v_organization_object_id,v_attribute_id,
''10'',''f'',null);




                  v_attribute_id := contact__attribute_create (null,
''legal_name'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Legal Name'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_organization_object_id,v_attribute_id,
''20'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''reg_number'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Registration number (ein/ssn/vat/etc)'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_organization_object_id,v_attribute_id,
''70'',''f'',null);

                  v_attribute_id := contact__attribute_create (null,
''managers_name'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Manager''''s Name'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''230'',''f'',null);
                  v_attribute_id := contact__attribute_create (null,
''assistants_name'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Assistant''''s Name'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''250'',''f'',null);








v_widget_id := contact__widget_create (''value'',''Email Address'',''text'',''email'',null,''size 35'',null,null,null);
                  v_attribute_id := contact__attribute_create (null,
''email'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Email Address'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''40'',''f'',null);
                  PERFORM contact__attribute_object_map_save(
v_organization_object_id,v_attribute_id,
''30'',''f'',null);















v_widget_id := contact__widget_create (''value'',''Website'',''text'',''url'',null,''size 35'',null,null,null);
                  v_attribute_id := contact__attribute_create (null,
''url'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Website'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''70'',''f'',null);
                  PERFORM contact__attribute_object_map_save(
v_organization_object_id,v_attribute_id,
''40'',''f'',null);









v_widget_id := contact__widget_create (''value'',''Textbox - large'',''text'',''text'',null,''size 55'',null,null,null);
                  v_attribute_id := contact__attribute_create (null,
''children'',
                  v_widget_id,''f'',now(),null,null,v_package_id);
                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
''Children'',
                  null
                  );
                  PERFORM contact__attribute_object_map_save(
v_person_object_id,v_attribute_id,
''190'',''f'',null);




v_widget_id := contact__widget_create (''value'',''Textarea - short and small'',''textarea'',''text'',null,''cols 40 rows 2 wrap virtual'',null,null,null);
v_widget_id := contact__widget_create (''value'',''Textarea - medium'',''textarea'',''text'',null,''cols 45 rows 6 wrap virtual'',null,null,null);
v_widget_id := contact__widget_create (''value'',''Textarea - large'',''textarea'',''text'',null,''cols 55 rows 12 wrap virtual'',null,null,null);
v_widget_id := contact__widget_create (''value'',''Textarea - No Spellcheck - short and small'',''textarea'',''text'',null,''cols 40 rows 2 wrap virtual'',null,null,''t'');
v_widget_id := contact__widget_create (''value'',''Textarea - No Spellcheck - medium'',''textarea'',''text'',null,''cols 45 rows 6 wrap virtual'',null,null,''t'');
v_widget_id := contact__widget_create (''value'',''Textarea - No Spellcheck - large'',''textarea'',''text'',null,''cols 55 rows 12 wrap virtual'',null,null,''t'');
v_widget_id := contact__widget_create (''value'',''Richtext - medium'',''richtext'',''richtext'',null,''cols 45 rows 6 wrap virtual'',null,null,null);
v_widget_id := contact__widget_create (''value'',''Richtext - large'',''richtext'',''richtext'',null,''cols 55 rows 12 wrap virtual'',null,null,null);



return 0;

end;' language 'plpgsql';

select inline_1 ();
drop function inline_1 ();

--                  v_attribute_id := contact__attribute_create (null,
--'''',
--                  v_widget_id,''f'',now(),null,null,v_package_id);
--                  PERFORM contact__attribute_name_save (v_attribute_id,''en_US'',
--'''',
--                  null
--                  );
--                  PERFORM contact__attribute_object_map_save(
--v_organization_object_id,v_attribute_id,
--'''',''f'',null);



