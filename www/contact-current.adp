<master>
<property name="title">@title@</property>
<property name="context">@context@</property>

<p>
  Are you sure you want to make <if @num_entries@ eq 1>this contact</if><else>these @num_entries@ contacts</else> current?
</p>

<p>
  <a href="@yes_url@">Make Current</a> - <a href="@no_url@">Cancel, do not make current</a>
</p>
