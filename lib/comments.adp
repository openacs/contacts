
<h3 class="contact-title">Comments</h3>

<if @form@ eq top>
<formtemplate id="comment_add" style="../../../contacts/resources/forms/inline"></formtemplate>
</if>

<if @comments:rowcount@ gt 0>
  <dl class="comments">
<multiple name="comments">
    <dt id="@comments.comment_id@" class="<if @comments.creation_user@ eq @user_id@>mine-</if><if @comments.rownum@ odd>odd</if><else>even</else>"><a href="comments#@comments.comment_id@" class="number">@comments.comment_number@.</a> @comments.pretty_date@ at @comments.pretty_time@ - <a href="contact?party_id=@comments.creation_user@">@comments.author@</a></dd>
      <dd class="<if @comments.creation_user@ eq @user_id@>mine-</if><if @comments.rownum@ odd>odd</if><else>even</else>">@comments.comment_html;noquote@</dd>
</multiple>
  </dl>
</div>
</if>

<if @form@ eq bottom>
<formtemplate id="comment_add" style="../../../contacts/resources/forms/inline"></formtemplate>
</if>