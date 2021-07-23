#!/bin/bash

echo "install docker"
curl -fsSL https://get.docker.com/ | sudo sh
sudo usermod -a -G docker $USER
sudo chmod 666 /var/run/docker.sock

echo "install docker-compose 1.27.4"
sudo rm /usr/local/bin/docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

docker --version
docker-compose --version
