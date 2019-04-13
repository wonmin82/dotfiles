#*****************************************
#*                                       *
#*                .zshrc                 *
#*                                       *
#*            by Wonmin Jung             *
#*          wonmin82@gmail.com           *
#*      https://github.com/wonmin82      *
#*                                       *
#*****************************************

# Functions for internal use {{{
# function: __determine_sysenv
function __determine_sysenv()
{
	_SYSENV_OS=${$(uname):l}
	_SYSENV_KERNEL=$(uname -r)
	_SYSENV_MACH=$(uname -m)

	if [[ "${_SYSENV_OS}" == "windowsnt" ]]; then
		_SYSENV_OS=windows
	elif [[ "${_SYSENV_OS}" == "darwin" ]]; then
		_SYSENV_OS=macos
	elif [[ "${_SYSENV_OS}" =~ "^cygwin" ]]; then
		_SYSENV_OS=cygwin
	else
		_SYSENV_OS=$(uname)
		if [[ "${_SYSENV_OS}" == "SunOS" ]]; then
			_SYSENV_OS=Solaris
			_SYSENV_ARCH=$(uname -p)
			_SYSENV_OSSTR="${_SYSENV_OS} ${_SYSENV_REV}(${_SYSENV_ARCH} $(uname -v))"
		elif [[ "${_SYSENV_OS}" == "AIX" ]]; then
			_SYSENV_OSSTR="${_SYSENV_OS} $(oslevel) ($(oslevel -r))"
		elif [[ "${_SYSENV_OS}" == "Linux" ]]; then
			if [[ -f /etc/redhat-release ]]; then
				_SYSENV_DISTROBASEDON='RedHat'
				_SYSENV_DIST=$(cat /etc/redhat-release | sed s/\ release.*//)
				_SYSENV_PSEUDONAME=$(cat /etc/redhat-release | sed s/.*\(// | sed s/\)//)
				_SYSENV_REV=$(cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//)
			elif [[ -f /etc/SuSE-release ]]; then
				_SYSENV_DISTROBASEDON='SuSe'
				_SYSENV_PSEUDONAME=$(cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//)
				_SYSENV_REV=$(cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //)
			elif [[ -f /etc/mandrake-release ]]; then
				_SYSENV_DISTROBASEDON='Mandrake'
				_SYSENV_PSEUDONAME=$(cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//)
				_SYSENV_REV=$(cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//)
			elif [[ -f /etc/debian_version ]]; then
				_SYSENV_DISTROBASEDON='Debian'
				if [[ -f /etc/lsb-release ]]; then
					_SYSENV_DIST=$(cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F= '{ print $2 }')
					_SYSENV_PSEUDONAME=$(cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F= '{ print $2 }')
					_SYSENV_REV=$(cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F= '{ print $2 }')
				fi
			elif [[ -f /etc/synoinfo.conf ]]; then
				_SYSENV_DIST="SynologyDSM"
			fi
			if [[ -f /etc/UnitedLinux-release ]]; then
				_SYSENV_DIST="${_SYSENV_DIST}[$(cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//)]"
			fi
			_SYSENV_OS=${_SYSENV_OS:l}
			_SYSENV_DIST=${_SYSENV_DIST:l}
			_SYSENV_DISTROBASEDON=${_SYSENV_DISTROBASEDON:l}
		fi
	fi
}
#}}}

# Determine system environment {{{
# call __determine_sysenv function if _SYSENV_OS is not read-only.
(unset _SYSENV_OS 2> /dev/null) && __determine_sysenv
readonly _SYSENV_OS _SYSENV_OSSTR _SYSENV_DIST _SYSENV_DISTROBASEDON \
	SYSENV_PSEUDONAME _SYSENV_REV _SYSENV_KERNEL _SYSENV_MACH
#}}}

# TERM variable {{{
# force TERM environment to xterm-256color when we are in gnome-terminal
if [[ ${_SYSENV_DIST} == "ubuntu" ]]; then
	if [[ $(ps -p $PPID o comm | grep gnome-terminal | wc -l) == 1 ]]; then
		# we are in gnome-terminal.
		# gnome-terminal does not set TERM to xterm-256color
		export TERM=xterm-256color
	else
		# we are not in gnome-terminal.
		:
	fi
fi

# if you want to force TERM to xterm-256color
#export TERM=xterm-256color
#}}}

# Variables for tmux bundle {{{
ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOSTART_ONCE=false
ZSH_TMUX_AUTOCONNECT=false
ZSH_TMUX_AUTOQUIT=false
ZSH_TMUX_FIXTERM=true
#}}}

# Antigen bundle configurations {{{
# Ensure $ZSHDATADIR exists.
__ensure_dir_exists $ZSHDATADIR

__ensure_dir_exists $ANTIGENDIR
if [[ ! -f $ANTIGENDIR/antigen.zsh ]]; then
	git clone https://github.com/zsh-users/antigen.git $ANTIGENDIR
fi

source $ANTIGENDIR/antigen.zsh

antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle gitignore
if (( $+commands[tmux] )); then
	antigen bundle tmux
	if [[ ${_SYSENV_OS} != "cygwin" ]]; then
		antigen bundle thewtex/tmux-mem-cpu-load
	fi
fi
antigen bundle screen

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

if [[ ${_SYSENV_OS} != "cygwin" ]]; then
	antigen bundle zsh-users/zsh-autosuggestions
fi

if [[ ${_SYSENV_DIST} == "ubuntu" ]]; then
	antigen bundle sudo
	# Workaround for issue described in following link.
	# https://bugs.launchpad.net/ubuntu/+source/command-not-found/+bug/1766068
	# TODO: Should be removed when the issue is resolved. {{{
	if [[ $ZSH_VERSION == 5.<3->* || $ZSH_VERSION == <6->* ]]; then
		if [[ -s /etc/zsh_command_not_found ]]; then
			function command_not_found_handler {
				[[ -x /usr/lib/command-not-found ]] || return 1
				/usr/lib/command-not-found -- ${1+"$1"} && :
			}
		fi
	fi
	#}}}
	antigen bundle command-not-found
	antigen bundle debian
	if (( $+commands[docker] )); then
		antigen bundle docker
	fi
fi

if [[ ${_SYSENV_OS} == "macos" ]]; then
	antigen bundle sudo
	antigen bundle osx
	antigen bundle brew
	antigen bundle brew-cask
	antigen bundle gnu-utils
fi

# more LS_COLORS
# only available for 256 color terminals
zmodload zsh/terminfo || return 1
if (( $+terminfo[colors] )) && (( $terminfo[colors] == 256 )); then
	antigen bundle trapd00r/LS_COLORS
fi

# Load the theme.
if [[ ${_SYSENV_OS} == "cygwin" ]]; then
	antigen theme risto
elif [[ ${_SYSENV_DIST} == "synologydsm" ]]; then
	antigen theme risto
else
	export LP_ENABLE_TEMP="0"
	export LP_ENABLE_SHORTEN_PATH="1"
	export LP_PATH_LENGTH="35"
	antigen bundle nojhan/liquidprompt
fi

# Tell antigen that you're done.
antigen apply
#}}}

# LS_COLORS configuration {{{
# only available for 256 color terminals
if (( $+terminfo[colors] )) && (( $terminfo[colors] == 256 )); then
	# load trapd00r's LS_COLORS things
	if (( $+commands[dircolors] )); then
		eval $( dircolors -b $ADOTDIR/bundles/trapd00r/LS_COLORS/LS_COLORS )
	elif (( $+commands[gdircolors] )); then
		eval $( gdircolors -b $ADOTDIR/bundles/trapd00r/LS_COLORS/LS_COLORS )
	fi
fi
#}}}

# zsh-autosugesstions configuration {{{
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
ZSH_AUTOSUGGEST_STRATEGY="history"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
#}}}

# Autocompletion configuration {{{
# borrowed from https://github.com/Valodim/zshrc
setopt no_menu_complete
setopt auto_menu complete_in_word always_to_end

zmodload -i zsh/complist

# already done in antigen-apply()
# autoload -U compinit
# compinit -i

# completion stuff
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$ZSHDATADIR"

zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' menu select=1 _complete _ignored _approximate
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# Completion Styles

# list of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

# allow one error for every three characters typed in approximate completer
zstyle ':completion:*:approximate:*' max-errors 3

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d --\e[0m'
zstyle ':completion:*:messages' format $'\e[01;35m -- %d --\e[0m'
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found --\e[0m'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' auto-description '%d'

# match uppercase from lowercase, and left-side substrings
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' '+l:|=*'

#case-insensitive -> partial-word (cs) -> substring completion:
#zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# matcher-list
zstyle ':completion:*' matcher-list     \
	'm:{A-Zöäüa-zÖÄÜ}={a-zÖÄÜA-Zöäü}'   \
	'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

 # command completion: highlight matching part of command, and
zstyle -e ':completion:*:-command-:*:commands' list-colors 'reply=( '\''=(#b)('\''$words[CURRENT]'\''|)*-- #(*)=0=38;5;45=38;5;136'\'' '\''=(#b)('\''$words[CURRENT]'\''|)*=0=38;5;45'\'' )'

# This is needed to workaround a bug in _setup:12, causing almost 2 seconds delay for bigger LS_COLORS
# UPDATE: not sure if this is required anymore, with the -command- style above.. keeping it here just to be sure
zstyle ':completion:*:*:-command-:*' list-colors ''

# use LS_COLORS for file coloring
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# generic, highlight matched part
# WACKY behavior with zstyle precedence, not using this for now!
# zstyle -e ':completion:*' list-colors '[[ -z $words[CURRENT] ]] && return 1; reply=( '\''=(#b)('\''$words[CURRENT]'\'')*=0=38;5;45'\'' )'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# show command short descriptions, too
zstyle ':completion:*' extra-verbose yes

# make them a little less short, after all (mostly adds -l option to the whatis calll)
zstyle ':completion:*:command-descriptions' command '_call_whatis -l -s 1 -r .\*; _call_whatis -l -s 6 -r .\* 2>/dev/null'

# x11 colors
zstyle ":completion:*:colors" path '/etc/X11/rgb.txt'

# for sudo kill, show all processes except childs of kthreadd (ie, kernel
# threads), which is assumed to be PID 2. otherwise, show user processes only.
zstyle -e ':completion:*:*:kill:*:processes' command '[[ $BUFFER == sudo* ]] && reply=( "ps --forest -p 2 --ppid 2 --deselect -o pid,user,cmd" ) || reply=( ps x --forest -o pid,cmd )'
zstyle ':completion:*:processes-names' command 'ps axho command'

## add colors to processes for kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:*:users' ignored-patterns \
	adm apache bin daemon games gdm halt ident junkbust lp mail mailnull \
	named news nfsnobody nobody nscd ntp operator pcap postgres radvd \
	rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs avahi-autoipd\
	avahi backup messagebus beagleindex debian-tor dhcp dnsmasq fetchmail\
	firebird gnats haldaemon hplip irc klog list man cupsys postfix\
	proxy syslog www-data mldonkey sys snort

zstyle ':completion:*:*:cs:*' file-patterns \
	'*(-/):directories'

zstyle ':completion:*:*:evince(syn|):*' file-patterns \
	'*.(pdf|PDF):pdf\ files *(-/):directories'

zstyle ':completion:*:*:vi(m|):*:*files' ignored-patterns \
	'*?.(aux|dvi|ps|pdf|bbl|toc|lot|lof|o|cm|class?)'

zle -C complete-history complete-word _generic
zstyle ':completion:complete-history:*' completer _history

# not really a good idea after all :|
# zstyle ':complete-recent-args' use-histbang yes

() {
	local -a coreutils
	coreutils=(
		# /bin
		cat chgrp chmod chown cp date dd df dir ln ls mkdir mknod mv readlink
		rm rmdir vdir sleep stty sync touch uname mktemp
		# /usr/bin
		install hostid nice who users pinky stdbuf base64 basename chcon cksum
		comm csplit cut dircolors dirname du env expand factor fmt fold groups
		head id join link logname md5sum mkfifo nl nproc nohup od paste pathchk
		pr printenv ptx runcon seq sha1sum sha224sum sha256sum sha384sum
		sha512sum shred shuf sort split stat sum tac tail tee timeout tr
		truncate tsort tty unexpand uniq unlink wc whoami yes arch touch
	)
	for i in $coreutils; do
		# all which don't already have one
		# at time of this writing, those are:
		# /bin
		# chgrp chmod chown cp date dd df ln ls mkdir rm rmdir stty sync
		# touch uname
		# /usr/bin
		# nice comm cut du env groups id join logname md5sum nohup printenv
		# sort stat unexpand uniq whoami
		(( $+_comps[$i] )) || compdef _gnu_generic $i
	done
}
#}}}

# Highlight style {{{
# variables for zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=$ADOTDIR/bundles/zsh-users/zsh-syntax-highlighting/highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_MAXLENGTH=300

if (( $+terminfo[colors] )) && (( $terminfo[colors] == 256 )); then
	typeset -A ZSH_HIGHLIGHT_STYLES
	: ${ZSH_HIGHLIGHT_STYLES[default]:=none}
	: ${ZSH_HIGHLIGHT_STYLES[unknown-token]:=fg=red,bold}
	: ${ZSH_HIGHLIGHT_STYLES[reserved-word]:=fg=yellow}
	: ${ZSH_HIGHLIGHT_STYLES[alias]:=fg=226}
	: ${ZSH_HIGHLIGHT_STYLES[builtin]:=fg=141}
	: ${ZSH_HIGHLIGHT_STYLES[function]:=fg=214}
	: ${ZSH_HIGHLIGHT_STYLES[command]:=fg=118}
	: ${ZSH_HIGHLIGHT_STYLES[hashed-command]:=fg=119}
	: ${ZSH_HIGHLIGHT_STYLES[path]:=underline}
	: ${ZSH_HIGHLIGHT_STYLES[globbing]:=fg=105}
	: ${ZSH_HIGHLIGHT_STYLES[history-expansion]:=fg=63}
	: ${ZSH_HIGHLIGHT_STYLES[single-hyphen-option]:=239}
	: ${ZSH_HIGHLIGHT_STYLES[double-hyphen-option]:=241}
	: ${ZSH_HIGHLIGHT_STYLES[back-quoted-argument]:=none}
	: ${ZSH_HIGHLIGHT_STYLES[single-quoted-argument]:=fg=yellow}
	: ${ZSH_HIGHLIGHT_STYLES[double-quoted-argument]:=fg=yellow}
	: ${ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]:=fg=cyan}
	: ${ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]:=fg=cyan}
	: ${ZSH_HIGHLIGHT_STYLES[assign]:=none}

	: ${ZSH_HIGHLIGHT_STYLES[precommand]:=fg=227}
	: ${ZSH_HIGHLIGHT_STYLES[commandseparator]:=none}

	# and zle's very own zle_highlight
	zle_highlight=(
		region:underline
		isearch:underline
		special:bold
		suffix:fg=76
	)
fi
#}}}

# Keyboard configurations {{{
# to use Ctrl-s
setopt noflowcontrol
stty -ixon

autoload zkbd

# read zkbd key codes
if [[ -f $ZDOTDIR/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE} ]]; then
	source $ZDOTDIR/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE}
fi

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
	function zle-line-init ()
	{
		printf '%s' "${terminfo[smkx]}"
	}
	function zle-line-finish ()
	{
		printf '%s' "${terminfo[rmkx]}"
	}
	zle -N zle-line-init
	zle -N zle-line-finish
fi

# fancy-ctrl-z: from http://superuser.com/a/161922/35223
fancy-ctrl-z () {
	if [[ $#BUFFER -eq 0 ]]; then
		bg
		zle redisplay
	else
		zle push-input
	fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z
#}}}

# Options {{{
setopt auto_cd
setopt auto_pushd pushd_ignore_dups
setopt pushd_to_home pushd_minus pushd_silent

setopt auto_list
setopt list_packed
setopt list_types

setopt rc_quotes
setopt interactive_comments
setopt no_clobber
setopt rm_star_silent

setopt extended_glob
setopt numeric_glob_sort
setopt magic_equal_subst

setopt auto_continue
setopt auto_resume
setopt bg_nice
setopt long_list_jobs
setopt notify
setopt check_jobs
setopt hup

setopt no_auto_param_slash
setopt no_beep
setopt no_hist_beep
setopt no_list_beep
#}}}

# History options {{{
# history file location set in .zshenv
export HISTSIZE=10000
export SAVEHIST=10000

export HISTCONTROL=erasedups

setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt no_hist_ignore_space

setopt append_history
setopt inc_append_history

setopt hist_reduce_blanks
setopt hist_verify
setopt share_history
setopt bang_hist
setopt extended_history

# Variables {{{
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

LOGCHECK=60
WATCHFMT="[%B%t%b] %B%n%b has %a %B%l%b from %B%M%b"

# grep color setting
export GREP_COLOR='1;31'

# Use vim to browse man pages. One can use Ctrl-] and Ctrl-t
# to browse and return from referenced man pages. ZZ or q to quit.
# Note initially within vim, one can goto the man page for the
# word under the cursor by using [section_number]K.
# Note we use bash explicitly here to support process substitution
# which in turn suppresses the "Vim: Reading from stdin..." warning.
#export MANPAGER='/bin/bash -c "vim -MRn -c \"set ft=man\" </dev/tty <(col -b)"'

# MANPAGER configuration for newer version of vim.
export MANPAGER="vim --not-a-term -M +MANPAGER -"
# If your vim doesn't support --not-a-term option.
#export MANPAGER="vim -M +MANPAGER -"

# less configuration
export LESS="-FRXK"

# coloring in less, for manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# python configurations
export PIP_CONFIG_FILE="$HOME/.config/pip/pip.conf"
export VIRTUALENV_PYTHON="$(command which python3)"
export VIRTUALENVWRAPPER_PYTHON="$(command which python3)"
export WORKON_HOME="$HOME/.virtualenvs"
if [[ -s /usr/share/virtualenvwrapper/virtualenvwrapper.sh ]]; then
	source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
fi
#}}}

# Functions {{{
if [[ ${_SYSENV_DIST} == "ubuntu" ]]; then
	function kernel-cleanup()
	{
		local cur_kernel=$(uname -r|sed 's/-*[a-z]//g'|sed 's/-386//g')
		local kernel_pkg="linux-(image-unsigned|signed-image|image|image-extra|headers|ubuntu-modules|restricted-modules|modules)"
		local meta_pkg="${kernel_pkg}-(generic|lowlatency|i386|virtual|server|common|rt|xen|ec2|amd64)"
		local latest_kernel=$(dpkg -l linux-image-\* | \
			grep -E "linux-image-unsigned-[0-9]|linux-signed-image-[0-9]|linux-image-[0-9]" | \
			awk '/^ii/{ print $2}' | \
			sed -e "s/^\(linux-image-unsigned-\|linux-signed-image-\|linux-image-\)//" | \
			grep -E \[0-9\] | sort -V | tail -1 | cut -f1,2 -d"-")
		local kernel_pkg_remove=$(dpkg -l | grep -E $kernel_pkg | grep -v -E "${cur_kernel}|${meta_pkg}|${latest_kernel}" | awk '{print $2}')
		if [[ ! -z ${kernel_pkg_remove} ]]; then
			sudo aptitude purge -y ${kernel_pkg_remove}
			sudo rm -r -f -v $(find /lib/modules/* -maxdepth 0 | grep -v -E "${cur_kernel}|${latest_kernel}" | awk '{print $1}')
			sudo update-grub2
		fi
	}

	function package-cleanup()
	{
		if [[ $(dpkg --get-selections | grep deinstall | cut -f1 | wc -l) != 0 ]]; then
			sudo aptitude -y purge $(dpkg --get-selections | grep deinstall | cut -f1)
		fi
		sudo aptitude -y autoclean
	}

	function package-refresh()
	{
		retry sudo aptitude update
		retry sudo aptitude -d -y upgrade
		sudo DEBIAN_FRONTEND="noninteractive" aptitude -y upgrade
		package-cleanup
		if (( $+commands[snap] )); then
			sudo snap refresh
		fi
	}

	function system-clean()
	{
		# local files=($HOME/.cache/pip/{*,.*}(N)); (($#files)) &&    \
		#     rm -r -f -- ${files}
		rm -f $HOME/.wget-hsts                                      \
			$HOME/.xsession-errors.old
	}

	function system-refresh()
	{
		package-refresh
		retry antigen selfupdate
		retry antigen update
		if [[ -d $HOME/.vim_data/bundle ]]; then
			vim +NeoBundleUpdate +quit!
		fi
		system-clean
	}
fi

if [[ ${_SYSENV_OS} == "macos" ]]; then
	function package-cleanup()
	{
		brew cleanup
	}

	function package-refresh()
	{
		retry brew update
		brew outdated
		retry brew upgrade
		brew cleanup
	}

	function system-clean()
	{
		rm -f $HOME/.wget-hsts
	}

	function system-refresh()
	{
		package-refresh
		antigen selfupdate
		antigen update
		if [[ -d $HOME/.vim_data/bundle ]]; then
			vim +NeoBundleUpdate +quit!
		fi
		system-clean
	}
fi

if [[ ${_SYSENV_OS} == "cygwin" ]]; then
	function system-refresh()
	{
		antigen selfupdate
		antigen update
		if [[ -d $HOME/.vim_data/bundle ]]; then
			vim +NeoBundleUpdate +quit!
		fi
	}
fi

if [[ ${_SYSENV_DIST} == "synologydsm" ]]; then
	function system-refresh()
	{
		antigen selfupdate
		antigen update
		if [[ -d $HOME/.vim_data/bundle ]]; then
			vim +NeoBundleUpdate +quit!
		fi
	}
fi

if (( $+commands[docker] )); then
	docker-clean-unused()
	{
		print "Starting procedure for cleaning all unused docker environment,"
		answer=""
		vared -p "Are you sure[y/N]? " answer
		if [[ ${answer} != "y" && ${answer} != "Y" ]]; then
			return 0
		fi

		docker system prune --force --all --volumes
	}

	docker-clean-all()
	{
		print "Starting procedure for removing all docker environment,"
		answer=""
		vared -p "Are you sure[y/N]? " answer
		if [[ ${answer} != "y" && ${answer} != "Y" ]]; then
			return 0
		fi

		list_container=$( docker container ls -a -q )
		if [[ ! -z "${list_container[@]}" ]]; then
			docker stop $( IFS=" "; echo "${list_container[@]}" )
		fi

		docker system prune --force --all --volumes
	}
fi

if (( $+commands[btrfs] )); then
	btrfs-optimize()
	{
		print "Starting btrfs defragmentation..."
		sudo btrfs filesystem defragment -r -f / 2> /dev/null
		print "Starting btrfs rebalancing..."
		sudo btrfs balance start --full-balance /
		print "Done."
	}
fi

if [[ -f /usr/bin/vmware-config-tools.pl ]]; then
	function vmware-tools-reconfigure()
	{
		sudo vmware-config-tools.pl --clobber-kernel-modules=vmblock,vmhgfs,vmmemctl,vmxnet,vmci,vsock,vmsync,pvscsi,vmxnet3,vmwsvga --default
	}
fi

function retry()
{
	local nTrys=0
	local maxTrys=20
	local delayBtwnTrys=3
	local lastStatus=256
	until [[ $lastStatus == 0 ]]; do
		$*
		lastStatus=$?
		nTrys=$(($nTrys + 1))
		if [[ $nTrys -gt $maxTrys ]]; then
			echo "Number of re-trys exceeded. Exit code: $lastStatus"
			exit $lastStatus
		fi
		if [[ $lastStatus != 0 ]]; then
			echo "Failed (exit code $lastStatus)... retry count $nTrys/$maxTrys"
			sleep $delayBtwnTrys
		fi
	done
}
#}}}

# Aliases {{{
# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask. For example, alias rm='rm -i' will mask the rm
# application. To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.
# Interactive operation...
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# These aliases already exists in ubuntu, but they are useful
# in other distributes.
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls -hF --color=auto'
alias lsa='ls -lah'

# Default to human readable figures
alias df='df -h'
alias du='du -h'
if [[ ${_SYSENV_OS} == "linux" || ${_SYSENV_OS} == "cygwin" ]]; then
	alias ls='ls -hF --color=auto'
elif [[ ${_SYSENV_OS} == "macos" ]]; then
	if (( $+commands[gls] )); then
		alias ls='gls -hF --color=auto'
	else
		alias ls='ls -hF -G'
	fi
fi

# use vim instead of vi
alias vi='vim'

# astyle options
alias astyle='astyle --style=break --indent=force-tab=4 --unpad-paren --pad-header --pad-oper --unpad-paren --align-pointer=name --align-reference=name'

# axel options
alias axel='axel -a'

# wget options
alias wget='wget --retry-connrefused'

# minicom options
alias minicom='minicom --wrap --color=on'

# mc options
#type -p -a mc > /dev/null && alias mc='. /usr/share/mc/bin/mc-wrapper.sh -a'
if type -p -a mc > /dev/null; then
	unset MCWRAPPERSH
	if [[ -x $HOME/.local/libexec/mc/mc-wrapper.sh ]]; then
		local MCWRAPPERSH="$HOME/.local/libexec/mc/mc-wrapper.sh"
	elif [[ -x /usr/share/mc/bin/mc-wrapper.sh ]]; then
		local MCWRAPPERSH="/usr/share/mc/bin/mc-wrapper.sh"
	elif (( $+commands[brew] )); then
		brew --prefix mc &> /dev/null
		if [[ $? -eq 0 ]]; then
			local MCWRAPPERSH="$(brew --prefix mc)/libexec/mc/mc-wrapper.sh"
		fi
	fi
	if [[ ! -z $MCWRAPPERSH ]]; then
		case "$TERM" in
			screen-256color)
				alias mc="TERM=screen . $MCWRAPPERSH -a -x"
				;;
			*)
				alias mc=". $MCWRAPPERSH -a"
				;;
		esac
	fi
fi
#}}}

# Window title setting {{{
# Disable if liquid prompt is enabled
if [[ -z $LP_ENABLE_TITLE ]]; then
	# try to give the window a meaningful title, at least some of the time

	# use terminfo data to set title. this works with urxvt and probably others
	title-set-terminfo()
	{
		print -nR "$terminfo[tsl]$1 ${*[2,$]}$terminfo[fsl]"
	}

	# xterm doesn't work with terminfo -> special treatment
	title-set-xterm()
	{
		print -nR $'\033]0;'$1 ${*[2,$]}$'\007'
	}

	# set tab title in screen
	title-set-screen()
	{
		# tab title only uses $1
		print -nR $'\033k'$1$'\033\\'
	}

	# run some application, maybe? set title to "command (pwd)"
	title-preexec()
	{
		# don't bother if nopony's listening anyways
		(( $#title_functions > 0 )) || return

		local -a buf
		buf=( ${(z)1} )

		# straight from zsh-syntax-highlighting :)
		precommands=( 'builtin' 'command' 'exec' 'nocorrect' 'noglob' 'sudo' 'time' )

		# first is a precommand? shift dis shit.
		local prefix
		while (( $+precommands[(r)$buf[1]] )); do
			if [[ $buf[1] == sudo ]]; then
				# show sudo as a prefix
				prefix="sudo "

				# shift away all sudo-args, so the next one should be the command
				shift buf
				while [[ $buf[1] == -* ]]; do
					shift buf
				done
			else
				shift buf
			fi
		done

		# only care for a couple of command-type types. "for" is hardly a useful title
		local typ=${"$(LC_ALL=C builtin whence -w $buf[1] 2>/dev/null)"#*: }
		[[ $typ == "function" || $typ == "command" || $typ == "alias" ]] || return

		local f
		for f in $title_functions; do
			$f "$prefix${buf[1]:t}" "(${(D)PWD})"
		done
	}

	# back to the prompt, title is "zsh (pwd)"
	title-precmd()
	{
		local f
		for f in $title_functions; do
			$f zsh "(${(D)PWD})"
		done
	}

	# array of functions to call for title setting
	typeset -aH title_functions

	# if we can get tsl from terminfo, that'd be perfect. works with urxvt.
	zmodload zsh/terminfo
	if (( $+terminfo[tsl] && $+terminfo[fsl] )); then
		title_functions+=( title-set-terminfo )
		# otherwise, fallback for specific terminals (maybe expand this list?)
	elif [[ $TERM == xterm* ]]; then
		title_functions+=( title-set-xterm )
	fi

	# set screen title independently
	if [[ $TERM == screen* ]]; then
		title_functions+=( title-set-screen )
	fi

	# we do this regardless, to always provide title_functions functionality
	autoload -U add-zsh-hook
	add-zsh-hook preexec title-preexec
	add-zsh-hook precmd title-precmd
fi
#}}}

# Show tmux sessions when login {{{
if [[ -o LOGIN ]]; then
    # (( $#commands[tmux] )) && tmux list-sessions 2>/dev/null
    (( $#commands[tmux] )) && [[ -z "${TMUX}" ]] && tmux list-sessions 2>/dev/null
fi
#}}}

# etc. {{{
# The file that I don't want to see.
if [[ ${_SYSENV_DIST} == "ubuntu" && -f ~/.xsession-errors.old ]]; then
	rm -f ~/.xsession-errors.old
fi
#}}}
#  vim: set ft=zsh ts=4 sts=4 sw=4 tw=0 noet fdm=marker :
