#!/bin/bash

echo "docker rm `docker ps -a | grep ex8 | awk '{ print $1 }'`"
docker rm `docker ps -a | grep ex8 | awk '{ print $1 }'`
