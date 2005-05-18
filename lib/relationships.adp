
<if @relationships:rowcount@ gt 0>
<div class="relationships">
<h3>Relationships</h3>
  <dl>
<multiple name="relationships">
    <dt>@relationships.role_singular@</dt>
      <group column="role">
      <dd><a href="@relationships.contact_url@">@relationships.other_name@</a></dd>
      </group>
</multiple>
  </dl>
</div>

</if>
