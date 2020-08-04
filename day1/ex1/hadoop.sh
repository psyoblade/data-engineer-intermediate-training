#!/bin/bash
PROJECT_HOME=`pwd`
exists=`docker ps --filter name=sqoop | wc -l`

if [ $exists -ne 2 ]; then
    echo "스쿱 컨테이너를 찾을 수 없습니다. - $exists"
    exit 0
fi

args=$@

if [ x"$args" == x"" ]; then
    echo "./hadoop.sh fs -ls /tmp/sqoop/t1"
    echo "./hadoop.sh fs -cat /tmp/sqoop/t1/part-m-00000"
else
    echo "다음 명령을 수행합니다 - '$@'"
    docker exec -it sqoop hadoop $@
fi

