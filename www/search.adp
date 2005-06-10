<master>

<property name="title">@page_title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
    <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>
<div id="section">
  <ul>
    <li><a href="contact-add?object_type=person">#contacts.Add_Person#</a>
    <li><a href="contact-add?object_type=organization">#contacts.Add_Organization#</a>
    <li><a href="search"><strong>#contacts.Advanced_Search#</strong></a>
    <li><a href="my-searches">#contacts.My_Searches#</a>
    <li><a href="settings">#contacts.Settings#</a>
    <li><a href="admin">#contacts.Admin#</a><em>&nbsp;</em> </li>
  </ul>
</div>

<formtemplate id="advanced_search" style="../../../contacts/resources/forms/inline"></formtemplate>


<if @query_code@ not nil and @sw_admin_p@>
<h3>#contacts.lt_Debugging_Code_-_Only#</h3>

@query_code;noquote@
</if>

