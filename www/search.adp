<master>

<property name="title">@page_title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
    <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>

<p><a href="my-searches" class="button">My Searches</a></p>
<formtemplate id="advanced_search" style="../../../contacts/resources/forms/inline"></formtemplate>

<if @query_code@ not nil and @sw_admin_p@>
<h3>Debugging Code - Only SW Admins See This</h3>

@query_code;noquote@
</if>
