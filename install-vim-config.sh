#! /usr/bin/env bash

mkdir -p $HOME/.vim
cp -f -v $PWD/vim/.vimrc $HOME/.vimrc
cp -f -v $PWD/vim/.vimrc.local $HOME/.vimrc.local
cp -f -v $PWD/vim/.ycm_extra_conf.py $HOME/.vim/.ycm_extra_conf.py
