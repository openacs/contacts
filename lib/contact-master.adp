<master>
<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
  <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>
<if @focus@ not nil>
<property name="focus">@focus@</property>
</if>
<div id="section">
  <ul>
<multiple name="links">
    <li><a href="@links.url@" title="Go to @links.label@"><if @links.selected_p@><strong></if>@links.label@<if @links.selected_p@></strong></if></a><if @links:rowcount@ eq @links.rownum@ and @public_url@ nil><em>&nbsp;</em></if> </li>
</multiple>
<if @public_url@ not nil>
    <li><a href="@public_url@" title="Go to this community member's public page">Public Page</a><em>&nbsp;</em> </li>
</if>
  </ul>
</div>

<slave>

