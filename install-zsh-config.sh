#!/bin/zsh
cp -f -v ./zsh/zshenv ~/.zshenv
mkdir -p -v ~/.zsh
cp -f -v ./zsh/zshrc ~/.zsh/.zshrc
mkdir -p -v ~/.zsh/.zkbd
cp -f -v ./zsh/zkbd/xterm-256color-pc-linux-gnu ~/.zsh/.zkbd/
cp -f -v ./zsh/zkbd/screen-256color-pc-linux-gnu ~/.zsh/.zkbd/
ln -sf ~/.zsh/.zkbd/xterm-256color-pc-linux-gnu ~/.zsh/.zkbd/xterm-256color-unknown-linux-gnu
ln -sf ~/.zsh/.zkbd/screen-256color-pc-linux-gnu ~/.zsh/.zkbd/screen-256color-unknown-linux-gnu
if [[ $(cat /etc/passwd | grep "^$USER" | awk -F ':' '{ print $7 }') != '/bin/zsh' ]]; then
	sudo chsh -s /bin/zsh ${USER}
fi
