#*****************************************
#*                                       *
#*                .zshenv                *
#*                                       *
#*            by Wonmin Jung             *
#*          wonmin82@gmail.com           *
#*      https://github.com/wonmin82      *
#*                                       *
#*****************************************

# umask setting for security {{{
umask 022
# }}}

# Variables {{{
ZDOTDIR="$HOME/.zsh"

ZSHDATADIR="$HOME/.zsh_data"
HISTFILE="$ZSHDATADIR/.zsh_history"

ANTIGENDIR="$ZSHDATADIR/antigen"
ADOTDIR="$ZSHDATADIR/antigen-repo"

skip_global_compinit=1
ANTIGEN_COMPDUMP="$ZSHDATADIR/.zcompdump"

# locale setting
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

# PAGER, EDITOR setting
export PAGER="less"
export EDITOR="vim"

# gcc color setting
export GCC_COLORS="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"
#}}}

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
# $1: character to strip (only ONE character!!)
# $2: string
function __strip()
{
	char="$1"
	shift
	string="$*"
	[[ ! -z "${string}" ]] && string="${string%${string##*[^${char}]}}"
	[[ ! -z "${string}" ]] && string="${string#${string%%[^${char}]*}}"
	print ${string}
}

function __rationalize_path()
{
	local element
	local build
	build=()
	eval '
	foreach element in "$'"$1"'[@]"
	do
		if [[ -d "$element" ]]; then
			build=("$build[@]" "$element")
		fi
	done
	'"$1"'=( "$build[@]" )
	'
}
#}}}

# Path configurations {{{
# Ensure '.local' directories exist.
[[ "${$(uname -m)/"x86_64"}" != "$(uname -m)" ]] && local is_64bit=true || local is_64bit=false

__ensure_dir_exists "$HOME/.local/bin"
__ensure_dir_exists "$HOME/.local/share/man"
__ensure_dir_exists "$HOME/.local/share/info"
__ensure_dir_exists "$HOME/.local/lib"
if [[ $is_64bit == true ]]; then
	__ensure_dir_exists "$HOME/.local/lib64"
	__ensure_dir_exists "$HOME/.local/lib32"
fi
__ensure_dir_exists "$HOME/.local/include"
__ensure_dir_exists "$HOME/.local/lib/pkgconfig"

__ensure_dir_exists "$HOME/.local/go"
__ensure_dir_exists "$HOME/work/go"
__ensure_dir_exists "$HOME/.local/go/bin"
__ensure_dir_exists "$HOME/work/go/bin"
# Set some paths
cdpath=( . )
typeset -U cdpath
export CDPATH

fpath=( "$fpath[@]" )
typeset -U fpath
export FPATH

path=(
"$HOME/.local/bin"
$path
)
if [[ -a /etc/synoinfo.conf ]]; then
	path=(
	"/usr/local/git/bin"
	$path
	)
fi
typeset -U path
__rationalize_path path
export PATH

if whence manpath > /dev/null 2>&1; then
	MANPATH="$(manpath 2> /dev/null)"
	manpath=(
	"$HOME/.local/share/man"
	"$manpath[@]"
	)
else
	manpath=(
	"$HOME/.local/share/man"
	"/usr/local/share/man"
	"/usr/local/man"
	"/usr/share/man"
	"/usr/man"
	)
fi
typeset -U manpath
__rationalize_path manpath
export MANPATH

typeset -T INFOPATH infopath ":"
infopath=(
"$HOME/.local/share/info"
$infopath
)
typeset -U infopath
__rationalize_path infopath
export INFOPATH

typeset -T LD_LIBRARY_PATH ld_library_path ":"
if [[ $is_64bit == true ]]; then
	ld_library_path=(
	"$HOME/.local/lib64"
	"$HOME/.local/lib32"
	$ld_library_path
	)
fi
ld_library_path=(
"$HOME/.local/lib"
$ld_library_path
)
typeset -U ld_library_path
__rationalize_path ld_library_path
export LD_LIBRARY_PATH

typeset -T LD_RUN_PATH ld_run_path ":"
if [[ $is_64bit == true ]]; then
	ld_run_path=(
	"$HOME/.local/lib64"
	"$HOME/.local/lib32"
	$ld_run_path
	)
fi
ld_run_path=(
"$HOME/.local/lib"
$ld_run_path
)
typeset -U ld_run_path
__rationalize_path ld_run_path
export LD_RUN_PATH

typeset -T LIBRARY_PATH library_path ":"
if [[ $is_64bit == true ]]; then
	library_path=(
	"$HOME/.local/lib64"
	"$HOME/.local/lib32"
	$library_path
	)
fi
library_path=(
"$HOME/.local/lib"
$library_path
)
typeset -U library_path
__rationalize_path library_path
export LIBRARY_PATH

typeset -T CPATH cpath ":"
cpath=(
"$HOME/.local/include"
$cpath
)
typeset -U cpath
__rationalize_path cpath
export CPATH

typeset -T PKG_CONFIG_PATH pkg_config_path ":"
pkg_config_path=(
"$HOME/.local/lib/pkgconfig"
$pkg_config_path
)
typeset -U pkg_config_path
__rationalize_path pkg_config_path
export PKG_CONFIG_PATH

typeset -T GOPATH gopath ":"
gopath=(
"$HOME/.local/go"
"$HOME/work/go"
$gopath
)
typeset -U gopath
__rationalize_path gopath
export GOPATH
#}}}

if [[ -f $HOME/.zshenv.path ]]; then
	source $HOME/.zshenv.path
	typeset -U path
	__rationalize_path path
	export PATH
fi

#  vim: set ft=zsh ts=4 sts=4 sw=4 tw=0 noet fdm=marker :
