<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<formtemplate id="add_option"></formtemplate>

<br>
<if @edit_p@ eq "f"> 
    <h3>#contacts.Stored_extended#:</h3>
    <listtemplate name="ext_options"></listtemplate>
</if>