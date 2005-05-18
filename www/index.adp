<master>

<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
    <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>
<property name="focus">search.query</property>
<div id="section">
  <ul>
    <li><a href="contact-add?object_type=person" title="Add a Person">Add Person</a>
    <li><a href="contact-add?object_type=organization" title="Add an Organization">Add Organization</a>
    <li><a href="search" title="Advanced Search">Advanced Search</a>
<!--    <li><a href="@tasks_url@" title="Show tasks assigned to these contacts">Tasks</a> -->
    <li><a href="settings" title="Modify My Settings">Settings</a>
    <li><a href="admin" title="Admin">Admin</a><em>&nbsp;</em> </li>
  </ul>
</div>

<p><formtemplate id="search" style="proper-inline"></formtemplate></p>

<listtemplate name="contacts"></listtemplate>
        

