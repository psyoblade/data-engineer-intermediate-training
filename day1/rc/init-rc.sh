#!/bin/bash
cp .vimrc $HOME/
cp .screenrc $HOME/
sudo apt install tree
echo "alias d=\"docker-compose\"" >> ~/.bashrc
echo "export EDITOR=\"vim\"" >> ~/.bashrc
