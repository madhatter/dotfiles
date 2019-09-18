#!/bin/bash

IMAGE_NAME=$1

echo "All images will be deleted."

docker images | grep "^${IMAGE_NAME}" | awk '{print $2}'

read -p "Continue? (y/n) " conti

if [ $conti == 'y' ]; then
	docker rmi -f $(docker images | grep "^${IMAGE_NAME}" | awk '{print $3}')
else
	echo "Ok."
fi

