<master>

<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
    <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>
<div id="section">
  <ul>
    <li><a href="@person_add_url@">#contacts.Add_Person#</a>
    <li><a href="@organization_add_url@">#contacts.Add_Organization#</a>
    <li><a href="search">#contacts.Advanced_Search#</a>
    <li><a href="my-searches">#contacts.My_Searches#</a>
    <li><a href="settings">#contacts.Settings#</a>
    <li><a href="admin">#contacts.Admin#</a><em>&nbsp;</em> </li>
  </ul>
</div>

<p><formtemplate id="search" style="../../../contacts/resources/forms/inline"></formtemplate></p>


<include src="../lib/contacts">
        


