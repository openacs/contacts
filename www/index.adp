<master>

<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
    <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>


<if @admin_p@>
<div align="right">
[ <a href="admin">Admin</a> ]
</div>
</if>


  <table cellpadding="3" cellspacing="3">
    
    <tr>
      
      <td class="list-filter-pane" valign="top">



  <p style="margin-top: 0px; margin-bottom: 12px;">
    <table border="0" cellspacing="0" cellpadding="2" width="100%">
      <tr>
        <td class="list-filter-header">
         #contacts.Search# (<a href="./index?searchterm=&@export_vars_search_url@" title="#contacts.Clear_the_currently_selected_Search#">clear</a>)
         
        </td>
      </tr>
      <tr>
        <td class="list-filter">
        <form method=post name=search action="./">
          <input type=text name=searchterm value="@searchterm@" size="15" />
          @export_vars_search_form;noquote@
          <input type="submit" value="Go" />
        </form>
        </td>
      </tr>
    </table>
  </p>


<if @categories_p@>
  <p style="margin-top: 0px; margin-bottom: 12px;">
    <table border="0" cellspacing="0" cellpadding="2" width="100%">
      <tr>
        <td class="list-filter-header">
         #contacts.Limit_Contacts_to# (<a href="./index?category_id=&@export_vars_category_url@" title="#contacts.Clear_the_currently_selected_Category#">clear</a>)         
        </td>
      </tr>
      <tr>
        <td class="list-filter">
        @category_select;noquote@
        </td>
      </tr>
    </table>
  </p>
</if>
        
<listfilters name="entries"></listfilters>
        
      </td>
      
      <td class="list-list-pane" valign="top">
<div id="contacts-sortbars">
<p>@letter_bar;noquote@</p>

<if @total_rows@ gt 0>
<p>#contacts.Showing# @first_row@ - @last_row@ #contacts.of# @total_rows@
<if @prev_link_p@>| <a href="@prev_link_url@">Prev</a> </if>
<if @next_link_p@>| <a href="@next_link_url@">Next</a> </if>
</p>
</if>
</div>
<listtemplate name="entries"></listtemplate>
        
      </td>
      
    </tr>
    
  </table>



