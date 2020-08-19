#!/bin/bash
curl -fsSL https://get.docker.com/ | sudo sh
sudo usermod -a -G docker $USER
sudo chmod 666 /var/run/docker.sock
sudo apt install docker-compose

docker --version
docker-compose --version
