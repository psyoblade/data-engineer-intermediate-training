#!/bin/bash
exists=`docker network ls --filter name=sqoop-mysql | wc -l`
if [ $exists -ne 2 ]; then
    docker network create sqoop-mysql
    docker network ls --filter name=sqoop-mysql
else
    echo "네트워크 sqoop-mysql 은 이미 존재합니다"
fi
