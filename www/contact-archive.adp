<master>
<property name="title">@title@</property>
<property name="context">@context@</property>

<p>
  Are you sure you want to archive <if @num_entries@ eq 1>this contact</if><else>these @num_entries@ contacts</else>?
</p>

<p>
  <a href="@yes_url@">Archive</a> - <a href="@no_url@">Cancel, do not archive</a>
</p>
