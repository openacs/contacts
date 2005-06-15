<master src="/packages/contacts/lib/contact-master" />
<property name="party_id">@party_id@</property>
<div id="contact-info">
  <div class="primary">
    <if @attributes:rowcount@ gt 0>
      <multiple name="attributes">
	<h3 class="contact-title">@attributes.section@</h3>
	<dl class="attribute-values">
	  <group column="section">
	    <dt class="attribute-name">@attributes.attribute@:</dt>
	    <dd class="attribute-value">@attributes.value;noquote@</dd>
	  </group>
	</dl>
      </multiple>
    </if>
    <if @rels:rowcount@ gt 0>
      <multiple name="rels">
	<h3 class="contact-title">@rels.relationship@</h3>
	<dl class="attribute-values">
	  <group column="relationship">
	    <dt class="attribute-name">
	      <strong>@rels.relationship@:</strong>
	    </dt>
	    <dd class="attribute-value">
	      <strong>
		<a href="@rels.contact_url@">@rels.contact@</a>
	      </strong>
	    </dd>
	    <group column="contact_url">
	      <if @rels.attribute@ not nil>
		<dt class="attribute-name">@rels.attribute@:</dt>
		<dd class="attribute-value">@rels.value;noquote@</dd>
	      </if>
	</dl>
    </if>
  </group>
  </group>
  </multiple>
  </if>
  </div>
  <div class="secondary">
    <include
      src="/packages/contacts/lib/groups"
      party_id="@party_id@"
      hide_form_p="t" />
    <if @tasks_enabled_p@>
      <include
	src="/packages/tasks/lib/tasks"
	party_id="@party_id@"
	hide_form_p="t" />
    </if>
    <include
      src="/packages/contacts/lib/comments"
      party_id="@party_id@"
      limit="3"
      truncate_len="100"
      size="small"
      recent_on_top_p="1" />
    <if @dotlrn_club_enabled_p@>
      <a href="@club_url@">#contacts.Visit_Club#</a>
      </if>
    <if @projects_enabled_p@>
    <if @project_url@ ne "">
      <br />
      <h3>
	<a href="@project_url@">#contacts.PROJECT#</a>
	<include
	  src="/packages/project-manager/lib/subprojects"
	  project_item_id="@project_id@"
	  base_url="@base_url@" />
    </if>
    </if>
    <if @update_date@ not nil>
      <p class="last-updated">#contacts.Last_updated# @update_date@</p>
    </if>
  </div>
</div>


