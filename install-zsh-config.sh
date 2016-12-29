#!/bin/zsh

cp -f -v ./zsh/zshenv ~/.zshenv
mkdir -p -v ~/.zsh
cp -f -v ./zsh/zshrc ~/.zsh/.zshrc
mkdir -p -v ~/.zsh/.zkbd
cp -f -v ./zsh/zkbd/xterm-256color-pc-linux-gnu ~/.zsh/.zkbd/
cp -f -v ./zsh/zkbd/screen-256color-pc-linux-gnu ~/.zsh/.zkbd/
ln -sf ~/.zsh/.zkbd/xterm-256color-pc-linux-gnu ~/.zsh/.zkbd/xterm-256color-unknown-linux-gnu
ln -sf ~/.zsh/.zkbd/screen-256color-pc-linux-gnu ~/.zsh/.zkbd/screen-256color-unknown-linux-gnu

local CURRENT_SHELL="/bin/zsh"

if (( $+commands[dscl] )); then
	CURRENT_SHELL=$(dscl localhost -read /Local/Default/Users/$(id -un) UserShell | cut -d ' ' -f 2)
else
	CURRENT_SHELL=$(cat /etc/passwd | grep "^$(id -un)" | cut -d ':' -f 7)
fi

if [[ ${CURRENT_SHELL} != '/bin/zsh' ]]; then
	sudo chsh -s /bin/zsh $(id -un)
fi
