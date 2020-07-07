#!/bin/bash
if [ ! -e $PROJECT_HOME ]; then
    echo "\$PROJECT_HOME 이 지정되지 않았습니다"
    exit 1
fi

# docker run --log-driver=fluentd ubuntu echo '{"message":"Hello Fluentd!!"}'
# docker run --log-driver=fluentd --log-opt tag=docker.helloworld --log-opt fluentd-address=192.168.128.3:24225 ubuntu echo '{"message":"Hello Fluentd!!"}'
# docker run --log-driver=fluentd --log-opt tag=docker.{{.ID}} ubuntu echo '{"message":"Hello Fluentd!!"}'
# docker run --log-driver=fluentd --log-opt tag=docker.{{.FullID}} ubuntu echo '{"message":"Hello Fluentd!!"}'
# docker run --log-driver=fluentd --log-opt tag=docker.{{.Name}} ubuntu echo '{"message":"Hello Fluentd!!"}'
docker run --log-driver=fluentd --log-opt tag=docker.helloworld --log-opt fluentd-address=192.168.128.3:24225 ubuntu echo '{"message":"Hello Fluentd!!"}'
