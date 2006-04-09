ad_library {

    Support procs for the contacts package with regards to OpenOffice

    Before you can make use of these functions, OpenOffice 2.0 needs to be installed in your system. 
    Additionally you need ghostscript and the msttftcorefonts (so your users wont complain about wrong verdana fonts)
    Not to forget "vncserver" and "x11fonts".

    Once this is done, call "spadmin" as the user running the AOLserver and configure a printer for PDF
    printing. Ideally you would call the printer "pdfconv", though you can specify any other name as well.

    Once spadmin has started, choose to create a PDF Konverter and make use of the Adobe Distiller and 
    choose the following command:
    /usr/bin/gs -q -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="(OUTFILE)" -
    
    and the target directory /tmp/. Call the printer "pdfconv". Once done, click on fonts, choose "Add fonts"
    and search in /usr/share. Add all fonts you find there. 

    Last but not least make sure that you have the "vncserver" running for your user and that ../bin/convert.sh reflects your
    environment

    @author Malte Sussdorff
    @creation-date 2006-04-18
}

namespace eval contact::oo:: {}

ad_proc -public contact::oo::convert {
    {-content}
} {
    Returns a string which we can insert into the content.xml file
    
    This is a replacement procedure which should hopefully deal with at least the breaks
    links and paragraphs. 
} {
    regsub -all -nocase "<br>" $content "<text:line-break/>" content
    regsub -all -nocase "<p>" $content "<text:line-break/>" content
    regsub -all -nocase "&nbsp;" $content " " content
    regsub -all -nocase "</p>" $content "<text:line-break/>" content
    regsub -all -nocase "a href=" $content "text:a xlink:type=\"simple\" xlink:href=" content
    regsub -all -nocase "/a" $content "/text:a" content
    return [string trim $content]
}
    

ad_proc -public contact::oo::import_oo_pdf {
    -oo_file:required
    {-printer_name "pdfconv"}
    {-title ""}
    {-item_id ""}
    {-parent_id ""}
    {-no_import:boolean}
} {
    Imports an OpenOffice file (.sxw / .odt) as a PDF file into the content repository. If item_id is specified a new revision of that item is created, else a new item is created.
    
    @param oo_file The full path to the OpenOffice file that containst the data to be exported as PDF.
    @param printer_name The name of the printer that is assigned as the PDF converter. Defaults to "pdfconv".
    @param title Title which will be used for the resulting content item and file name if none was given in the item
    @param item_id The item_id of the content item to which the content should be associated.
    @param parent_id Needed to set the parent of this object
    @param no_import If this flag is specified the location of the generated PDF will be returned, but the pdf will not be stored in the content repository
    @return item_id of the revision that contains the file
    @return file location of the file if "no_import" has been specified.
} {
    # This exec command is missing all the good things about openacs
    # Add the parameter to whatever package you put this procedure in.
    set oowriter_bin [parameter::get -parameter "OOWriterBin" -default "/opt/openoffice.org2.0/program/swriter"]

    set status [catch {exec -- /bin/sh [acs_package_root_dir contacts]/bin/convert.sh $oo_file } result]

    if { $status == 0 } {

        # The command succeeded, and wrote nothing to stderr.
        # $result contains what it wrote to stdout, unless you
        # redirected it

    } elseif { [string equal $::errorCode NONE] } {

        # The command exited with a normal status, but wrote something
        # to stderr, which is included in $result.

    } else {

        switch -exact -- [lindex $::errorCode 0] {

            CHILDKILLED {
                foreach { - pid sigName msg } $::errorCode break

                # A child process, whose process ID was $pid,
                # died on a signal named $sigName.  A human-
                # readable message appears in $msg.

            }

            CHILDSTATUS {

                foreach { - pid code } $::errorCode break

                # A child process, whose process ID was $pid,
                # exited with a non-zero exit status, $code.

            }

            CHILDSUSP {

                foreach { - pid sigName msg } $::errorCode break

                # A child process, whose process ID was $pid,
                # has been suspended because of a signal named
                # $sigName.  A human-readable description of the
                # signal appears in $msg.

            }

            POSIX {

                foreach { - errName msg } $::errorCode break

                # One of the kernel calls to launch the command
                # failed.  The error code is in $errName, and a
                # human-readable message is in $msg.

            }

        }
    }
    
    # Strip the extension.
    set pdf_filename "[file rootname $oo_file].pdf"
    set mime_type "application/pdf"
    if {![file exists $pdf_filename]} {
	###############
	# this is a fix to use the oo file if pdf file could not be generated
	###############
	set pdf_filename $oo_file
	set mime_type "application/odt"
    } else {
#	ns_unlink $oo_file
    }

    if {$no_import_p} {
	return [list $mime_type $pdf_filename]
    }

    set pdf_filesize [file size $pdf_filename]
    
    set file_name [file tail $pdf_filename]
    if {$title eq ""} {
	set title $file_name
    }
    
    if {[exists_and_not_null $item_id]} {
	set parent_id [get_parent -item_id $item_id]
	
	set revision_id [cr_import_content \
			     -title $title \
			     -item_id $item_id \
			     $parent_id \
			     $pdf_filename \
			     $pdf_filesize \
			     $mime_type \
			     $file_name ]
    } else {
	set revision_id [cr_import_content \
			     -title $title \
			     $parent_id \
			     $pdf_filename \
			     $pdf_filesize \
			     $mime_type \
			     $file_name ]
    }	

    ns_unlink $pdf_filename

    content::item::set_live_revision -revision_id $revision_id
    return [content::revision::item_id -revision_id $revision_id]
}

ad_proc -public contact::oo::change_content {
    -path:required
    -document_filename:required
    -contents:required
} {
    Takes the provided contents and places them in the content.xml file of the sxw file, effectivly changing the content of the file.

    @param path Path to the file containing the content
    @param document_filename The open-office file whose contents will be changed.
    @param contents This is a list of key-values (to be used as an array) of filenames and contents
                    to be replaced in the oo-file.
    @return The path to the new file.
} {
    # Create a temporary directory
    set dir [ns_tmpnam]
    ns_mkdir $dir

    array set content_array $contents
    foreach filename [array names content_array] {
	# Save the content to a file.
	set file [open "${dir}/$filename" w]
	fconfigure $file -encoding utf-8
	puts $file $content_array($filename)
	flush $file
	close $file
    }

    # copy the document
    ns_cp "${path}/$document_filename" "${dir}/$document_filename"

    # Replace old content in document with new content
    # The zip command should replace the content.xml in the zipfile which
    # happens to be the OpenOffice File. 
    foreach filename [array names content_array] {
	exec zip -j "${dir}/$document_filename" "${dir}/$filename"
    }

    # copy odt file
    set new_file "[ns_tmpnam].odt"
    ns_cp "${dir}/$document_filename" $new_file

    # delete other tmpfiles
    ns_unlink "${dir}/$document_filename"
    foreach filename [array names content_array] {
	ns_unlink "${dir}/$filename"
    }
    ns_rmdir $dir

    return $new_file
}

