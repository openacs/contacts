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
            <b>@show_default_names;noquote@</b> @show_names;noquote@
            ( <a href="search?search_id=@search_id@">#contacts.Clear#</a> )
            <table><tr><td>
            <form action="/contacts/">
                <input type="hidden" name="attr_val_name" value="@attr_val_name@">
                <input type="hidden" name="search_id" value="@search_id@">
                <input type="submit" value="#contacts.Go#" style="font-size: 8px;">
            </form></td><td>
            <form action="save-attribute">
                <input type="hidden" name="attr_val_name" value="@attr_val_name@">
                <input type="hidden" name="search_id" value="@search_id@">
                <input type="submit" value="#contacts.Save#" style="font-size: 8px;">
            </form></td></tr></table>
            </small>
        </td>
	</if>
   </tr>
   </table>
</if>


