#!/bin/bash
docker volume rm mysql_default
docker run --name mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -e MYSQL_DATABASE=testdb -e MYSQL_USER=user -e MYSQL_PASSWORD=pass -v mysql_default:/var/lib/mysql -d mysql
docker ps --filter name=mysql
