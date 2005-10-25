<master src="/packages/contacts/lib/contacts-master" />

<formtemplate id="advanced_search" style="../../../contacts/resources/forms/inline"></formtemplate>

<br />
<br />
<if @search_exists_p@>
    <table>
    <tr>
        <td>
        <formtemplate id="extend_attributes" style="../../../contacts/resources/forms/inline"></formtemplate>
        </td>
	<if @attribute_values@ not nil>
        <td>
	    <small>
            <form action="/contacts/">
	        <b>@show_default_names;noquote@</b> @show_names;noquote@ 	
  	        ( <a href="search?search_id=@search_id@">#contacts.Clear#</a> )
	        <input type="hidden" name="attr_val_name" value="@attr_val_name@">
	        <input type="hidden" name="search_id" value="@search_id@">
		<input type="submit" value="#contacts.Go#" style="font-size: 8px;">
            </form>
            </small>
        </td>
	</if>
   </tr>
   </table>
</if>


