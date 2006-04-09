#!/bin/bash

# Set the display variable to the home of the user who has write access to the X11 server
# which is running on the display port. This could either be VNC or something else.

export HOME=/home/<yourserver>
/etc/openoffice.org-2.0/program/soffice.bin -writer -headless -pt pdfconv $1 -display <systemname>:1.0