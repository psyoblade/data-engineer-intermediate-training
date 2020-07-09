#!/bin/bash

echo "docker rm `docker ps -a | grep ex7 | awk '{ print $1 }'`"
docker rm `docker ps -a | grep ex7 | awk '{ print $1 }'`
