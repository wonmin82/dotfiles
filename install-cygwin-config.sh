#!/bin/bash
source ./lib/install-output.sh || exit

copy_config_file ./cygwin/.bash_profile ~/.bash_profile
copy_config_file ./cygwin/.bashrc ~/.bashrc
copy_config_file ./cygwin/.inputrc ~/.inputrc
copy_config_file ./cygwin/.startxwinrc ~/.startxwinrc
copy_config_file ./cygwin/.minttyrc ~/.minttyrc
copy_config_file ./cygwin/.gitconfig ~/.gitconfig
copy_config_file ./cygwin/.tmux.conf ~/.tmux.conf
