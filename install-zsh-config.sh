#!/bin/zsh
cp -f -v ./zsh/zshenv ~/.zshenv
mkdir -p -v ~/.zsh
cp -f -v ./zsh/zshrc ~/.zsh/.zshrc
if [[ $(cat /etc/passwd | grep "^$USER" | awk -F ':' '{ print $7 }') != '/bin/zsh' ]]; then
	sudo chsh --shell /bin/zsh wonmin82
fi
