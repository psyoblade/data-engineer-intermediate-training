#!/bin/bash
PROJECT_HOME=`pwd`
docker stop mysql
docker rm mysql
docker run --name mysql --network sqoop-mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -e MYSQL_DATABASE=testdb -e MYSQL_USER=user -e MYSQL_PASSWORD=pass -v $PROJECT_HOME/etc:/etc/mysql/conf.d -v mysql_default:/var/lib/mysql -d psyoblade/data-engineer-intermediate-day1-mysql
docker ps --filter name=mysql
