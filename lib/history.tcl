#    @author Matthew Geddert openacs@geddert.com
#    @creation-date 2005-07-09
#    @cvs-id $Id$

if { [string is false [contact::exists_p -party_id $party_id]] } {
    error "[_ contacts.lt_The_party_id_specifie]"
}

if { [string is false [exists_and_not_null recent_on_top_p]] } {
    set recent_on_top_p [parameter::get_from_package_key -boolean -package_key "general-comments" -parameter "RecentOnTopP"]
}

if { [string is false [exists_and_not_null recent_on_top_p]] } {
    error "[_ contacts.lt_The_parameter_RecentO]"
} else {
    if { $recent_on_top_p } {
        set orderby_clause "creation_date desc"
    } else {
        set orderby_clause "creation_date asc"
    }
}
if { [string is false [exists_and_not_null size]] } {
    set size "normal"
}
switch $size {
    normal  {
        set textarea_size "cols 50 rows 6"
    }
    small   {
        set textarea_size "cols 35 rows 3"
    }
    default { error "[_ contacts.lt_You_have_specified_an_1]" }
}

if { [string is false [exists_and_not_null form]] } {
    if { $recent_on_top_p } {
        set form "top"
    } else {
        set form "bottom"
    }
}
if { [lsearch [list top bottom none] $form] < 0 } {
    error "[_ contacts.lt_Invalid_input_you_spe]"
}






if { [exists_and_not_null limit] } {
    set limit_clause "limit $limit"
} else {
    set limit_clause ""
}




set project_id "26798"

set tasks [list]
db_foreach get_tasks {
    select pt.task_id,
           tasks__completion_date(ci.item_id) as completion_date,
           tasks__completion_user(ci.item_id) as completion_user,
           cr.title,
           cr.description as content
      from cr_items ci,
           pm_tasks_revisions ptr,
           pm_tasks pt left join pm_process_instance ppi on (pt.process_instance = ppi.instance_id ),
           cr_revisions cr,
           acs_objects ao
     where ci.parent_id = :project_id
       and ci.item_id = pt.task_id
       and ci.latest_revision = ptr.task_revision_id
       and ci.live_revision = ptr.task_revision_id
       and ptr.task_revision_id = cr.revision_id
       and cr.revision_id = ao.object_id
       and pt.status = '2'
       and pt.deleted_p = 'f'
       and task_id in ( select task_id from pm_task_assignment where party_id = :party_id and role_id = '1' )
} {
    if { [exists_and_not_null truncate_len] } {
        set content_html [ad_html_text_convert -truncate_len $truncate_len -from "text/plain" -to "text/html" $content]
    } else {
        set content_html [ad_html_text_convert -from "text/plain" -to "text/html" $content]
    }
    lappend tasks [list $completion_date $task_id $completion_user [list $title $content_html] "/packages/tasks/lib/task-chunk"]
}





set comments [list]
db_foreach get_comments "
         select g.comment_id,
                o.creation_user,
                o.creation_date,
                content,
                r.title,
                r.mime_type
           from general_comments g,
                cr_revisions r,
                acs_objects o
          where g.object_id = :party_id
            and r.revision_id = content_item__get_live_revision(g.comment_id)
            and o.object_id = g.comment_id
" {
    if { [exists_and_not_null truncate_len] } {
        set comment_html [ad_html_text_convert -truncate_len $truncate_len -from $mime_type -to "text/html" $content]
    } else {
        set comment_html [ad_html_text_convert -from $mime_type -to "text/html" $content]
    }
    lappend comments [list $creation_date $comment_id $creation_user $comment_html]
}

set hist [lsort -index 0 -decreasing [concat $tasks $comments]]

template::multirow create history date time object_id creation_user user_link include content

set result_number 1
foreach item $hist { 
    set timestamp      [lindex [split [lindex $item 0] "."] 0]
    set date          [lc_time_fmt $timestamp "%q"]
    set time          [string trimleft [lc_time_fmt $timestamp "%r"] "0"]
    set object_id     [lindex $item 1]
    set creation_user [lindex $item 2]
    set user_link     [contact::name -party_id $creation_user]
    set content       [lindex $item 3]
    set include       [lindex $item 4]
    template::multirow append history $date $time $object_id $creation_user $user_link $include $content
    if { [exists_and_not_null limit] } {
	incr result_number
	if { $result_number > $limit } {
	    break
	}
    }
}







ad_form -name comment_add \
   -action "[ad_conn package_url]comment-add" \
    -form "
        party_id:integer(hidden)
        return_url:text(hidden),optional
        {comment:text(textarea),nospell {label {}} {html {$textarea_size}} {after_html {<br />}}}
        {save:text(submit),optional {label {[_ contacts.Add_Comment]}}}
    " -on_request {
    } -after_submit {
    }

set user_id [ad_conn user_id]
