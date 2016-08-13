# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# base-files version 4.1-1

# ~/.bash_profile: executed by bash(1) for login shells.

# The latest version as installed by the Cygwin Setup program can
# always be found at /etc/defaults/etc/skel/.bash_profile

# Modifying /etc/skel/.bash_profile directly will prevent
# setup from updating it.

# The copy in your home directory (~/.bash_profile) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the cygwin mailing list.

# User dependent .bash_profile file

# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/bin" ] ; then
  PATH="${HOME}/bin:${PATH}"
fi

# Set MANPATH so it includes users' private man if it exists
if [ -d "${HOME}/man" ]; then
  MANPATH="${HOME}/man:${MANPATH}"
fi

# Set INFOPATH so it includes users' private info if it exists
if [ -d "${HOME}/info" ]; then
  INFOPATH="${HOME}/info:${INFOPATH}"
fi

# locale setting
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
chcp.com 65001 > /dev/null

# Functions for internal use {{{
# function: __ensure_dir_exists
# $1: directory name to make if doesn't exist
function __ensure_dir_exists()
{
	if [[ ! -d $1 ]]; then
		mkdir -p $1
	fi
}

# function: __strip
# $1: string
# $2: character to strip (only ONE character!!)
function __strip()
{
	echo $1 | sed -e 's/^'$2'*//g' -e 's/'$2'*$//g'
}
#}}}

# Path configurations {{{
# Ensure '.local' directories exist.
__ensure_dir_exists $HOME/.local/bin
__ensure_dir_exists $HOME/.local/share/man
__ensure_dir_exists $HOME/.local/share/info
__ensure_dir_exists $HOME/.local/lib
if [[ $(uname -m | grep 'x86_64' | wc -l) != 0 ]]; then
	__ensure_dir_exists $HOME/.local/lib64
	__ensure_dir_exists $HOME/.local/lib32
fi
__ensure_dir_exists $HOME/.local/include
__ensure_dir_exists $HOME/.local/lib/pkgconfig

# Set some paths
if [[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
	PATH=$HOME/.local/bin:$PATH
	PATH=$(__strip "$PATH" ':')
	export PATH
fi

if [[ ! ":$(manpath 2> /dev/null):" == *":$HOME/.local/share/man:"* ]]; then
	unset MANPATH
	MANPATH=$HOME/.local/share/man:$(manpath 2> /dev/null)
	MANPATH=$(__strip "$MANPATH" ':')
	export MANPATH
fi

if [[ ! ":$INFOPATH:" == *":$HOME/.local/share/info:"* ]]; then
	INFOPATH=$HOME/.local/share/info:$INFOPATH
	INFOPATH=$(__strip "$INFOPATH" ':')
	export INFOPATH
fi

unset LD_LIBRARY_PATH_SCRATCH
if [[ ! ":$LD_LIBRARY_PATH:" == *":$HOME/.local/lib:"* ]]; then
	LD_LIBRARY_PATH_SCRATCH=$LD_LIBRARY_PATH_SCRATCH:$HOME/.local/lib
fi
if [[ $(uname -m | grep 'x86_64' | wc -l) != 0 ]]; then
	if [[ ! ":$LD_LIBRARY_PATH:" == *":$HOME/.local/lib64:"* ]]; then
		LD_LIBRARY_PATH_SCRATCH=$LD_LIBRARY_PATH_SCRATCH:$HOME/.local/lib64
	fi

	if [[ ! ":$LD_LIBRARY_PATH:" == *":$HOME/.local/lib32:"* ]]; then
		LD_LIBRARY_PATH_SCRATCH=$LD_LIBRARY_PATH_SCRATCH:$HOME/.local/lib32
	fi
fi
LD_LIBRARY_PATH_SCRATCH=$("__strip" $LD_LIBRARY_PATH_SCRATCH ':')
LD_LIBRARY_PATH=$LD_LIBRARY_PATH_SCRATCH:$LD_LIBRARY_PATH
LD_LIBRARY_PATH=$("__strip" $LD_LIBRARY_PATH ':')
unset LD_LIBRARY_PATH_SCRATCH
export LD_LIBRARY_PATH

unset LD_RUN_PATH_SCRATCH
if [[ ! ":$LD_RUN_PATH:" == *":$HOME/.local/lib:"* ]]; then
	LD_RUN_PATH_SCRATCH=$LD_RUN_PATH_SCRATCH:$HOME/.local/lib
fi
if [[ $(uname -m | grep 'x86_64' | wc -l) != 0 ]]; then
	if [[ ! ":$LD_RUN_PATH:" == *":$HOME/.local/lib64:"* ]]; then
		LD_RUN_PATH_SCRATCH=$LD_RUN_PATH_SCRATCH:$HOME/.local/lib64
	fi

	if [[ ! ":$LD_RUN_PATH:" == *":$HOME/.local/lib32:"* ]]; then
		LD_RUN_PATH_SCRATCH=$LD_RUN_PATH_SCRATCH:$HOME/.local/lib32
	fi
fi
LD_RUN_PATH_SCRATCH=$(__strip "$LD_RUN_PATH_SCRATCH" ':')
LD_RUN_PATH=$LD_RUN_PATH_SCRATCH:$LD_RUN_PATH
LD_RUN_PATH=$(__strip "$LD_RUN_PATH" ':')
unset LD_RUN_PATH_SCRATCH
export LD_RUN_PATH

unset LIBRARY_PATH_SCRATCH
if [[ ! ":$LIBRARY_PATH:" == *":$HOME/.local/lib:"* ]]; then
	LIBRARY_PATH_SCRATCH=$LIBRARY_PATH_SCRATCH:$HOME/.local/lib
fi
if [[ $(uname -m | grep 'x86_64' | wc -l) != 0 ]]; then
	if [[ ! ":$LIBRARY_PATH:" == *":$HOME/.local/lib64:"* ]]; then
		LIBRARY_PATH_SCRATCH=$LIBRARY_PATH_SCRATCH:$HOME/.local/lib64
	fi

	if [[ ! ":$LIBRARY_PATH:" == *":$HOME/.local/lib32:"* ]]; then
		LIBRARY_PATH_SCRATCH=$LIBRARY_PATH_SCRATCH:$HOME/.local/lib32
	fi
fi
LIBRARY_PATH_SCRATCH=$(__strip "$LIBRARY_PATH_SCRATCH" ':')
LIBRARY_PATH=$LIBRARY_PATH_SCRATCH:$LIBRARY_PATH
LIBRARY_PATH=$(__strip "$LIBRARY_PATH" ':')
unset LIBRARY_PATH_SCRATCH
export LIBRARY_PATH

if [[ ! ":$CPATH:" == *":$HOME/.local/include:"* ]]; then
	CPATH=$HOME/.local/include:$CPATH
	CPATH=$(__strip "$CPATH" ':')
	export CPATH
fi

if [[ ! ":$PKG_CONFIG_PATH:" == *":$HOME/.local/lib/pkgconfig:"* ]]; then
	PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH
	PKG_CONFIG_PATH=$(__strip "$PKG_CONFIG_PATH" ':')
	export PKG_CONFIG_PATH
fi
#}}}
