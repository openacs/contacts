<if @search_id@ not nil and @hide_form_p@ nil>
    <br>
    <table>
	<tr><td><b>#contacts.You_can_extend#</b></td></tr>
	<tr>
    	<if @available_options@ not nil>
	   <td><formtemplate id="extend" style="inline"></formtemplate></td>
           <td>&nbsp;&nbsp;&nbsp;</td>
        </if>
	</tr>
    </table>
</if>

<br>
<listtemplate name="contacts"></listtemplate>
