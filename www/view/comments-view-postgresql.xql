<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>



<fullquery name="">
  <querytext>
         select g.comment_id,
                r.mime_type,
                o.creation_user,
                acs_object__name(o.creation_user) as author,
                to_char(o.creation_date, 'MM-DD-YYYY') as pretty_date,
                to_char(o.creation_date, 'YYYY-MM-DD HH24:MI') as pretty_timestamp,
                r.content
           from general_comments g,
                cr_revisions r,
                acs_objects o
          where g.object_id = :party_id and
                r.revision_id = content_item__get_live_revision(g.comment_id) and
                o.object_id = g.comment_id
                and o.context_id = :package_id
          [template::list::orderby_clause -orderby -name comments]
  </querytext>
</fullquery>


</queryset>
