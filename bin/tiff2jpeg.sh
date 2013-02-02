#!/bin/bash
 
for i in *.tif
do
  echo converting $i to ./jpeg/$(basename $i .tif).jpg
    convert $i ./jpeg/$(basename $i .tif).jpg
	#exit 0
done
