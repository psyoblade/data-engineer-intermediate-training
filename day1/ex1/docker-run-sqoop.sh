#!/bin/bash
PROJECT_HOME=`pwd`
echo $PROJECT_HOME

docker rm sqoop
docker run --name sqoop --network sqoop-mysql -v $PROJECT_HOME/jars:/jdbc -dit psyoblade/data-engineer-intermediate-day1-sqoop
docker ps --filter name=sqoop
