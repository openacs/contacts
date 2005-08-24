    <if @attributes:rowcount@ gt 0>
  <multiple name="attributes">
	<h3 class="contact-title">@attributes.section@</h3>
	<dl class="attribute-values">
	  <group column="section">
	    <dt class="attribute-name">@attributes.attribute@:</dt>
	    <dd class="attribute-value">@attributes.value;noquote@</dd>
	  </group>
	</dl>
      </multiple>
    </if>
  
