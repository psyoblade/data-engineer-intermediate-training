#!/bin/bash
cp .vimrc $HOME/
cp .screenrc $HOME/
sudo apt install tree
echo "\nalias d=\"docker-compose\"" >> ~/.bashrc
echo "\nexport EDITOR=\"vim\"" >> ~/.bashrc
