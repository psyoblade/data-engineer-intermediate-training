#!/bin/bash

echo "docker run --name ex8 -u fluent -p 9880:9880 -p 9880:9880 -v `pwd`/fluent.conf:/fluentd/etc/fluent.conf -v `pwd`/source:/fluentd/source -v `pwd`/target:/fluentd/target -it psyoblade/fluentd-debian"
docker run --name ex8 -u fluent -p 9880:9880 -p 9881:9881 -v `pwd`/fluent.conf:/fluentd/etc/fluent.conf -v `pwd`/source:/fluentd/source -v `pwd`/target:/fluentd/target -it psyoblade/fluentd-debian

