#! /usr/bin/env zsh

cp -f -v ./zsh/.zshenv ~/.zshenv
mkdir -p -v ~/.zsh
cp -f -v ./zsh/.zshrc ~/.zsh/.zshrc
mkdir -p -v ~/.zsh/.zkbd
cp -f -v ./zsh/.zkbd/xterm-256color-ubuntu-linux-gnu ~/.zsh/.zkbd/
cp -f -v ./zsh/.zkbd/screen-256color-ubuntu-linux-gnu ~/.zsh/.zkbd/
ln -s -f ~/.zsh/.zkbd/xterm-256color-ubuntu-linux-gnu ~/.zsh/.zkbd/xterm-256color-unknown-linux-gnu
ln -s -f ~/.zsh/.zkbd/screen-256color-ubuntu-linux-gnu ~/.zsh/.zkbd/screen-256color-unknown-linux-gnu
cp -f -v ./zsh/.zkbd/xterm-256color-pc-linux-gnu ~/.zsh/.zkbd/
cp -f -v ./zsh/.zkbd/screen-256color-pc-linux-gnu ~/.zsh/.zkbd/
cp -f -v ./zsh/.zkbd/xterm-256color-apple-darwin18.0 ~/.zsh/.zkbd/
cp -f -v ./zsh/.zkbd/screen-256color-apple-darwin18.0 ~/.zsh/.zkbd/

if (( $+commands[dscl] )); then
	CURRENT_SHELL=$(dscl localhost -read /Local/Default/Users/$(id -un) UserShell | cut -d ' ' -f 2)
else
	CURRENT_SHELL=$(cat /etc/passwd | grep "^$(id -un)" | cut -d ':' -f 7)
fi

if [[ ${CURRENT_SHELL:t} != 'zsh' ]]; then
	if [[ -a /etc/synoinfo.conf ]]; then
		cp -f -v ./zsh/.profile.synology ~/.profile
	else
		sudo chsh -s /bin/zsh $(id -un)
	fi
fi
