#!/bin/bash
cp -f -v ./ubuntu/.bash_aliases ~
cp -f -v ./ubuntu/.inputrc ~
cp -f -v ./ubuntu/.tmux.conf ~
cp -f -v ./ubuntu/.gitconfig ~
mkdir -p -v ~/.config/fontconfig
cp -f -v ./ubuntu/fonts.conf ~/.config/fontconfig/
sudo mkdir -p -v /root/.config/fontconfig
sudo cp -f -v ./ubuntu/fonts.conf /root/.config/fontconfig/
sudo chown -v root:root /root/.config/fontconfig/fonts.conf
sudo cp -f -v ./ubuntu/local.conf /etc/fonts/
sudo chown -v root:root /etc/fonts/local.conf
