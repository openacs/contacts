# /packages/project-manager/www/comments/add.tcl

ad_page_contract {
    
    Adds a general comment to a project or task
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-09
    @arch-tag: 7448d185-3d5c-43f2-853e-de7c929c4526
    @cvs-id $Id$
} {
    party_id:integer,notnull
    return_url:notnull
} -properties {
} -validate {
} -errors {
}
set name "[contact::name $party_id]"
set title "Add a comment to: $name"
set context [list [list "$return_url" "$name"] "Add a comment"]


ad_form -name comment -action comment-view -form {
        comment_id:key
        party_id:integer(hidden)
        view_id:integer(hidden)
        return_url:text(hidden)
        {comment_title:text {label "Title"} {html {size 50}}}
        {description:richtext(richtext),optional {label "Comment"} {html { rows 12 cols 65 wrap soft}}}
    } -new_request {
        set comment_title $name
    } -on_submit {
        
        # insert the comment into the database
        set description_body [template::util::richtext::get_property contents $description]
        set description_format [template::util::richtext::get_property format $description]

        general_comment_new -object_id $party_id \
            -comment_id $comment_id \
            -title $comment_title \
            -user_id [ad_conn user_id] \
            -creation_ip [ad_conn peeraddr] \
            -context_id [ad_conn package_id] \
            -is_live t \
            -comment_mime_type $description_format \
            -content $description_body \
            -category ""

        ad_returnredirect -message "Comment: [ad_quotehtml $title] saved" $return_url
    }

