#!/bin/bash

if [ $# -ne 1 ]; then
    echo "./aggregator.sh 2 or 3"
    exit 1
fi
no=$1
docker run --name "aggregator$no" --network=mynet -p 2422$no:24224 -v `pwd`/aggregator.conf:/fluentd/etc/fluent.conf -it fluent/fluentd
