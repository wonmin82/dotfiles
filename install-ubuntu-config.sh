#! /usr/bin/env bash

cp -f -v $PWD/ubuntu/.bash_aliases $HOME/.bash_aliases
cp -f -v $PWD/ubuntu/.inputrc $HOME/.inputrc
cp -f -v $PWD/ubuntu/.tmux.conf $HOME/.tmux.conf
cp -f -v $PWD/ubuntu/.gitconfig $HOME/.gitconfig
cp -f -v $PWD/ubuntu/.wgetrc $HOME/.wgetrc
cp -f -v $PWD/ubuntu/.curlrc $HOME/.curlrc
mkdir -p -v $HOME/.config/pip
cp -f -v $PWD/ubuntu/pip.conf $HOME/.config/pip/pip.conf
sudo mkdir -p -v /root/.config/pip
sudo cp -f -v $PWD/ubuntu/pip.conf /root/.config/pip/pip.conf
mkdir -p -v $HOME/.config/fontconfig
cp -f -v $PWD/ubuntu/fonts.conf $HOME/.config/fontconfig/fonts.conf
sudo mkdir -p -v /root/.config/fontconfig
sudo cp -f -v $PWD/ubuntu/fonts.conf /root/.config/fontconfig/fonts.conf
sudo chown -v root:root /root/.config/fontconfig/fonts.conf
sudo mkdir -p -v /etc/fonts
sudo cp -f -v $PWD/ubuntu/local.conf /etc/fonts/local.conf
sudo chown -v root:root /etc/fonts/local.conf
sudo cp -f -v $PWD/ubuntu/preferences /etc/apt/preferences
sudo chown -v root:root /etc/apt/preferences
sudo cp -f -v $PWD/ubuntu/99dpkg-options /etc/apt/apt.conf.d/99dpkg-options
sudo chown -v root:root /etc/apt/apt.conf.d/99dpkg-options
