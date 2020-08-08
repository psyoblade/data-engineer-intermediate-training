#!/bin/bash
if [ -z $PROJECT_HOME ]; then
    echo "\$PROJECT_HOME 이 지정되지 않았습니다"
    exit 1
fi

name="multi-process"
container_name=`docker ps -a --filter name=$name | grep -v 'CONTAINER' | awk '{ print $1 }'`
docker rm -f $container_name
