<master src="/packages/contacts/lib/contact-master" />
<property name="party_id">@party_id@</property>
<div id="contact-info">
  <div class="primary">
    <include src="/packages/contacts/lib/contact-attributes" party_id="@party_id@" />
    <include src="/packages/contacts/lib/contact-relationships" party_id="@party_id@" />
  </div>
  <div class="secondary">
    <if @dotlrn_club_enabled_p@>
      <h3 class="contact-title"><a href="@club_url@">#contacts.Visit_Club#</a></h3>
      </if>
    <include
      src="/packages/contacts/lib/searches"
      party_id="@party_id@"
      hide_form_p="t" />
    <if @tasks_enabled_p@>
      <include
	src="/packages/tasks/lib/tasks"
	party_id="@party_id@"
	hide_form_p="t" />
    </if>
    <include
      src="/packages/contacts/lib/history"
      party_id="@party_id@"
      limit="3"
      truncate_len="100"
      size="small"
      recent_on_top_p="1" />
    <if @pm_package_id@>
      <include src=/packages/project-manager/lib/projects orderby=@orderby;noquote@ elements="planned_end_date category_id" package_id=@pm_package_id@ actions_p="1" bulk_p="1" assignee_id="" filter_p="0" base_url="@pm_base_url@" customer_id="@party_id@" status_id="1" fmt="%x %r">
</if>
    <if @projects_enabled_p@>
      <if @project_url@ ne "">
	<br />
	<h3>
	  <a href="@project_url@">#contacts.PROJECT#</a></h3>
	  <include
	    src="/packages/project-manager/lib/subprojects"
	    project_item_id="@project_id@"
	    base_url="@base_url@" />
      </if>
    </if>
    <if @object_type@ eq "organization">
      <if @invoices_enabled_p@>
	<include src="/packages/invoices/lib/offer-list" organization_id="@party_id@" elements="offer_nr title amount_total" package_id="@iv_package_id@" base_url="@iv_base_url@" />
	
	<h3 class="contact-title"><a href="/invoices">#invoices.Billable_Projects#</a></h3>
	<include src="/packages/invoices/lib/projects-billable" organization_id="@party_id@" elements="checkbox project_id title amount_open" package_id="@iv_package_id@" base_url="@iv_base_url@" />
	<include src="/packages/glossar/lib/glossar-list" owner_id=@party_id@ orderby=@orderby@ customer_id=@party_id@ format=table></include>
      </if>
      <if @pm_installed_p@>
	<br>
	<h3 class="contact-title">#contacts.Complaints#:</h3>
	<include src="/packages/contacts/lib/contact-complaint-list" 
	    customer_id=@party_id@
	    elements="title supplier state description"
	>
	<form action="/contacts/add-edit-complaint">
	#contacts.Add_complaint_to#: @select_menu;noquote@
	     <input type="hidden" name="customer_id" value="@party_id@">
	     <input type="submit" value="#contacts.Add_1#">
	</form>
	<br>
	<h3 class="contact-title">#contacts.Freelancers#:</h3>
	<include src="/packages/project-manager/lib/customer-group-list" 
	    customer_id=@party_id@
	    group_name="Freelancer"
	    elements="name project_name deadline"
	    cgl_orderby=@cgl_orderby;noquote@
	    page=@page@
	>
	<br>
        <include src="/packages/project-manager/lib/tasks"
		display_mode="list"
		elements="task_item_id title slack_time project_item_id percent_complete"
		is_observer_p="f"
		orderby="title,asc"
		status_id="1"
		party_id=@dotlrn_club_id@
		assign_group_p="1"
	>
      </if>
    </if>
    <if @update_date@ not nil>
      <p class="last-updated">#contacts.Last_updated# @update_date@</p>
    </if>
  </div>
</div>



