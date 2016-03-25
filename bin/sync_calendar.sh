#!/bin/bash

docker run -ti -v /tmp:/mnt/output -e USERNAME=${EWS_USERNAME} -e PASSWORD=${EWS_PASSWORD} madhatter/davmail
scp /tmp/calendar.ics madhatter@nostalgix.org:/var/customers/webs/arvid/share/
