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
DISTRIB_RELEASE=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | cut -d '=' -f 2`
case $DISTRIB_RELEASE in
	"16.10")
		sudo cp -f -v ./ubuntu/preferences-16.10 /etc/apt/preferences
		;;
	*)
		sudo cp -f -v ./ubuntu/preferences /etc/apt/preferences
		;;
esac
sudo chown -v root:root /etc/apt/preferences
sudo cp -f -v ./ubuntu/local /etc/apt/apt.conf.d/local
sudo chown -v root:root /etc/apt/apt.conf.d/local
