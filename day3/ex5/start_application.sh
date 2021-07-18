#!/bin/bash

# https://docs.docker.com/config/containers/logging/fluentd/ - By default, the logging driver connects to localhost:24224
docker run --rm --log-driver=fluentd ubuntu echo '{"message":"null tag message"}'
docker run --rm --log-driver=fluentd --log-opt tag=docker.{{.ID}} ubuntu echo '{"message":"send message with id"}'
docker run --rm --log-driver=fluentd --log-opt tag=docker.{{.Name}} ubuntu echo '{"message":"send message with name"}'
docker run --rm --log-driver=fluentd --log-opt tag=docker.{{.FullID}} ubuntu echo '{"message":"send message with full-id"}'

# in case of connect other container 
aggregator_address=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' aggregator`
docker run --rm --log-driver=fluentd --log-opt tag=docker.helloworld --log-opt fluentd-address=$aggregator_address:24224 ubuntu echo '{"message":"exact ip send message"}'
