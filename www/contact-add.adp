<master>
<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
    <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>
<property name="focus">party_ae.first_names</property>
<div id="section">
  <ul>
    <li><a href="contact-add?object_type=person"><if @object_type@ eq person><strong></if>#contacts.Add_Person#<if @object_type@ eq person></strong></if></a>
    <li><a href="contact-add?object_type=organization"><if @object_type@ eq organization><strong></if>#contacts.Add_Organization#<if @object_type@ eq organization></strong></if></a>
    <li><a href="search">#contacts.Advanced_Search#</a>
    <li><a href="my-searches">#contacts.My_Searches#</a>
    <li><a href="settings">#contacts.Settings#</a>
    <li><a href="admin">#contacts.Admin#</a><em>&nbsp;</em> </li>
  </ul>
</div>

<formtemplate id="party_ae"></formtemplate>


