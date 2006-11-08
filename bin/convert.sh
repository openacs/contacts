#!/bin/bash

# This script takes to input variables of which one is optional.
# This is the input file (usually an .odt) and the resulting .pdf filename

# Set the display variable to the home of the user who has write access to the X11 server
# which is running on the display port. This could either be VNC or something else.

export HOME=/home/malte
#/usr/bin/openoffice -writer -headless -pt pdfconv $1 -display lektor2:1.0

# If you are going to use jooconverter
/usr/bin/java -jar /usr/bin/jooconverter/jooconverter-2.1rc2/jooconverter-2.1rc2.jar $1 $2
#/etc/openoffice.org-2.0/program/soffice.bin -writer -headless -pt pdfconv $1 -display lektor:1.0