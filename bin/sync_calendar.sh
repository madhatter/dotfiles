#!/bin/bash

#echo "${EWS_USERNAME} ${EWS_PASSWORD}"
#docker run -ti -v /tmp:/mnt/output -e USERNAME=${EWS_USERNAME} -e PASSWORD=${EWS_PASSWORD} -p 1080:1080 madhatter/davmail-new
~/dev/davmail/scripts/pull-calendar.sh
scp /tmp/calendar.ics madhatter@brutal.nostalgix.org:/var/www/share/
