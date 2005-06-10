<master>
<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
    <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>
<div id="section">
  <ul>
    <li><a href="contact-add?object_type=person">#contacts.Add_Person#</a>
    <li><a href="contact-add?object_type=organization">#contacts.Add_Organization#</a>
    <li><a href="search">#contacts.Advanced_Search#</a>
    <li><a href="my-searches">#contacts.My_Searches#</a>
    <li><a href="settings"><strong>#contacts.Settings#</strong></a>
    <li><a href="admin">#contacts.Admin#</a><em>&nbsp;</em> </li>
  </ul>
</div>

<p>
<a href="signature" class="button">#contacts.Add_Signature#</a></if>
<if @admin_p@><a href="admin/" class="button">#contacts.Administer_Contacts#</a></if>
</p>
<h3>#contacts.My_Signatures#</h3>
<listtemplate name="signatures"></listtemplate>



