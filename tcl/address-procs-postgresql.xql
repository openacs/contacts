<?xml version="1.0"?>
<queryset>

<rdbms><type>postgresql</type><version>7.2</version></rdbms>

<fullquery name="template::util::address::country_options.get_countries">
  <querytext>
        select default_name, iso from countries order by default_name
  </querytext>
</fullquery>


<fullquery name="template::data::validate::address.validate_state">
  <querytext>
        select 1 from us_states where abbrev = upper(:region) or state_name = upper(:region)

  </querytext>
</fullquery>


</queryset>
