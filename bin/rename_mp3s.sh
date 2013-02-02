#!/bin/bash
for artist in *; do cd "$artist";
for album in *; do cd "$album"; 
for i in *.mp3; do num=`id3v2 --list "$i" | grep -e 'TR.*K' | cut -f 2 -d: | cut -f 1 -d/`; mv "$i" "`printf %02d $num` - $i"; done;
cd ..;
done;
cd ..;
done
