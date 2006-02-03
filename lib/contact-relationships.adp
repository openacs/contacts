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
	  </group>
	</group>
	<dd class="attribute-value"><a href="@rels.relation_url@" class="add-new-rel">#contacts.lt_Add_new_relsrelations#</a></dd>
      </dl>
  </multiple>
  </if>
