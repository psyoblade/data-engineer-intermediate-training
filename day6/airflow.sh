#!/bin/bash
if [ $# -eq 0 ]; then
    echo "$0 commands"
    echo "$0 list_dags"
    echo "$0 list_tasks <dag-name>"
    echo "$0 test <dag-name> <task-name> <execution-date>"
    exit 1
fi

docker exec -it day6_webserver_1 airflow $@
