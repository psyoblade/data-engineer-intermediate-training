#!/bin/bash
name="multi-process"
container_name=`docker ps -a --filter name=$name | grep -v 'CONTAINER' | awk '{ print $1 }'`
docker rm -f $container_name
