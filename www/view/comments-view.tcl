ad_page_contract {


    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {party_id:integer}
    {return_url}
    groupby:optional
    orderby:optional
    {format "normal"}
    {status "normal"}
}

set add_url "[apm_package_url_from_id [ad_conn package_id]]comment-add?[export_url_vars party_id return_url]"


list::create \
    -name comments \
    -multirow comments \
    -key comment_id \
    -row_pretty_plural "Comments" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
    } -actions {
    } -bulk_actions {
    } -bulk_action_export_vars { 
    } -elements {
        time {
            label "Time"
            display_col pretty_timestamp
        }
        author {
            display_col author
            label "Author"
            link_url_eval $author_url
        }
        comment {
            label "Comment"
            display_col content_html;noquote
        }
    } -filters {
    } -groupby {
    } -orderby {
        default_value time,desc
        time {
            label "Time"
            orderby_desc "o.creation_date desc"
            orderby_asc  "o.creation_date asc"
            default_direction desc
        }
        author {
            label "Author"
            orderby_desc "acs_object__name(o.creation_user) desc, o.creation_date desc"
            orderby_asc  "acs_object__name(o.creation_user) asc, o.creation_date desc"
            default_direction asc
        }
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                time {}
                author {}
                comment {}
            }
        }
    }



# This query will override the ad_page_contract value entry_id
template::multirow create comments comment_id author author_url pretty_timestamp content content_html

set package_id [ad_conn package_id]
db_foreach get_comments "
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
" {
    set author_url "[apm_package_url_from_id [ad_conn package_id]]view/$creation_user"
    set content_html [ad_html_text_convert -from $mime_type -to "text/html" $content]
    template::multirow append comments $comment_id $author $author_url $pretty_timestamp $content $content_html
}

















set login_button [list [list "Add this Comment" ok]]

ad_form -name comment -action comments-view -edit_buttons $login_button -form {
        new_comment_id:key
        party_id:integer(hidden)
        return_url:text(hidden)
        {description:text(textarea),nospell {label "Comment"} {html { rows 6 cols 65 wrap soft}}}
    } -new_request {
    } -on_submit {
        
        # insert the comment into the database
#        set description_body [template::util::richtext::get_property contents $description]
#        set description_format [template::util::richtext::get_property format $description]
        set description_body [string trim $description]
        set description_format "text/plain"


        general_comment_new -object_id $party_id \
            -comment_id $new_comment_id \
            -title [contact::name $party_id] \
            -user_id [ad_conn user_id] \
            -creation_ip [ad_conn peeraddr] \
            -context_id [ad_conn package_id] \
            -is_live t \
            -comment_mime_type $description_format \
            -content $description_body \
            -category ""

        ad_returnredirect -message "Comment added" $return_url
    }


ad_return_template
