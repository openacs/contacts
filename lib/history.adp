<h3>#contacts.History#</h3>

<if @form@ eq top>
<formtemplate id="comment_add" style="../../../contacts/resources/forms/inline"></formtemplate>
</if>

<if @history:rowcount@ gt 0>
  <dl class="comments">
<multiple name="history">
    <dt id="@history.object_id@" class="<if @history.creation_user@ eq @user_id@>mine-</if><if @history.rownum@ odd>odd</if><else>even</else>">@history.date@ #contacts.at# @history.time@ @history.user_link@</dd>
      <dd class="<if @history.creation_user@ eq @user_id@>mine-</if><if @history.rownum@ odd>odd</if><else>even</else>">
   
	<if @history.include@ nil>
	      @history.content;noquote@
        </if>
        <else>
              <include src=@history.include@ content=@history.content;noquote@ object_id=@history.object_id@ party_id=@party_id@>
        </else>

      </dd>
</multiple>
  </dl>
</if>
<if @form@ eq bottom>
<formtemplate id="comment_add" style="../../../contacts/resources/forms/inline"></formtemplate>
</if>

