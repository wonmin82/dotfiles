#!/bin/bash
cp -f -v ./ubuntu/bash_aliases ~/.bash_aliases
cp -f -v ./ubuntu/inputrc ~/.inputrc
cp -f -v ./ubuntu/tmux.conf ~/.tmux.conf
cp -f -v ./ubuntu/gitconfig ~/.gitconfig
cp -f -v ./ubuntu/wgetrc ~/.wgetrc
cp -f -v ./ubuntu/curlrc ~/.curlrc
mkdir -p -v ~/.config/fontconfig
cp -f -v ./ubuntu/fonts.conf ~/.config/fontconfig/
sudo mkdir -p -v /root/.config/fontconfig
sudo cp -f -v ./ubuntu/fonts.conf /root/.config/fontconfig/
sudo chown -v root:root /root/.config/fontconfig/fonts.conf
sudo mkdir -p -v /etc/fonts
sudo cp -f -v ./ubuntu/local.conf /etc/fonts/
sudo chown -v root:root /etc/fonts/local.conf
