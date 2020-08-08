#!/bin/bash
export PROJECT_HOME=`pwd`
name="multi-process-ex"
echo "docker run --name $name -u fluent -p 9880:9880 -v $PROJECT_HOME/fluent.conf:/fluentd/etc/fluent.conf -v $PROJECT_HOME/source:/fluentd/source -v $PROJECT_HOME/target:/fluentd/target -it psyoblade/fluentd-debian"
docker run --name $name -u fluent -p 9880:9880 -p 9881:9881 -v $PROJECT_HOME/fluent.conf:/fluentd/etc/fluent.conf -v $PROJECT_HOME/source:/fluentd/source -v $PROJECT_HOME/target:/fluentd/target -it psyoblade/fluentd-debian

