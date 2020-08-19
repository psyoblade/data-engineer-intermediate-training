#!/bin/bash
export PROJECT_HOME=`pwd`
name="multi-process"
echo "docker run --name $name -u root -p 9880:9880 -v $PROJECT_HOME/fluent.conf:/fluentd/etc/fluent.conf -v $PROJECT_HOME/source:/fluentd/source -v $PROJECT_HOME/target:/fluentd/target -it psyoblade/data-engineer-intermediate-day2-fluentd"
docker run --name $name -u root -p 9880:9880 -v $PROJECT_HOME/fluent.conf:/fluentd/etc/fluent.conf -v $PROJECT_HOME/source:/fluentd/source -v $PROJECT_HOME/target:/fluentd/target -it psyoblade/data-engineer-intermediate-day2-fluentd
