#!/bin/bash
PROJECT_HOME=`pwd`
echo $PROJECT_HOME

PORTS="-p 8020:8020 -p 8088:8088 -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 19888:19888"

docker stop sqoop
docker rm sqoop
docker run --name sqoop --network sqoop-mysql $PORTS -v $PROJECT_HOME/jars:/jdbc -dit psyoblade/data-engineer-intermediate-day1-sqoop
docker ps --filter name=sqoop
