<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>



<fullquery name="attr_exists_p">
  <querytext>
        select 1 from contact_attributes where attribute_id = :attribute_id
  </querytext>
</fullquery>


<fullquery name="get_widget_id">
  <querytext>
        select widget_id from contact_attributes where attribute_id = :attribute_id
  </querytext>
</fullquery>


<fullquery name="get_widget_description">
  <querytext>
        select description as widget_description from contact_widgets where widget_id = :widget_id
  </querytext>
</fullquery>

<fullquery name="get_options_p">
  <querytext>
        select CASE WHEN storage_column = 'option_map_id' THEN '1' ELSE '0' END as options_p
          from contact_widgets
         where widget_id = :widget_id
  </querytext>
</fullquery>

<fullquery name="get_attribute_info">
  <querytext>
        select * from contact_attributes where attribute_id = :attribute_id
  </querytext>
</fullquery>

<fullquery name="get_attribute_name">
  <querytext>
        select * from contact_attribute_names where attribute_id = :attribute_id and locale = :locale
  </querytext>
</fullquery>

<fullquery name="get_attribute_options">
  <querytext>
        select option from contact_attribute_options where attribute_id = :attribute_id
  </querytext>
</fullquery>

<fullquery name="attribute_create">
  <querytext>
	    select contact__attribute_create (
                                              :attribute_id,
					      :attribute,
                                              :widget_id,
                                              'f',
                                              now(),
					      :user_id,
					      :peeraddr,
                                              :context_id
					      )
  </querytext>
</fullquery>

<fullquery name="attribute_name_save">
  <querytext>
        select contact__attribute_name_save (
                                            :attribute_id,
                                            :language,
                                            :name,
                                            :help_text
                                            )
  </querytext>
</fullquery>

<fullquery name="attribute_option_create">
  <querytext>
        select contact__attribute_option_create (:attribute_id,:option,:sort_order)
  </querytext>
</fullquery>


</queryset>
