<master>

<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_stuff">
    <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>
<p>All searches are case insensitive, capitalization does not matter. If more than one contact match the search a list of results is returned. If only one contact meets the search criteria you are redirected to that contact.</p>
<h3>Normal Searches</h3>
<p>Entering a string in the normal search box means that a search will be performed where:</p>
<ol>
<li>"First Names" contains "Search_Word" or
<li>"Last Name" contains "Search_Word" or 
<li>"Organization Name" contains "Search_Word" or
<li>"Party ID" equals "Search_Word"
</ol>
<p>If multiple words are used then all words must match the above critera. So, for example if our contacts database contains these entries:
<pre>
Contact ID    | First Names    | Last Name     | Organization Name
--------------+----------------+---------------+---------------------------------
123           | Jane           | Doe           |
234           | John           | Doe           |
345           | Alfred         | Hitchcock     |
456           |                |               | United States Treasury
</pre>
<p>If in a normal search we search for "D Jane". The first Search_Word ("D") matches contacts 123 (via "Doe"), 234 (via "Doe"), and 345 (via "Alfred"). And the second Search_Word ("Jane") matches only contact 123. Thus only one contact meets both requirements and "Jane Doe" (contact 123) is returned.</p>

<h3>Advanced Searches</h3>
<p>Advanced searches are very powerful but in return they require very specific input...
