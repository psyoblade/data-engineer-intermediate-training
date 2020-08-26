#!/bin/bash
if [ $# -eq 0 ]; then
    echo "$0 <commands>"
    echo "$0 initdb  : 에어플로우 데이터베이스 초기화 - 반드시 처음에 수행되어야 합니다"
    echo "$0 list_dags"
    echo "$0 list_tasks <dag-name>"
    echo "$0 test <dag-name> <task-name> <execution-date>"
    exit 1
fi

docker exec -it day6_webserver_1 airflow $@
