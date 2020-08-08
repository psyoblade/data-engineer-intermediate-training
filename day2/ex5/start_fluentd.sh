#!/bin/bash
if [ -z $PROJECT_HOME ]; then
    echo "\$PROJECT_HOME 이 지정되지 않았습니다"
    exit 1
fi
docker run --name aggregator -it -p 24224:24224 -v $PROJECT_HOME/aggregator.conf:/fluentd/etc/fluent.conf fluent/fluentd
