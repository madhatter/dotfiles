#!/bin/bash

docker run -ti -v /tmp:/mnt/output -e USERNAME=${EWS_USERNAME} -e PASSWORD=${EWS_PASSWORD} madhatter/davmail
scp /tmp/calendar.ics madhatter@brutal.nostalgix.org:/var/www/share/
