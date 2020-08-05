#!/bin/bash
PROJECT_HOME=`pwd`
exists=`docker ps --filter name=sqoop | wc -l`

if [ $exists -ne 2 ]; then
    echo "스쿱 컨테이너를 찾을 수 없습니다. - $exists"
    exit 0
fi

args=$@

if [ x"$args" == x"" ]; then
    echo "./sqoop-eval.sh eval \"select * from users\""
else
    echo "다음 명령을 수행합니다 - '$@'"
    docker exec -it sqoop sqoop eval --connect jdbc:mysql://mysql:3306/testdb --username user --password pass -e "$@"
fi
