<div id="comments">

<h3>Comments</h3>

<if @form@ eq top>
<form name="comment_add" method="post" action="@package_url@comment-add">
<input type="hidden" name="party_id" value="@party_id@" />
<input type="hidden" name="return_url" />
<textarea name="comment" @textarea_size;noquote@></textarea>
<br /><input type="submit" name="save" value="Add Comment" class="comment-button"/>
</form>
</if>

<if @comments:rowcount@ gt 0>
  <dl>
<multiple name="comments">
    <dt id="@comments.comment_id@" class="<if @comments.creation_user@ eq @user_id@>mine-</if><if @comments.rownum@ odd>odd</if><else>even</else>"><a href="comments#@comments.comment_id@" class="number">@comments.comment_number@.</a> @comments.pretty_date@ at @comments.pretty_time@ - <a href="contact?party_id=@comments.creation_user@">@comments.author@</a></dd>
      <dd class="<if @comments.creation_user@ eq @user_id@>mine-</if><if @comments.rownum@ odd>odd</if><else>even</else>">@comments.comment_html;noquote@</dd>
</multiple>
  </dl>
</div>
</if>

<if @form@ eq bottom>
<form name="comment_add" method="post" action="@package_url@comment-add">
<input type="hidden" name="party_id" value="@party_id" />
<input type="hidden" name="return_url" />
<textarea name="comment" @textarea_size;noquote@></textarea>
<br /><input type="submit" name="save" value="Add Comment" class="comment-button"/>
</form>
</if>
