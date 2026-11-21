#! /bin/bash

source ./lib/install-output.sh || exit

copy_config_file ./common/.gitconfig ~/.gitconfig
copy_config_file ./common/.wgetrc ~/.wgetrc
copy_config_file ./common/.curlrc ~/.curlrc
copy_config_file ./synology/.tmux.conf ~/.tmux.conf
