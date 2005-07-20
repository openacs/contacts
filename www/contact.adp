<master src="/packages/contacts/lib/contact-master" />
<property name="party_id">@party_id@</property>
<div id="contact-info">
  <div class="primary">
    <include src="/packages/contacts/lib/contact-attributes" party_id="@party_id@" />
    <include src="/packages/contacts/lib/contact-relationships" party_id="@party_id@" />
    <dl>
      <dd class="attribute-value">
	<if @employee_url@ ne "">
	  <strong><a href="@employee_url@">Add new employee</a></strong>
	</if>      
      </dt>
    </dl>
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
	<h3 class="contact-title"><a href="@pm_base_url@">#project-manager.Projects#</a></h3>
            <include src=/packages/project-manager/lib/projects orderby=@orderby;noquote@    elements="customer_name  earliest_finish_date latest_finish_date actual_hours_completed category_id" package_id=@pm_package_id@ actions_p="1" bulk_p="1" assignee_id="" filter_p="0" base_url="@pm_base_url@" customer_id="@party_id@" status_id="1">
</if>
    <if @projects_enabled_p@>
      <if @project_url@ ne "">
	<br />
	<h3>
	  <a href="@project_url@">#contacts.PROJECT#</a>
	  <include
	    src="/packages/project-manager/lib/subprojects"
	    project_item_id="@project_id@"
	    base_url="@base_url@" />
      </if>
    </if>
    <if @invoices_enabled_p@>
      <h3 class="contact-title"><a href="/invoices">#invoices.Offers#</a></h3>
      <include src="/packages/invoices/lib/offer-list" organization_id="@party_id@" elements="offer_nr title amount_total" package_id="@iv_package_id@" base_url="@iv_base_url@" />
	
      <h3 class="contact-title"><a href="/invoices">#invoices.Billable_Projects#</a></h3>
      <include src="/packages/invoices/lib/projects-billable" organization_id="@party_id@" elements="checkbox project_id title amount_open" package_id="@iv_package_id@" base_url="@iv_base_url@" />
    </if>
    <if @update_date@ not nil>
      <p class="last-updated">#contacts.Last_updated# @update_date@</p>
    </if>
  </div>
</div>


