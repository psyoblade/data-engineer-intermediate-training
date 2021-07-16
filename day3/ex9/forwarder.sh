#!/bin/bash

if [ $# -ne 1 ]; then
    echo "./forwarder.sh 0 or 1"
    exit 1
fi

no=$1
docker run --name "forwarder$no" --network=mynet -p 988$no:9880 -p 2422$no:24224 -v `pwd`/forwarder.conf:/fluentd/etc/fluent.conf -it fluent/fluentd
