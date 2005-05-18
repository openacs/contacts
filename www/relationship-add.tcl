ad_page_contract {
    List and manage contacts.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {party_one:integer,notnull}
    {role_one:optional}
    {party_two:integer,notnull}
    {role_two:notnull}
    {rel_type:optional}
    {comment ""}
    {comment_format "text/plain"}
    {return_url ""}
} -validate {
    contact_one_exists -requires {party_one} {
	if { ![contact::exists_p -party_id $party_one] } {
	    ad_complain "The first contact specified does not exist"
	}
    }
    contact_two_exists -requires {party_two} {
	if { ![contact::exists_p -party_id $party_two] } {
	    ad_complain "The second contact specified does not exist"
	}
    }
    role_one_exists -requires {role_one} {
	if { ![db_0or1row role_exists {select 1 from contact_rel_types where primary_role = :role_one}] } {
	    ad_complain "The first role specified does not exist"
	}
    }
    role_two_exists -requires {role_two} {
	if { ![db_0or1row role_exists {select 1 from contact_rel_types where primary_role = :role_two}] } {
	    ad_complain "The second role specified does not exist"
	}
    }
}

set party_id $party_one
set contact_name_one [contact::name -party_id $party_id]
set contact_name_two [contact::name -party_id $party_two]
set contact_type_one [contact::type -party_id $party_id]
set contact_type_two [contact::type -party_id $party_two]
set secondary_role_pretty [db_string getit { select acs_rel_type__role_pretty_name(:role_two) as secondary_role_pretty }]
if { ![exists_and_not_null rel_type] } {
    set options_list [db_list_of_lists get_rel_type {
        select rel_type,
               primary_role,
               acs_rel_type__role_pretty_name(primary_role) as primary_role_pretty
          from contact_rel_types
         where secondary_role = :role_two
           and secondary_object_type in (:contact_type_two,'party')
           and primary_object_type in (:contact_type_one,'party')
    }]
    set options_length [llength $options_list]
    if { $options_length == "0" } {
        ad_return_error "Error" "There was a problem with your input. this type of relationship cannot exist."
    } elseif { $options_length == "1" } {
        set rel_type [lindex [lindex $options_list 0] 0]
        set role_one [lindex [lindex $options_list 0] 1]
    } else {
        multirow create rel_types rel_type primary_role_pretty url
        foreach rel $options_list {
            set temp_rel_type [lindex $rel 0]
            set temp_role_one [lindex $rel 1]
            set temp_role_pretty [lindex $rel 2]
            multirow append rel_types $temp_rel_type $temp_role_pretty [export_vars -base "relationship-add" -url {party_one party_two role_two {role_one $temp_role_one} {rel_type $temp_rel_type}}]
        }
    }
}




if { [exists_and_not_null rel_type] } {

    db_1row get_roles {
    select role_one as db_role_one,
           role_two as db_role_two
      from acs_rel_types
     where rel_type = :rel_type
    }

    if { $db_role_one == $role_one } {
        set object_id_one $party_one
        set object_id_two $party_two
    } else {
        set object_id_one $party_two
        set object_id_two $party_one
    }
    set existing_rel_id [db_string rel_exists { 
        select rel_id
        from   acs_rels 
        where  rel_type = :rel_type 
        and    object_id_one = :object_id_one
        and    object_id_two = :object_id_two
    } -default {}]
    
    if { [empty_string_p $existing_rel_id] } {
	set rel_id {}
	set context_id {}
	set creation_user [ad_conn user_id]
	set creation_ip [ad_conn peeraddr]
	set rel_id [db_exec_plsql create_rel {
	    select acs_rel__new (
				 :rel_id,
				 :rel_type,
				 :object_id_one,
				 :object_id_two,
				 :context_id,
				 :creation_user,
				 :creation_ip  
			)
	}]
        db_dml insert_rel {
            insert into contact_rels
                   (rel_id,comment,comment_format)
            values 
                   (:rel_id,:comment,:comment_format)
        }
    }
    if { ![exists_and_not_null return_url] } {
        set return_url [export_vars -base "contact-rels" -url {{party_id $party_one}}]
        ad_returnredirect -message "Relationship Added" $return_url
    }
    ad_script_abort
}

