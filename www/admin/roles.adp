<master>
<property name="context">@context;noquote@</property>
<property name="title">Roles</property>


<p><a href="role-ae" class="button">Create a role</a></p>
<ul>
  <if @roles:rowcount@ eq 0>
    <li> <em>(none)</em>
  </if><else>
  <multiple name="roles">
    <li> <a href=role-ae?role=<%=[ad_urlencode $roles(role)]%>>@roles.pretty_name@</a>
  </multiple>
  </else>
</ul>

