<master>
<property name="title">@title@</property>
<property name="context">@context@</property>

<div id="subnavbar-div">
  <div id="subnavbar-container">
    <div id="subnavbar">

<if @views:rowcount@ gt 0>
  <multiple name="views">
          <div class="tab" <if @views.selected_p@>id="subnavbar-here"</if>>
              <a href="@views.url@" title="@views.name@">@views.name@</a>
          </div>
  </multiple>
</if>
        
    </div>
  </div>
</div>
<div id="subnavbar-body">



<include src="@src@">




<div style="clear: both;"></div>
</div>

