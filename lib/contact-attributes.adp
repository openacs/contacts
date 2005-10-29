    <if @attributes:rowcount@ gt 0>
    	<table width="100%">
  <multiple name="attributes">
	<h3 class="contact-title">@attributes.section@</h3>
	  <group column="section">
	 <tr>
	    <td valign="top" align="right">@attributes.attribute@:</td>
	    <td valign="top" align="left">@attributes.value;noquote@</td>
	</tr>
	  </group>

      </multiple>
      </table>
    </if>
  
