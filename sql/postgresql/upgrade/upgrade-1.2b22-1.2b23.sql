alter table user_preferences drop constraint user_prefs_user_id_fk;
alter table user_preferences add constraint user_prefs_user_id_fk foreign key  (user_id) references parties (party_id);