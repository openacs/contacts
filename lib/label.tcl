# packages/contacts/lib/email.tcl
# Template for email inclusion
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-06-14
# @arch-tag: 48fe00a8-a527-4848-b5de-0f76dfb60291
# @cvs-id $Id$

foreach required_param {party_ids recipients} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {return_url} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}
set message_type "label"

ad_form -action message \
    -name letter \
    -cancel_label "[_ contacts.Cancel]" \
    -cancel_url $return_url \
    -edit_buttons [list [list "[_ contacts.create_label] (this make take a bit, please be patient)" print]] \
    -export {party_ids return_url title message_type} \
    -form {
	message_id:key
	{recipients:text(inform) {label "Contacts to Export"}}
	{label_type:text(select),optional
	    {label "[_ contacts.Label_Type]"}
	    {options {{"Avery 5160 (1in x 2.5in, 30 per sheet)" avery5160}}}
	}
    } -on_request {
    } -on_submit {
	# display the progress bar

	ad_progress_bar_begin \
	    -title "Generating PDF" \
	    -message_1 "Generating mailing labels for the contacts you selected, please wait..." \
	    -message_2 "You will be automatically redirected once the file is complete."



	set labels [list]
	foreach party_id $party_ids {
	    set name [contact::name -party_id $party_id]
	    set mailing_address [contact::message::mailing_address -party_id $party_id -format "text/plain"]
	    if {[empty_string_p $mailing_address]} {
		ad_return_error [_ contacts.Error] [_ contacts.lt_there_was_an_error_processing_this_request]
		break
	    }
 	    
	    set name            [openreport::clean_string_for_rml -string ${name}]
	    set mailing_address [openreport::clean_string_for_rml -string ${mailing_address}]

	    set one "<para style=\"name\">
${name}
</para>
<xpre style=\"address\">
${mailing_address}
</xpre>
"
	    lappend labels [string trim $one]


	}
	

	if { $label_type == "avery5160" } {
	
	# onLoad=\"window.print()\"
	set rml {
<!DOCTYPE document SYSTEM "rml_1_0.dtd">
<document filename="filename.pdf">
<template pageSize="(8.5in, 11in)"
          leftMargin="0in"
          rightMargin="0in"
          topMargin="0in"
          bottomMargin="0in"
          title="Mailing Labels"
          author="mbseminary.edu"
          allowSplitting="0"
          showBoundary="0"
          >
          <!-- showBoundary means that we will be able to see the            -->
          <!-- limits of frames                                              -->
    <pageTemplate id="main">
        <pageGraphics>
        </pageGraphics>
        <frame id="label01" x1="0.25in" y1="9.30in" width="2.50in" height="1.00in"/>
        <frame id="label02" x1="0.25in" y1="8.30in" width="2.50in" height="1.00in"/>
        <frame id="label03" x1="0.25in" y1="7.30in" width="2.50in" height="1.00in"/>
        <frame id="label04" x1="0.25in" y1="6.30in" width="2.50in" height="1.00in"/>
        <frame id="label05" x1="0.25in" y1="5.30in" width="2.50in" height="1.00in"/>
        <frame id="label06" x1="0.25in" y1="4.30in" width="2.50in" height="1.00in"/>
        <frame id="label07" x1="0.25in" y1="3.30in" width="2.50in" height="1.00in"/>
        <frame id="label08" x1="0.25in" y1="2.30in" width="2.50in" height="1.00in"/>
        <frame id="label09" x1="0.25in" y1="1.30in" width="2.50in" height="1.00in"/>
        <frame id="label10" x1="0.25in" y1="0.30in" width="2.50in" height="1.00in"/>
        <frame id="label11" x1="3.00in" y1="9.30in" width="2.50in" height="1.00in"/>
        <frame id="label12" x1="3.00in" y1="8.30in" width="2.50in" height="1.00in"/>
        <frame id="label13" x1="3.00in" y1="7.30in" width="2.50in" height="1.00in"/>
        <frame id="label14" x1="3.00in" y1="6.30in" width="2.50in" height="1.00in"/>
        <frame id="label15" x1="3.00in" y1="5.30in" width="2.50in" height="1.00in"/>
        <frame id="label16" x1="3.00in" y1="4.30in" width="2.50in" height="1.00in"/>
        <frame id="label17" x1="3.00in" y1="3.30in" width="2.50in" height="1.00in"/>
        <frame id="label18" x1="3.00in" y1="2.30in" width="2.50in" height="1.00in"/>
        <frame id="label19" x1="3.00in" y1="1.30in" width="2.50in" height="1.00in"/>
        <frame id="label20" x1="3.00in" y1="0.30in" width="2.50in" height="1.00in"/>
        <frame id="label21" x1="5.75in" y1="9.30in" width="2.50in" height="1.00in"/>
        <frame id="label22" x1="5.75in" y1="8.30in" width="2.50in" height="1.00in"/>
        <frame id="label23" x1="5.75in" y1="7.30in" width="2.50in" height="1.00in"/>
        <frame id="label24" x1="5.75in" y1="6.30in" width="2.50in" height="1.00in"/>
        <frame id="label25" x1="5.75in" y1="5.30in" width="2.50in" height="1.00in"/>
        <frame id="label26" x1="5.75in" y1="4.30in" width="2.50in" height="1.00in"/>
        <frame id="label27" x1="5.75in" y1="3.30in" width="2.50in" height="1.00in"/>
        <frame id="label28" x1="5.75in" y1="2.30in" width="2.50in" height="1.00in"/>
        <frame id="label29" x1="5.75in" y1="1.30in" width="2.50in" height="1.00in"/>
        <frame id="label30" x1="5.75in" y1="0.30in" width="2.50in" height="1.00in"/>
    </pageTemplate>
</template>
<stylesheet>
    <paraStyle name="name"
      fontName="Helvetica"
      fontSize="9"
      alignment="CENTER"
    />
    <paraStyle name="address"
      fontName="Helvetica"
      fontSize="9"
      alignment="CENTER"
    />
</stylesheet>
<!-- The story starts below this comment -->
<story>
}

    }
	set rml [string trim $rml]
	append rml "\n[join $labels "\n<nextFrame />\n<condPageBreak height=\"0in\" />\n"]"
	append rml "\n</story>\n</document>"

	# Gerneate the pdf
	set filename "contacts_labels_[ad_conn user_id]_[dt_systime -format {%Y%m%d-%H%M%S}]_[ad_generate_random_string].pdf"
	set pdf_filename [openreport::trml2pdf -rml $rml -filename $filename]
	util_user_message -html -message "The pdf you requested is available. You may <a href=\"[ad_conn package_url]pdfs/${filename}\">download it now</a>."
	ad_progress_bar_end -url "[ad_conn package_url]pdfs/"

#	ad_returnredirect 
        ad_script_abort

    }




















































