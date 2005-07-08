<if @public_searches:rowcount@ gt 0>
<h3>#contacts.In_Searches#</h3>
<ul>
<multiple name="public_searches">
  <li><a href="@public_searches.url@">@public_searches.title@</a></li>
</multiple>
</ul>
</if>
