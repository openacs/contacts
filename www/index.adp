<master>

<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
    <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>
<property name="focus">search.query</property>
<div id="section">
  <ul>
    <li><a href="contact-add?object_type=person" title="Add a Person">#contacts.Add_Person#</a>
    <li><a href="contact-add?object_type=organization" title="Add an Organization">#contacts.Add_Organization#</a>
    <li><a href="search" title="Advanced Search">#contacts.Advanced_Search#</a>
    <li><a href="settings" title="Modify My Settings">#contacts.Settings#</a>
    <li><a href="admin" title="Admin">#contacts.Admin#</a><em>&nbsp;</em> </li>
  </ul>
</div>

<p><formtemplate id="search" style="../../../contacts/resources/forms/inline"></formtemplate></p>

<listtemplate name="contacts"></listtemplate>
        


