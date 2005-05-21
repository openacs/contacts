<master>
<property name="context">@context;noquote@</property>
<property name="title">@title@</property>


<p>
<a href="relationship-ae" class="button">Define a new relationship type</a>
<a href="roles" class="button">View all roles</a>
</p>
<p>Currently, the system is able to handle the following types of relationships: </p>



<dl>

  <if @rel_types:rowcount@ eq 0>
    <dt><em>(none)</em></dt>
      
  </if>
  <else>
  
  <multiple name="rel_types">
    <dt><strong>@rel_types.primary_type_pretty@ -> @rel_types.secondary_type_pretty@</strong></dt>
    <dl>
      <ul>
        <group column=sort_two>
        <li>@rel_types.primary_role_pretty@ -> @rel_types.secondary_role_pretty@ <a href="@rel_types.rel_form_url@" class="button">Attributes</a></li>
        </group>
      </ul>
    </dl>
  </multiple>

  </else>

</dl>


