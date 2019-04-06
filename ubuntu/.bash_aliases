# to use Ctrl-s
stty -ixon

# Ensure some directories exist.
if [ ! -d $HOME/.local/bin ]; then
	mkdir -p $HOME/.local/bin
fi

if [ ! -d $HOME/.local/share/man ]; then
	mkdir -p $HOME/.local/share/man
fi

if [ ! -d $HOME/.local/share/info ]; then
	mkdir -p $HOME/.local/share/info
fi

if [ ! -d $HOME/.local/lib ]; then
	mkdir -p $HOME/.local/lib
fi

if [ $(uname -m | grep 'x86_64' | wc -l) != 0 ]; then
	if [ ! -d $HOME/.local/lib64 ]; then
		mkdir -p $HOME/.local/lib64
	fi

	if [ ! -d $HOME/.local/lib32 ]; then
		mkdir -p $HOME/.local/lib32
	fi
fi

# Set some paths
if [[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
	PATH=$HOME/.local/bin:$PATH
	PATH=$(echo $PATH | sed -e 's/^:*//g' -e 's/:*$//g')
	export PATH
fi

if [[ ! ":$(manpath):" == *":$HOME/.local/share/man:"* ]]; then
	unset MANPATH
	MANPATH=$HOME/.local/share/man:$(manpath)
	MANPATH=$(echo $MANPATH | sed -e 's/^:*//g' -e 's/:*$//g')
	export MANPATH
fi

if [[ ! ":$INFOPATH:" == *":$HOME/.local/share/info:"* ]]; then
	INFOPATH=$HOME/.local/share/info:$INFOPATH
	INFOPATH=$(echo $INFOPATH | sed -e 's/^:*//g' -e 's/:*$//g')
	export INFOPATH
fi

unset LD_PATH_SCRATCH
if [[ ! ":$LD_LIBRARY_PATH:" == *":$HOME/.local/lib:"* ]]; then
	LD_PATH_SCRATCH=$LD_PATH_SCRATCH:$HOME/.local/lib
fi

if [ $(uname -m | grep 'x86_64' | wc -l) != 0 ]; then
	if [[ ! ":$LD_LIBRARY_PATH:" == *":$HOME/.local/lib64:"* ]]; then
		LD_PATH_SCRATCH=$LD_PATH_SCRATCH:$HOME/.local/lib64
	fi

	if [[ ! ":$LD_LIBRARY_PATH:" == *":$HOME/.local/lib32:"* ]]; then
		LD_PATH_SCRATCH=$LD_PATH_SCRATCH:$HOME/.local/lib32
	fi
fi

LD_PATH_SCRATCH=$(echo $LD_PATH_SCRATCH | sed -e 's/^:*//g' -e 's/:*$//g')
LD_LIBRARY_PATH=$LD_PATH_SCRATCH:$LD_LIBRARY_PATH
LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed -e 's/^:*//g' -e 's/:*$//g')
LD_RUN_PATH=$LD_PATH_SCRATCH:$LD_RUN_PATH
LD_RUN_PATH=$(echo $LD_RUN_PATH | sed -e 's/^:*//g' -e 's/:*$//g')
unset LD_PATH_SCRATCH
export LD_LIBRARY_PATH
export LD_RUN_PATH

# Aliases
# #######
# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask. For example, alias rm='rm -i' will mask the rm
# application. To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.
# Interactive operation...
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Default to human readable figures
alias df='df -h'
alias du='du -h'
alias ls='ls -hF --color=auto'

# astyle options
alias astyle='astyle --style=break --indent=force-tab=4 --unpad-paren --pad-header --pad-oper --unpad-paren --align-pointer=name --align-reference=name'

# axel options
alias axel='axel -a'

# wget options
alias wget='wget --retry-connrefused'

# mc options
#type -p -a mc > /dev/null && alias mc='. /usr/share/mc/bin/mc-wrapper.sh -a'
if type -p -a mc > /dev/null; then
	case "$TERM" in
		screen-256color)
			alias mc='TERM=screen . /usr/share/mc/bin/mc-wrapper.sh -a -x'
			;;
		*)
			alias mc='. /usr/share/mc/bin/mc-wrapper.sh -a'
			;;
	esac
fi

# vim settings
export EDITOR=vim
# Use vim to browse man pages. One can use Ctrl-] and Ctrl-t
# to browse and return from referenced man pages. ZZ or q to quit.
# Note initially within vim, one can goto the man page for the
# word under the cursor by using [section_number]K.
# Note we use bash explicitly here to support process substitution
# which in turn suppresses the "Vim: Reading from stdin..." warning.
export MANPAGER='/bin/bash -c "vim -MRn -c \"set ft=man\" </dev/tty <(col -b)"'

# force TERM environment to xterm-256color when we are in gnome-terminal
if [ $(ps -p $PPID o comm | grep gnome-terminal | wc -l) == 1 ]; then
	# we are in gnome-terminal.
	# gnome-terminal does not set TERM to xterm-256color
	export TERM=xterm-256color
else
	# we are not in gnome-terminal.
	:
fi

# set prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
	xterm*|rxvt*|screen*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
		;;
	*)
		;;
esac

case "$TERM" in
	xterm*|rxvt*)
		# Show the currently running command in the terminal title:
		# http://www.davidpashley.com/articles/xterm-titles-with-bash.html
		show_command_in_title_bar()
		{
			case "$BASH_COMMAND" in
				*\033]0*)
					# The command is trying to set the title bar as well;
					# this is most likely the execution of $PROMPT_COMMAND.
					# In any case nested escapes confuse the terminal, so don't
					# output them.
					;;
				*)
					echo -ne "\033]0;${USER}@${HOSTNAME}: ${BASH_COMMAND}\007"
					;;
			esac
		}
		trap show_command_in_title_bar DEBUG
		;;
	*)
		;;
esac

#  vim: set ft=sh ts=4 sw=4 tw=0 noet :
