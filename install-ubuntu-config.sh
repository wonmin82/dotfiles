#! /usr/bin/env bash

flag_system=false

while [[ $# -gt 0 ]]
do
	case $1 in
		-s|--system)
			flag_system=true
			shift
			;;
		*)
			echo "Unknown option."
			exit 1
	esac
done

cp -f -v $PWD/ubuntu/.bash_aliases $HOME/.bash_aliases
cp -f -v $PWD/ubuntu/.inputrc $HOME/.inputrc
cp -f -v $PWD/ubuntu/.tmux.conf $HOME/.tmux.conf
cp -f -v $PWD/ubuntu/.gitconfig $HOME/.gitconfig
cp -f -v $PWD/ubuntu/.wgetrc $HOME/.wgetrc
cp -f -v $PWD/ubuntu/.curlrc $HOME/.curlrc
mkdir -p -v $HOME/.config/pip
cp -f -v $PWD/ubuntu/pip.conf $HOME/.config/pip/
mkdir -p -v $HOME/.config/fontconfig
cp -f -v $PWD/ubuntu/fonts.conf $HOME/.config/fontconfig/

if [[ $flag_system == false ]]; then
	exit 0
fi
sudo mkdir -p -v /root/.config/pip
sudo cp -f -v $PWD/ubuntu/pip.conf /root/.config/pip/
sudo chown -v root:root /root/.config/pip/pip.conf
sudo mkdir -p -v /root/.config/fontconfig
sudo cp -f -v $PWD/ubuntu/fonts.conf /root/.config/fontconfig/
sudo chown -v root:root /root/.config/fontconfig/fonts.conf

sudo mkdir -p -v /etc/fonts
sudo cp -f -v $PWD/ubuntu/local.conf /etc/fonts/
sudo chown -v root:root /etc/fonts/local.conf

sudo mkdir -p -v /etc/apt/preferences.d
sudo cp -f -v $PWD/ubuntu/preferences.d/nodejs /etc/apt/preferences.d/
sudo cp -f -v $PWD/ubuntu/preferences.d/runit /etc/apt/preferences.d/
sudo cp -f -v $PWD/ubuntu/preferences.d/docker /etc/apt/preferences.d/
sudo chown -v root:root                     \
		 /etc/apt/preferences.d/nodejs      \
		 /etc/apt/preferences.d/runit       \
		 /etc/apt/preferences.d/docker

sudo mkdir -p -v /etc/apt/apt.conf.d
sudo cp -f -v $PWD/ubuntu/apt.conf.d/99dpkg-options /etc/apt/apt.conf.d/
sudo chown -v root:root /etc/apt/apt.conf.d/99dpkg-options
