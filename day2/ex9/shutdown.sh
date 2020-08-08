#!/bin/bash

echo "export PROJECT_HOME=`pwd`"
export PROJECT_HOME=`pwd`

echo "docker-compose down $@"
docker-compose down $@
