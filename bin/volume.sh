#!/bin/bash
vol=`amixer get PCM | grep "Front Left:" | awk '{print $5}' | tr -d '[]'`
echo $vol
