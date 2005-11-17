    <if @attributes:rowcount@ gt 0>
   <table>
    <multiple name="attributes">
     <tr>
       	<td colspan="2" align="left"><h3 class="contact-title">@attributes.section@</h3></td>
     </tr>
	<dl class="attribute-values">
	  <group column="section">
 	     <tr>
	 	<td align="right" valign="top">@attributes.attribute@:</td>
		<td align="left" valign="top">@attributes.value;noquote@</td>
	    </tr>
	  </group>

      </multiple>
      </table>
    </if>
  
