"*****************************************
"*                                       *
"*                .vimrc                 *
"*                                       *
"*            by Wonmin Jung             *
"*          wonmin82@gmail.com           *
"*      https://github.com/wonmin82      *
"*                                       *
"*****************************************
" TODO: Check compatibility in windows.
" TODO: Move cursor by display lines when wrapping
"       - http://vim.wikia.com/wiki/Move_cursor_by_display_lines_when_wrapping

" Note: Skip initialization for vim-tiny or vim-small. {{{
if !1 | finish | endif
"}}}

set nocompatible               " Be iMproved

" Judging OS "{{{
let s:is_win64 = 0
let s:is_win32 = 0
let s:is_cygwin = 0
let s:is_macos = 0
let s:is_raspbian = 0
let s:is_synology = 0
let s:is_linux64 = 0
let s:is_linux32 = 0
let s:is_unix = 0

if has('win32')
	if has('win64')
		" Windows 64-bit
		let s:is_win64 = 1
	else
		" Windows 32-bit
		let s:is_win32 = 1
	endif
elseif has('win32unix')
	" cygwin
	let s:is_cygwin = 1
elseif !has('win32') && (has('mac') || has('macunix') || has('gui_macvim') ||
			\ (!isdirectory('/proc') && executable('sw_vers')))
	" MacOS
	let s:is_macos = 1
elseif glob('/etc/rpi-issue') != ''
	" Synology DSM
	let s:is_raspbian = 1
elseif glob('/etc/synouser.conf') != ''
	" Synology DSM
	let s:is_synology = 1
elseif glob('/lib*/ld-linux*64.so.2') != ''
	" Linux 64-bit
	let s:is_linux64 = 1
elseif glob('/lib*/ld-linux*.so.2') != ''
	" Linux 32-bit
	let s:is_linux32 = 1
else
	" Unix
	let s:is_unix = 1
endif
"}}}

" Set directories {{{
" Function: Make directory if doesn't exist "{{{
function! EnsureDirExists(dir)
	let rdir = expand(a:dir)
	if ! isdirectory(rdir)
		if exists("*mkdir")
			call mkdir(rdir, 'p')
			echon "Created directory: " . rdir . "\n\r"
		else
			echon "Please create directory: " . rdir . "\n\r"
		endif
	endif
endfunction
"}}}

" set data directories
let $DOTVIMPATH = expand('~/.vim')
let $DOTVIMDATAPATH = expand('~/.vim_data')
let $PLUGINPATH = $DOTVIMDATAPATH . '/bundle'
let $SWAPPATH = $DOTVIMDATAPATH . '/swap'
let $BACKUPPATH = $DOTVIMDATAPATH . '/backup'
let $UNDOPATH = $DOTVIMDATAPATH . '/undo'
let $SESSIONPATH = $DOTVIMDATAPATH . '/session'
let $ULTISNIPSPATH = $DOTVIMDATAPATH . '/UltiSnips'
let $UNITEPATH = $DOTVIMDATAPATH . '/cache/unite'
let $VIMFILERPATH = $DOTVIMDATAPATH . '/cache/vimfiler'
let $VIMSHELLPATH = $DOTVIMDATAPATH . '/cache/vimshell'
let $NEOMRUPATH = $DOTVIMDATAPATH . '/cache/neomru'

call EnsureDirExists($DOTVIMDATAPATH)
set viminfo+=n$DOTVIMDATAPATH/viminfo

call EnsureDirExists($SWAPPATH)
set directory=$SWAPPATH//

call EnsureDirExists($BACKUPPATH)
set backupdir=$BACKUPPATH//

call EnsureDirExists($UNDOPATH)
set undodir=$UNDOPATH//

call EnsureDirExists($SESSIONPATH)
let g:session_directory = $SESSIONPATH

call EnsureDirExists($ULTISNIPSPATH)
let g:UltiSnipsSnippetsDir = $ULTISNIPSPATH

call EnsureDirExists($UNITEPATH)
let g:unite_data_directory = $UNITEPATH

call EnsureDirExists($VIMFILERPATH)
let g:vimfiler_data_directory = $VIMFILERPATH

call EnsureDirExists($VIMSHELLPATH)
let g:vimshell_data_directory = $VIMSHELLPATH

call EnsureDirExists($NEOMRUPATH)
let g:neomru#file_mru_path = $NEOMRUPATH . '/file'
let g:neomru#directory_mru_path = $NEOMRUPATH . '/directory'
"}}}

" Plugin: NeoBundle {{{
let g:neobundle#types#git#default_protocol = 'https'
" YouCompleteMe install process tooks time.
let g:neobundle#install_process_timeout = 1200

if has('vim_starting')
	" following line has moved to very first of vimrc
	" set nocompatible               " Be iMproved

	" Required:
	set runtimepath+=$PLUGINPATH/neobundle.vim/
endif

" Begin NeoBundle {{{
let s:max_retry_count = 5
let s:retry_count = 0
let s:is_neobundle_inited = 0
while ! s:is_neobundle_inited
	try
		" Required:
		call neobundle#begin(expand($PLUGINPATH))

		" Let NeoBundle manage NeoBundle
		" Required:
		NeoBundleFetch 'Shougo/neobundle.vim'
		let s:is_neobundle_inited = 1
	catch /^Vim\%((\a\+)\)\=:E117/
		" If NeoBundle is missing, define an installer for it
		function! NeoBundleInstaller()
			if s:is_cygwin || s:is_macos || s:is_raspbian || s:is_synology ||
						\  s:is_linux64 || s:is_linux32 || s:is_unix
				let s:retry_count = s:retry_count + 1
				if s:retry_count > s:max_retry_count
					execute ':silent !echo "==> NeoBundle installation has been failed."'
					quit!
				endif

				execute ':silent !echo "==> Starting NeoBundle installation... (retry count: ' . s:retry_count . '/' . s:max_retry_count . ')"'
				let destination = expand($PLUGINPATH . '/neobundle.vim')
				if ! isdirectory(destination)
					call mkdir(destination, "p")
				endif
				let install_command = printf('git clone %s://github.com/Shougo/neobundle.vim.git %s',
							\ (exists('$http_proxy') ? 'https' : 'git'),
							\ destination)
				execute ':silent !echo "==> Executing command: ' . install_command . '"'
				execute ':silent !' . install_command
				let neobundle_plugin = expand($PLUGINPATH . '/neobundle.vim/autoload/neobundle.vim')
				try
					execute ':source ' . neobundle_plugin
					execute ':silent !echo "==> NeoBundle has been installed."'
				catch
					execute ':silent !echo "==> Failed to load NeoBundle."'
				endtry
			elseif s:is_win32 || s:is_win64
				" TODO: need to be checked if it is working or not.
				let s:retry_count = s:retry_count + 1
				if s:retry_count > s:max_retry_count
					execute ':silent !echo "==> NeoBundle installation has been failed."'
					quit!
				endif

				execute ':silent !echo "==> Starting NeoBundle installation... (retry count: ' . s:retry_count . '/' . s:max_retry_count . ')"'
				let destination = expand($PLUGINPATH . '/neobundle.vim')
				if ! isdirectory(destination)
					call mkdir(destination, "p")
				endif
				let install_command = printf('git clone %s://github.com/Shougo/neobundle.vim.git %s',
							\ (exists('$http_proxy') ? 'https' : 'git'),
							\ destination)
				execute ':silent !echo "==> Executing command: ' . install_command . '"'
				execute ':silent !' . install_command
				execute ':silent !echo "==> NeoBundle has been installed."'
				let neobundle_plugin = expand($PLUGINPATH . '/neobundle.vim/autoload/neobundle.vim')
				try
					execute ':source ' . neobundle_plugin
					execute ':silent !echo "==> NeoBundle has been installed."'
				catch
					execute ':silent !echo "==> Failed to load NeoBundle."'
				endtry
			endif
		endfunction

		call NeoBundleInstaller()
	catch
		execute ':silent !echo "==> NeoBundle initialization has been failed."'
		quit!
	endtry
endwhile
"}}}

" My Bundles here:
" Refer to |:NeoBundle-examples|.
" Note: You don't set neobundle setting in .gvimrc!
let s:is_ycm_enabled = 1

if !s:is_synology
	NeoBundle 'Shougo/vimproc', {
				\   'build': {
				\       'windows': 'make -f make_mingw32.mak',
				\       'cygwin': 'make -f make_cygwin.mak',
				\       'mac': 'make -f make_mac.mak',
				\       'unix': 'make -f make_unix.mak',
				\}}
endif

" Fuzzy search
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/unite-outline'
NeoBundle 'Shougo/unite-help'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'tsukkee/unite-tag'
NeoBundle 'osyo-manga/unite-quickfix'
NeoBundle 'thinca/vim-unite-history'
NeoBundle 'mileszs/ack.vim'

" File browsing
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'Shougo/vimfiler'

" Session
NeoBundle 'xolox/vim-session', {
			\   'lazy': 0,
			\   'depends': 'xolox/vim-misc',
			\   'augroup': 'PluginSession',
			\   'autoload': {
			\   'commands': [
			\   {
			\       'name': [ 'OpenSession', 'CloseSession' ],
			\       'complete': 'customlist,xolox#session#complete_names'
			\   },
			\   {
			\       'name': [ 'SaveSession' ],
			\       'complete': 'customlist,xolox#session#complete_names_with_suggestions'
			\   }
			\   ],
			\       'functions': [ 'xolox#session#complete_names',
			\                      'xolox#session#complete_names_with_suggestions' ]
			\}}

" Shell
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'Shougo/vimshell'
NeoBundle 'tpope/vim-dispatch'

" Git
NeoBundle 'tpope/vim-fugitive'

" Tags
NeoBundle 'majutsushi/tagbar'

" Status line
NeoBundle 'vim-airline/vim-airline'
NeoBundle 'vim-airline/vim-airline-themes'
NeoBundle 'bling/vim-bufferline'

NeoBundle 'embear/vim-localvimrc'
NeoBundle 'scrooloose/nerdcommenter'
if v:version > 703 || v:version == 703 && has('patch465')
	NeoBundle 'eiginn/netrw'
endif
NeoBundle 'wesleyche/SrcExpl'
NeoBundle 'jlanzarotta/bufexplorer'
NeoBundle 'dbakker/vim-projectroot'
NeoBundle 'godlygeek/tabular'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'vim-scripts/IndentTab', {
			\   'depends': 'vim-scripts/ingo-library'
			\}
NeoBundle 'vim-scripts/IndentConsistencyCop'
NeoBundle 'vim-scripts/IndentConsistencyCopAutoCmds'
NeoBundle 'ntpeters/vim-better-whitespace'

NeoBundle 'kergoth/vim-bitbake'
NeoBundle 'peterhoeg/vim-qml'

NeoBundle 'rhysd/vim-clang-format', {
			\   'depends': 'kana/vim-operator-user'
			\}
NeoBundle 'vivien/vim-linux-coding-style'
NeoBundle 'dimbleby/black.vim'
NeoBundle 'maksimr/vim-jsbeautify'
NeoBundle 'z0mbix/vim-shfmt'
if v:version >= 704 && !s:is_raspbian && !s:is_synology
	NeoBundle 'SirVer/ultisnips'
endif
NeoBundle 'honza/vim-snippets'

" ensure vim version >= 7.3.584 and not in cygwin.
if s:is_ycm_enabled && (v:version > 703 || v:version == 703 && has('patch584'))
			\   && !(s:is_win32 || s:is_win64 ||
			\        s:is_cygwin || s:is_raspbian || s:is_synology)
	NeoBundle 'Valloric/YouCompleteMe', {
				\   'build' : {
				\       'windows' : './install.py --clang-completer --system-libclang',
				\       'cygwin' : './install.py --clang-completer --system-libclang',
				\       'mac' : './install.py --all --system-libclang',
				\       'unix' : './install.py --all --system-libclang',
				\   }
				\}
endif

NeoBundle 'tomasr/molokai'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'noahfrederick/vim-noctu'

call neobundle#end()

" Required:
filetype plugin indent on

if neobundle#exists_not_installed_bundles()
	" Prevent vim-session's confirmation.
	let g:session_autosave = 'no'

	let more_save = &more
	let showcmd_save = &showcmd
	let ruler_save = &ruler
	let cmdheight_save = &cmdheight

	set nomore
	set noshowcmd
	set noruler
	set cmdheight=5

	NeoBundleInstall

	let &more = more_save
	let &showcmd = showcmd_save
	let &ruler = ruler_save
	let &cmdheight = cmdheight_save

	if neobundle#exists_not_installed_bundles()
		execute ':silent !echo ""'
		execute ':silent !echo "==> Failed to install some bundles, try run vim again."'
	else
		execute ':silent !echo ""'
		execute ':silent !echo "==> Bundles have been installed. Restart vim to continue."'
	endif
	quit!
endif
"}}}

"===============================================================================
" General Settings
"===============================================================================
" Set augroup {{{
augroup MyAutoCmd
	autocmd!
augroup END
"}}}
"
syntax on

scriptencoding utf-8
if &modifiable
	set fileencoding=utf-8
endif
set fileencodings=utf-8,cp949,unicode
set termencoding=utf-8
set encoding=utf-8

" Set the language to english. {{{
try
	language en_US.UTF-8
catch
endtry
"}}}

set autoread
set noautowrite
set nobackup
set nowritebackup
set swapfile
" Allow changing buffer without saving it first
set hidden

set undofile
set undolevels=1000
set undoreload=10000

set cursorline
set cursorcolumn
"if version >= 703
if exists('+colorcolumn')
	set colorcolumn=80
endif

set splitbelow
set splitright

" always show line numbers
set number
" Min width of the number column to the left
set numberwidth=1
set list

if has('folding')
	set foldenable
	set foldmethod=syntax
	set foldlevelstart=99
	set foldtext=FoldText()
endif

" Nicer fold text {{{
" See: http://dhruvasagar.com/2013/03/28/vim-better-foldtext
function! FoldText()
	let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
	let lines_count = v:foldend - v:foldstart + 1
	let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
	let foldchar = matchstr(&fillchars, 'fold:\zs.')
	let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
	let foldtextend = lines_count_text . repeat(foldchar, 8)
	let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
	return foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction
" }}}

" Minimal number of screen lines to keep above and below the cursor
set scrolloff=3
set sidescrolloff=3

" How many lines to scroll at a time, make scrolling appears faster
set scrolljump=3

set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
set smarttab

set autoindent
set cindent
set smartindent
set backspace=indent,eol,start
set nowrap
set whichwrap=h,l,<,>,[,]

set formatoptions=tcq

set hlsearch
set incsearch
set ignorecase
if exists('+wildignorecase')
	set wildignorecase
endif
if exists('+fileignorecase')
	set nofileignorecase
endif
set smartcase
set magic

set history=1000
"set km=startsel,stopsel
set laststatus=2
set nomore
set matchpairs+=<:>
set mouse=a
if &term =~ '^screen'
	" tmux knows the extended mouse mode
	set ttymouse=xterm2
endif
"set pastetoggle=<ins>
set report=0
set ruler
set selection=exclusive
set showcmd
set showmatch
set showmode
set startofline
"set statusline=%-3.3n\ %f\ %r%#Error#%m%#Statusline#\ (%l/%L,\ %v)\ %P%=%h%w\ %y\ [%{&encoding}:%{&fileformat}]
set title
set ttyfast
"set virtualedit=onemore                        " Has to be used with caution!!

set wildchar=<tab>
set wildmenu
"set wildmode=list:longest,full
set wildmode=longest,list,full
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
set wildignore+=*.pyc
set wildignore+=*DS_Store*,*/.Trash/**

set noerrorbells
set visualbell
set vb t_vb=

" Lower the delay of escaping out of other modes
"set timeout timeoutlen=1000 ttimeoutlen=1
set timeout timeoutlen=500 ttimeoutlen=1

let mapleader = ','
let maplocalleader = '\'

" fillchars and listchars {{{
if 0
	if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
		"set fillchars=stl:^,stlnc:-,vert:\|,fold:-,diff:-:
		let &fillchars="vert:\u2502,fold:\u2500,diff:\u2014"
	endif

	" Define characters to show when you show formatting
	" stolen from https://github.com/tpope/vim-sensible
	if &listchars ==# 'eol:$'
		set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
		if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
			"let &listchars="eol:\u00b6,tab:\u25b8\ ,trail:\u2022,extends:\u00bb,precedes:\u00ab,nbsp:\u00d7"
			let &listchars="eol:\u00b6,tab:\u25b8\ ,trail:\u2022,extends:\u00bb,precedes:\u00ab,nbsp:\u2423"
		endif
	endif

	" another nice listchars configuration
	"set listchars=tab:\|\ ,eol:¬
	"set listchars=eol:¬,tab:>-,trail:.,extends:»,precedes:«
	"set listchars=tab:\|\ ,eol:¬,trail:-,extends:>,precedes:<,nbsp:+

	if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
		let &showbreak="\u21aa"
	endif
endif

" override special chars avoid using not supported by some fonts,
" above settings will be ignored.
let &fillchars="vert:\u2502,fold:\u2500,diff:\u2014"
let &listchars="eol:\u00b6,tab:\u00bb\u0020,trail:\u00b7,extends:\u00bb,precedes:\u00ab,nbsp:\u00b7"
let &showbreak="\u2026"
"}}}

" examine terminal color and decide colorscheme to use {{{
if has('gui_running')
	set background=dark
	colorscheme molokai
else
	if $TERM =~ '256color'
		set t_Co=256
	elseif $TERM =~ '^xterm'
		set t_Co=256
	elseif $TERM =~ '^screen-bce'
		set t_Co=256            " just guessing
	elseif $TERM =~ '^screen'
		set t_Co=256            " just guessing, too
	elseif $TERM =~ '^rxvt'
		set t_Co=88
	elseif $TERM =~ '^linux'
		set t_Co=8
	elseif $TERM =~ '^cygwin'
		set t_Co=8
	else
		set t_Co=16
	endif

	function! OverrideColorScheme()
		if g:colors_name == 'molokai'
			execute "hi VertSplit cterm=none"
		endif
		if g:colors_name == 'molokai' && &t_Co >= 256
			execute "hi MatchParen ctermfg=226 ctermbg=bg"
		endif
	endfunction
	" customizing colorschemes
	" disable bold attribute for VertSplit in molokai colorscheme,
	" because certain font(Dejavu Sans Mono Bold) lacks
	" line drawing characters.
	augroup MyAutoCmd
		autocmd ColorScheme *
					\   execute "try | call OverrideColorScheme() | catch | endtry"
	augroup END

	if &t_Co >= 256
		set background=dark
		let g:rehash256 = 1                 " for molokai colorscheme
		let g:solarized_termcolors = 256    " for solarized colorscheme
		colorscheme molokai
	elseif &t_Co >= 88
		set background=dark
		colorscheme noctu
		set nocursorcolumn
		set nocursorline
	else
		set background=dark
		let g:jellybeans_use_lowcolor_black = 0
		colorscheme jellybeans
		set nocursorcolumn
		set nocursorline
	endif
endif
"}}}
"
" XTerm escape sequences definition for tmux {{{
" Make Vim recognize XTerm escape sequences for Page and Arrow
" keys combined with modifiers such as Shift, Control, and Alt.
" See http://www.reddit.com/r/vim/comments/1a29vk/_/c8tze8p
if &term =~ '^screen'
	" Page keys http://sourceforge.net/p/tmux/tmux-code/ci/master/tree/FAQ
	execute "set t_kP=\e[5;*~"
	execute "set t_kN=\e[6;*~"

	" Arrow keys http://unix.stackexchange.com/a/34723
	execute "set <xUp>=\e[1;*A"
	execute "set <xDown>=\e[1;*B"
	execute "set <xRight>=\e[1;*C"
	execute "set <xLeft>=\e[1;*D"
endif
"}}}

" XTerm escape sequence definition for <home> and <end> key {{{
if &term =~ "^xterm"
	execute "map <esc>[1~ <home>"
	execute "map! <esc>[1~ <home>"
	execute "map <esc>[4~ <end>"
	execute "map! <esc>[4~ <end>"
endif
"}}}

" Cursor settings. {{{
" This makes terminal vim sooo much nicer!
" Tmux will only forward escape sequences to the terminal if surrounded by a DCS
" sequence
if exists('$TMUX')
	let &t_SI = "\<esc>Ptmux;\<esc>\<esc>]50;CursorShape=1\x7\<esc>\\"
	let &t_EI = "\<esc>Ptmux;\<esc>\<esc>]50;CursorShape=0\x7\<esc>\\"
else
	let &t_SI = "\<esc>]50;CursorShape=1\x7"
	let &t_EI = "\<esc>]50;CursorShape=0\x7"
endif
"}}}

" remember last editing position {{{
" Uncomment the following to have Vim jump to the last position when
" reopening a file
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
"    \| exe "normal g'\"" | endif
"endif
"}}}

" Settings per filetype {{{
let g:c_syntax_for_h = 1

function! GetVisualSelection()
	let [line_start, column_start] = getpos("'<")[1:2]
	let [line_end, column_end] = getpos("'>")[1:2]
	let l:lines = getline(line_start, line_end)
	if len(l:lines) == 0
		return ''
	endif
	let l:lines[-1] = lines[-1][: column_end - 2]
	let l:lines[0] = lines[0][column_start - 1:]
	return join(l:lines, "\n")
endfunction

function! PydocFind()
	let l:line = getline(".")
	let l:pre = l:line[:col(".") - 1]
	let l:suf = l:line[col("."):]
	let word = matchstr(pre, "[A-Za-z0-9_.]*$") . matchstr(suf, "^[A-Za-z0-9_]*")
	call PydocShow(word)
endfunction

function! PydocShow(word)
	if a:word == ''
		echo "Invalid name or symbol."
		return 0
	endif
	silent execute ":!clear"
	execute ":!pydoc " . a:word
	redraw!
endfunction

function s:set_buffer_env_for_python()
	setlocal tabstop=4 softtabstop=4 shiftwidth=4
	setlocal smarttab expandtab
	setlocal autoindent cindent smartindent
	setlocal backspace=indent,eol,start
	nnoremap <silent> <buffer> K :call PydocFind()<CR>
	vnoremap <silent> <buffer> K :<C-U>if line("'>") - line("'<") == 0<bar>execute(":call PydocShow(GetVisualSelection())")<bar>endif<CR>
endfunction

function s:set_buffer_env_for_man()
	setlocal tabstop=8
	setlocal nomodifiable nomodified
	setlocal nolist nonumber nospell
	setlocal mouse=a
	setlocal nocursorline nocursorcolumn
	setlocal nofoldenable
	if exists('+colorcolumn')
		setlocal colorcolumn=
	endif
	nnoremap <buffer> q :qa!<cr>
	nnoremap <buffer> <end> G
	nnoremap <buffer> <home> gg
	nmap <buffer> K <c-]>
	nnoremap <buffer> : <nop>
	nnoremap <buffer> <f2> <nop>
	nnoremap <buffer> <f3> <nop>
	nnoremap <buffer> <f4> <nop>
	nnoremap <buffer> <f5> <nop>
endfunction

function s:set_buffer_env_for_cppman()
	setlocal tabstop=8
	setlocal nolist nonumber nospell
	setlocal mouse=a
	setlocal nocursorline nocursorcolumn
	setlocal nofoldenable
	if exists('+colorcolumn')
		setlocal colorcolumn=
	endif
	nnoremap <buffer> q :qa!<cr>
	nnoremap <buffer> <end> G
	nnoremap <buffer> <home> gg
	nnoremap <buffer> <f2> <nop>
	nnoremap <buffer> <f3> <nop>
	nnoremap <buffer> <f4> <nop>
	nnoremap <buffer> <f5> <nop>
endfunction

augroup MyAutoCmd
	autocmd BufWinEnter *.hpp set syntax=cpp
	" default cinoptions value
	"set cinoptions=s,e0,n0,f0,{0,}0,^0,L-1,:s,=s,l0,b0,gs,hs,N0,ps,ts,is,+s,c3,C0,/0,(2s,us,U0,w0,W0,k0,m0,j0,J0,)20,*70,#0
	autocmd Filetype c,cpp
				\   execute "setlocal tabstop=4 softtabstop=4 shiftwidth=4" |
				\   execute "setlocal smarttab noexpandtab" |
				\   execute "setlocal autoindent cindent smartindent" |
				\   execute "setlocal backspace=indent,eol,start" |
				\   execute "setlocal cinoptions=:0,l1,g0,t0,(0,W4,j1,J1" |
				\   execute "setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e" |
				\   execute "setlocal cinwords=if,else,while,do,for,switch"
	autocmd Filetype cpp
				\   execute "setlocal keywordprg=cppman"
	autocmd Filetype python
				\   execute "call s:set_buffer_env_for_python()"
	autocmd Filetype perl
				\   execute "setlocal keywordprg=perldoc\\ -f"
	autocmd Filetype tex
				\   execute "setlocal textwidth=72"
	autocmd FileType man
				\   execute "call s:set_buffer_env_for_man()"
	" SourcePost autocmd supported from 8.1.0729
	if (v:version > 801 || v:version == 801 && has('patch729'))
		autocmd SourcePost cppman.vim
					\   execute "call s:set_buffer_env_for_cppman()"
	endif
	autocmd FileType vimshell
				\   execute "setlocal nolist nonumber nospell"
augroup END
"}}}

" some autocmds {{{
" Only set more option after VimEnter occurred.
autocmd VimEnter * set more

if 0
	" automatically delete trailing Dos-returns,whitespace
	"autocmd BufRead * silent! %s/[\r \t]\+$//
	"autocmd BufEnter *.php :%s/[ \t\r]\+$//e

	" automatically delete trailing Dos-returns
	autocmd BufRead * silent! %s/\r\+$//
	autocmd BufEnter *.php :%s/\r\+$//e

	" Automatic folding
	autocmd BufWinLeave *.rb mkview
	autocmd BufWinEnter *.rb silent loadview

	autocmd BufWinLeave *.c mkview
	autocmd BufWinEnter *.c silent loadview

	autocmd BufWinLeave *.cc mkview
	autocmd BufWinEnter *.cc silent loadview

	autocmd BufWinLeave *.cpp mkview
	autocmd BufWinEnter *.cpp silent loadview

	autocmd BufWinLeave *.C mkview
	autocmd BufWinEnter *.C silent loadview

	autocmd BufWinLeave *.h mkview
	autocmd BufWinEnter *.h silent loadview

	autocmd BufWinLeave *.H mkview
	autocmd BufWinEnter *.H silent loadview

	autocmd BufWinLeave *.hpp mkview
	autocmd BufWinEnter *.hpp silent loadview
	autocmd BufWinEnter *.hpp set syntax=cpp

	autocmd BufWinLeave *.s mkview
	autocmd BufWinEnter *.s silent loadview

	autocmd BufWinLeave *.S mkview
	autocmd BufWinEnter *.S silent loadview
endif
"}}}

" cscope settings {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CSCOPE settings for vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" This file contains some boilerplate settings for vim's cscope interface,
" plus some keyboard mappings that I've found useful.
"
" USAGE:
" -- vim 6:     Stick this file in your ~/.vim/plugin directory (or in a
"               'plugin' directory in some other directory that is in your
"               'runtimepath'.
"
" -- vim 5:     Stick this file somewhere and 'source cscope.vim' it from
"               your ~/.vimrc file (or cut and paste it into your .vimrc).
"
" NOTE:
" These key maps use multiple keystrokes (2 or 3 keys).  If you find that vim
" keeps timing you out before you can complete them, try changing your timeout
" settings, as explained below.
"
" Happy cscoping,
"
" Jason Duell       jduell@alumni.princeton.edu     2002/3/7
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim...
if has("cscope")

	""""""""""""" Standard cscope/vim boilerplate

	" use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
	set cscopetag

	" check cscope for definition of a symbol before checking ctags: set to 1
	" if you want the reverse search order.
	set csto=0

	" add any cscope database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
		" else add the database pointed to by environment variable
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif

	" show msg when any other cscope db added
	set cscopeverbose


	""""""""""""" My cscope/vim key mappings
	"
	" The following maps all invoke one of the following cscope search types:
	"
	"   's'   symbol: find all references to the token under cursor
	"   'g'   global: find global definition(s) of the token under cursor
	"   'c'   calls:  find all calls to the function name under cursor
	"   't'   text:   find all instances of the text under cursor
	"   'e'   egrep:  egrep search for the word under cursor
	"   'f'   file:   open the filename under cursor
	"   'i'   includes: find files that include the filename under cursor
	"   'd'   called: find functions that function under cursor calls
	"
	" Below are three sets of the maps: one set that just jumps to your
	" search result, one that splits the existing vim window horizontally and
	" diplays your search result in the new window, and one that does the same
	" thing, but does a vertical split instead (vim 6 only).
	"
	" I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
	" unlikely that you need their default mappings (CTRL-\'s default use is
	" as part of CTRL-\ CTRL-N typemap, which basically just does the same
	" thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
	" If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
	" of these maps to use other keys.  One likely candidate is 'CTRL-_'
	" (which also maps to CTRL-/, which is easier to type).  By default it is
	" used to switch between Hebrew and English keyboard mode.
	"
	" All of the maps involving the <cfile> macro use '^<cfile>$': this is so
	" that searches over '#include <time.h>" return only references to
	" 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
	" files that contain 'time.h' as part of their name).


	" To do the first type of search, hit 'CTRL-\', followed by one of the
	" cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
	" search will be displayed in the current window.  You can use CTRL-T to
	" go back to where you were before the search.
	"

	nmap <c-\>s :cs find s <c-R>=expand("<cword>")<cr><cr>
	nmap <c-\>g :cs find g <c-R>=expand("<cword>")<cr><cr>
	nmap <c-\>c :cs find c <c-R>=expand("<cword>")<cr><cr>
	nmap <c-\>t :cs find t <c-R>=expand("<cword>")<cr><cr>
	nmap <c-\>e :cs find e <c-R>=expand("<cword>")<cr><cr>
	nmap <c-\>f :cs find f <c-R>=expand("<cfile>")<cr><cr>
	nmap <c-\>i :cs find i ^<c-R>=expand("<cfile>")<cr>$<cr>
	nmap <c-\>d :cs find d <c-R>=expand("<cword>")<cr><cr>


	" Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
	" makes the vim window split horizontally, with search result displayed in
	" the new window.
	"
	" (Note: earlier versions of vim may not have the :scs command, but it
	" can be simulated roughly via:
	"    nmap <c-@>s <c-W><c-S> :cs find s <c-R>=expand("<cword>")<cr><cr>

	nmap <c-@>s :scs find s <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@>g :scs find g <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@>c :scs find c <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@>t :scs find t <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@>e :scs find e <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@>f :scs find f <c-R>=expand("<cfile>")<cr><cr>
	nmap <c-@>i :scs find i ^<c-R>=expand("<cfile>")<cr>$<cr>
	nmap <c-@>d :scs find d <c-R>=expand("<cword>")<cr><cr>


	" Hitting CTRL-space *twice* before the search type does a vertical
	" split instead of a horizontal one (vim 6 and up only)
	"
	" (Note: you may wish to put a 'set splitright' in your .vimrc
	" if you prefer the new window on the right instead of the left

	nmap <c-@><c-@>s :vert scs find s <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@><c-@>g :vert scs find g <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@><c-@>c :vert scs find c <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@><c-@>t :vert scs find t <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@><c-@>e :vert scs find e <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@><c-@>f :vert scs find f <c-R>=expand("<cfile>")<cr><cr>
	nmap <c-@><c-@>i :vert scs find i ^<c-R>=expand("<cfile>")<cr>$<cr>
	nmap <c-@><c-@>d :vert scs find d <c-R>=expand("<cword>")<cr><cr>


	""""""""""""" key map timeouts
	"
	" By default Vim will only wait 1 second for each keystroke in a mapping.
	" You may find that too short with the above typemaps.  If so, you should
	" either turn off mapping timeouts via 'notimeout'.
	"
	"set notimeout
	"
	" Or, you can keep timeouts, by uncommenting the timeoutlen line below,
	" with your own personal favorite value (in milliseconds):
	"
	"set timeoutlen=4000
	"
	" Either way, since mapping timeout settings by default also set the
	" timeouts for multicharacter 'keys codes' (like <f1>), you should also
	" set ttimeout and ttimeoutlen: otherwise, you will experience strange
	" delays as vim waits for a keystroke after you hit ESC (it will be
	" waiting to see if the ESC is actually part of a key code like <f1>).
	"
	"set ttimeout
	"
	" personally, I find a tenth of a second to work well for key code
	" timeouts. If you experience problems and have a slow terminal or network
	" connection, set it higher.  If you don't set ttimeoutlen, the value for
	" timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
	"
	"set ttimeoutlen=100

endif
"}}}

" Load ctag and cscope database {{{
function! LoadCtags()
	let currentdir = getcwd()
	try
		execute "cd %:p:h"
	catch
	endtry
	let db = findfile("tags", ".;")

	if (!empty(db))
		let db = fnamemodify(db, ':p')
		let path = strpart(db, 0, match(db, "/tags$"))
		let path = fnamemodify(path, ':p')
		execute "set tags=" . db
		let b:ctags_db_path = path
	else
		let b:ctags_db_path = projectroot#guess()
	endif
	execute "cd " . currentdir
endfunction

function! LoadCscope()
	let currentdir = getcwd()
	try
		execute "cd %:p:h"
	catch
	endtry
	let db = findfile("cscope.out", ".;")

	if (!empty(db))
		let db = fnamemodify(db, ':p')
		let path = strpart(db, 0, match(db, "/cscope.out$"))
		let path = fnamemodify(path, ':p')
		set nocsverb " suppress 'duplicate connection' error
		execute "cscope add " . db . " " . path
		let b:cscope_db_path = path
		set csverb   " switch back to verbose mode
	else
		let b:cscope_db_path = projectroot#guess()
	endif
	execute "cd " . currentdir
endfunction

augroup MyAutoCmd
	autocmd Filetype c,cpp
				\   execute "call LoadCtags()"  |
				\   execute "call LoadCscope()"
augroup END
"}}}

" tabs {{{
" (leader is ",")
" Function: reorder tabs {{{
function! MoveTabLeft()
	let tab_number = tabpagenr() - 1
	if tab_number == 0
		execute "tabmove" tabpagenr('$') - 1
	else
		execute "tabmove" tab_number - 1
	endif
endfunction

function! MoveTabRight()
	let tab_number = tabpagenr() - 1
	let last_tab_number = tabpagenr('$') - 1
	if tab_number == last_tab_number
		execute "tabmove" 0
	else
		execute "tabmove" tab_number + 1
	endif
endfunction
"}}}

" buffers {{{
" next buffer
map <leader>bn :bnext<cr>
" previous buffer
map <leader>bp :bprevious<cr>
" last buffer
map <leader>bl :blast<cr>
" first buffer
map <leader>br :brewind<cr>
" delete buffer
map <leader>bd :bdelete<cr>
" find modified buffer
map <leader>bm :bmodified<cr>
"}}}

" create a new tab
map <leader>tc :tabnew<cr>
" close a tab
map <leader>td :tabclose<cr>
" next tab
map <leader>tn :tabnext<cr>
" previous tab
map <leader>tp :tabprev<cr>
" move a tab to a new location
map <leader>tm :tabmove
" move a tab to left or right
map <leader>tl :execute MoveTabLeft()<cr>
map <leader>tr :execute MoveTabRight()<cr>
"}}}

" windows {{{
" split current window
map <leader>ws :split<cr>
" split current window vertically
map <leader>wv :vsplit<cr>
" move cursor to next window
map <leader>ww <c-w>w
" close window
map <leader>wc <c-w>c
" close window for shortcut consistency
map <leader>wd <c-w>c
" make every windows to have same size
map <leader>we <c-w>=
" maximize window
map <leader>wz :vertical resize<cr>:resize<cr>
" move the current window to the left, bottom, top or right
map <leader>wH <c-w>H
map <leader>wJ <c-w>J
map <leader>wK <c-w>K
map <leader>wL <c-w>L
"}}}

" some useful mappings {{{
" w!!: Writes using sudo
cnoremap w!! w !sudo tee % >/dev/null
" R: Reindent entire file
nnoremap R mqHmwgg=G`wzt`q
" U: Redos since 'u' undos
nnoremap U :redo<cr>
" Y: yanks from cursor to $
map Y y$
" toggle list mode
nmap <leader>ml :set list!<cr>
" toggle paste mode
nmap <leader>mp :set paste!<cr>
" toggle more-prompt
nmap <leader>mo :set more!<cr>
" change directory to that of current file
nmap <leader>cd :cd%:p:h<cr>
" change local directory to that of current file
nmap <leader>lcd :lcd%:p:h<cr>
" open all folds
nmap <leader>fo :%foldopen!<cr>
" close all folds
nmap <leader>fc :%foldclose!<cr>
" When I'm pretty sure that the first suggestion is correct
map <leader>r 1z=
" toggle wordwrap mode
nmap <leader>mw :set wrap!<cr>
" toggle number mode
nmap <leader>mn :set number!<cr>
" <leader>o: only
nnoremap <leader>o :only<cr>

" Function: toggle vim's mouse control {{{
function! ToggleMouse()
	" check if mouse is enabled
	if &mouse == 'a'
		" disable mouse
		set mouse=
		echo "Mouse control mode: OFF"
	else
		" enable mouse everywhere
		set mouse=a
		echo "Mouse control mode: ON"
	endif
endfunc
"}}}
"
" toggle mouse mode
nmap <leader>mm :call ToggleMouse()<cr>

" Function: toggle copy mode {{{
let s:is_copy_mode = 0
function! ToggleCopyMode()
	if s:is_copy_mode == 0
		set mouse=
		set nonumber
		set nolist
		echo "Copy mode: ON"
		let s:is_copy_mode = 1
	else
		set mouse=a
		set number
		set list
		echo "Copy mode: OFF"
		let s:is_copy_mode = 0
	endif
endfunc
"}}}
"
" toggle mouse copy mode
nmap <leader>mc :call ToggleCopyMode()<cr>

" Function: Append modeline after last line in buffer. {{{
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
	let l:modeline = printf(" vim: set ft=%s ts=%d sts=%d sw=%d tw=%d %set fdm=%s :",
				\   &filetype, &tabstop, &softtabstop, &shiftwidth, &textwidth,
				\   &expandtab ? '' : 'no', &fdm)
	let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
	call append(line("$"), l:modeline)
endfunction
"}}}

nnoremap <silent> <localleader>ml :call AppendModeline()<cr>

" Fast exit from Insert Mode
"inoremap kj <esc>

" Function: Generating tags. {{{
function! MakeTagsAndCscope()
	if s:is_cygwin || s:is_macos || s:is_linux64 || s:is_linux32 || s:is_unix
		let more_save = &more
		set nomore
		let currentdir = getcwd()
		if (!exists('b:ctags_db_path'))
			let b:ctags_db_path = projectroot#guess()
		elseif (empty(b:ctags_db_path))
			let b:ctags_db_path = projectroot#guess()
		endif
		silent execute "cd " . b:ctags_db_path
		call system("make --silent --dry-run tags")
		if v:shell_error == 0
			silent execute "!make tags"
		else
			silent execute "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q --verbose=yes"
		endif
		silent execute "set tags=" . b:ctags_db_path
		silent execute "cd " . currentdir

		let currentdir = getcwd()
		if (!exists('b:cscope_db_path'))
			let b:cscope_db_path = projectroot#guess()
		elseif (empty(b:cscope_db_path))
			let b:cscope_db_path = projectroot#guess()
		endif
		silent execute "cd " . b:cscope_db_path
		call system("make --silent --dry-run cscope")
		if v:shell_error == 0
			silent execute "!make cscope"
		else
			silent execute "!rm -fv cscope.files"
			silent execute "!find . \\( -name '*.c' -o -name '*.cpp' -o -name '*.cc' -o -name '*.h' -o -name '*.s' -o -name '*.S' \\) -print > cscope.files"
			silent execute "!cscope -v -q -b -i cscope.files $*"
		endif
		set nocsverb " suppress 'duplicate connection' error
		silent execute "cscope add " . b:cscope_db_path . "/cscope.out " . b:cscope_db_path
		silent execute "cscope reset"
		set csverb   " switch back to verbose mode
		execute "cd " . currentdir
		let &more = more_save
		redraw!
	elseif s:is_win32 || s:is_win64
		" TODO: add routine for generating ctags and cscope for windows.
	endif
endfunction
"}}}

" Function: Cleaning tags. {{{
function! CleaningTagsAndCscope()
	if s:is_cygwin || s:is_macos || s:is_linux64 || s:is_linux32 || s:is_unix
		let more_save = &more
		set nomore
		let currentdir = getcwd()

		if (exists('b:ctags_db_path'))
			if (!empty(b:ctags_db_path))
				silent execute "cd " . b:ctags_db_path
			endif
		endif
		silent execute "!rm -fv tags TAGS"

		if (exists('b:cscope_db_path'))
			if (!empty(b:cscope_db_path))
				silent execute "cd " . b:cscope_db_path
			endif
		endif
		silent execute "!rm -fv cscope.out cscope.in.out cscope.po.out cscope.out.in cscope.out.po cscope.files"

		execute "cd " . currentdir
		let &more = more_save
		redraw!
	elseif s:is_win32 || s:is_win64
		" TODO: add routine for cleaning ctags and cscope for windows.
	endif
endfunction
"}}}

" <leader>tg <leader>te : generating/cleaning ctags and cscope
nmap <leader>tg :call MakeTagsAndCscope()<cr>
nmap <leader>te :call CleaningTagsAndCscope()<cr>

" <leader>s: Spell checking shortcuts
nnoremap <leader>ss :setlocal spell!<cr>
nnoremap <leader>sj ]s
nnoremap <leader>sk [s
nnoremap <leader>sa zg]s
nnoremap <leader>sd 1z=
nnoremap <leader>sf z=

" <leader>f: Open Quickfix
nnoremap <silent> <leader>f :botright copen<cr>

" <f1>: Help
nmap <f1> [unite]h<cr>

" Ctrl-e: Find (e)verything
nmap <c-e> [unite]f

" Ctrl-r: Command history using Unite
silent! nunmap <c-r>
"nmap <c-r> [unite];

" Ctrl-r: Reopen last unite window
nnoremap <c-r> :UniteResume<cr>

" Ctrl-y: Yanks
nmap <c-y> [unite]y

" Ctrl-p: Find MRU and buffers
nmap <c-p> [unite]u

" Ctrl-\: Quick outline
nmap <silent> <c-\> [unite]o

" Ctrl-sa: Reopen last grep window
nnoremap <c-s><c-a> :UniteResume -buffer-name=grep<cr>
" Ctrl-ss: (S)earch word under cur(s)or in current directory
nnoremap <c-s><c-s> :Unite -buffer-name=grep grep:.::<c-r><c-w><cr>
" Ctrl-sd: (S)earch word in current (d)irectory (prompt for word)
nnoremap <c-s><c-d> :Unite -buffer-name=grep grep:.<cr>
" Ctrl-sf: Quickly (s)earch in (f)ile
nmap <c-s><c-f> [unite]/
" Ctrl-sr: Easier (s)earch and (r)eplace
nnoremap <c-s><c-r> :%s/<c-r><c-w>//gc<left><left><left>
" Ctrl-sw: Quickly surround word
nmap <c-s><c-w> ysiw
" Ctrl-c: (C)hange (c)urrent directory
nmap <c-c> [unite]d
" Ctrl-/: A more powerful '/'
nmap <c-_> [unite]/

" Backspace: Toggle search highlight
nnoremap <bs> :set hlsearch! hlsearch?<cr>

" Enter: Highlight visual selections
xnoremap <silent> <cr> y:let @/ = @"<cr>:set hlsearch<cr>
"}}}

" Plugin: vim-projectroot {{{
let g:rootmarkers = ['.projectroot', '.git', '.hg', '.svn', '.bzr', '_darcs', 'build.xml', 'tags', 'TAGS', 'cscope.out']
function! <SID>AutoProjectRootCD()
	try
		if &ft != 'help' && &ft != 'vimshell' && &ft != 'unite'
			ProjectRootCD
		endif
	catch
		" Silently ignore invalid buffers
	endtry
endfunction
autocmd BufEnter * call <SID>AutoProjectRootCD()

nnoremap <leader>g :ProjectRootExe grep<space>
nnoremap <expr> <leader>ep ':edit '.projectroot#guess().'/'
nnoremap <expr> <leader>rg ':!touch '.getcwd().'/.projectroot'
nnoremap <expr> <leader>re ':!rm -f '.projectroot#guess().'/.projectroot'
"}}}

" Plugin: localvimrc {{{
let g:localvimrc_name = [ '.vimrc.local' ]
" add BufReadPre autocmd for apply options of Syntastic
let g:localvimrc_event = [ 'BufReadPre', 'BufWinEnter' ]
let g:localvimrc_ask = 0
"}}}

" Function: check whether current buffer is plugin's or not {{{
let s:Plugin_Buffer_List = ["\\[BufExplorer\\]", "NERD_tree.*", "__Tagbar__"]
function! IsHerePluginBuffer()
	for l:item in s:Plugin_Buffer_List
		if match(bufname('%'), l:item) >= 0
			return 1
		endif
	endfor
	" special handle for fugitive window
	if getbufvar(@%, 'fugitive_type') == 'index'
		return 1
	endif
	if getbufvar(@%, '&buftype') == 'quickfix'
		return 1
	endif
	return 0
endfunc
"}}}

" Plugin: Unite {{{
" Map space to the prefix for Unite
nnoremap [unite] <nop>
nmap <space> [unite]

" General fuzzy search
nnoremap <silent> [unite]<space> :<c-u>Unite
			\ -buffer-name=files buffer file_mru bookmark file_rec/async<cr>

" Quick registers
nnoremap <silent> [unite]r :<c-u>Unite -buffer-name=register register<cr>

" Quick buffer and mru
nnoremap <silent> [unite]u :<c-u>Unite -buffer-name=buffers file_mru buffer<cr>

" Quick yank history
nnoremap <silent> [unite]y :<c-u>Unite -buffer-name=yanks history/yank<cr>

" Quick outline
nnoremap <silent> [unite]o :<c-u>Unite -buffer-name=outline -vertical outline<cr>

" Quick tag
nnoremap <silent> [unite]t :<c-u>Unite -buffer-name=tag tag<cr>

" Quick sessions (projects)
nnoremap <silent> [unite]p :<c-u>Unite -buffer-name=sessions session<cr>

" Quick quickfix
nnoremap <silent> [unite]q :<c-u>Unite -buffer-name=quickfix quickfix<cr>

" Quick location list
nnoremap <silent> [unite]l :<c-u>Unite -buffer-name=location_list location_list<cr>

" Quick sources
nnoremap <silent> [unite]a :<c-u>Unite -buffer-name=sources source<cr>

" Quick snippet
" nnoremap <silent> [unite]s :<c-u>Unite -buffer-name=snippets snippet<cr>
nnoremap <silent> [unite]s :<c-u>Unite -buffer-name=snippets ultisnips<cr>

" Quickly switch lcd
nnoremap <silent> [unite]d
			\ :<c-u>Unite -buffer-name=change-cwd -default-action=cd directory_mru directory_rec/async<cr>

" Quick file search
nnoremap <silent> [unite]f :<c-u>Unite -buffer-name=files file_rec/async file/new<cr>

" Quick grep from cwd
nnoremap <silent> [unite]g :<c-u>Unite -buffer-name=grep grep:.<cr>

" Quick help
nnoremap <silent> [unite]h :<c-u>Unite -buffer-name=help help<cr>

" Quick line using the word under cursor
" nnoremap <silent> [unite]l :<c-u>UniteWithCursorWord -buffer-name=search_file line<cr>

" Quick line
nnoremap <silent> [unite]/ :<c-u>Unite -buffer-name=line line<cr>

" Quick MRU search
nnoremap <silent> [unite]m :<c-u>Unite -buffer-name=mru file_mru<cr>

" Quick find
nnoremap <silent> [unite]n :<c-u>Unite -buffer-name=find find:.<cr>

" Quick commands
nnoremap <silent> [unite]c :<c-u>Unite -buffer-name=commands command<cr>

" Quick bookmarks
nnoremap <silent> [unite]b :<c-u>Unite -buffer-name=bookmarks bookmark<cr>

" Fuzzy search from current buffer
" nnoremap <silent> [unite]b :<c-u>UniteWithBufferDir
" \ -buffer-name=files -prompt=%\  buffer file_mru bookmark file<cr>

" Quick commands
nnoremap <silent> [unite]; :<c-u>Unite -buffer-name=history -default-action=edit history/command command<cr>

" Quick mappings
nnoremap <silent> [unite]k :<c-u>Unite -buffer-name=mapping mapping<cr>

" Custom Unite settings
autocmd MyAutoCmd FileType unite call s:unite_settings()
function! s:unite_settings()
	" map <esc> key overriding and some escape sequence handling. {{{
	" NOTE: frankly speaking, I doubt that if I am doing right..
	nmap <buffer> <esc> <plug>(unite_exit)
	imap <buffer> <esc> <plug>(unite_insert_leave)
	imap <buffer> <esc><esc> <plug>(unite_exit)
	nnoremap <buffer> <esc>[ <esc>[
	inoremap <buffer> <esc>[ <esc>[
	nnoremap <buffer> <esc>[O <esc>[O
	inoremap <buffer> <esc>[O <esc>[O
	nnoremap <buffer> <esc>[[ <esc>[[
	inoremap <buffer> <esc>[[ <esc>[[
	inoremap <buffer> <esc><esc>[ <esc><esc>[
	"}}}

	nmap <buffer> <home> <plug>(unite_cursor_top)
	nmap <buffer> <end> <plug>(unite_cursor_bottom)
	" imap <buffer> <c-j> <plug>(unite_select_next_line)
	imap <buffer> <c-j> <plug>(unite_insert_leave)
	nmap <buffer> <c-j> <plug>(unite_loop_cursor_down)
	nmap <buffer> <c-k> <plug>(unite_loop_cursor_up)
	"nmap <buffer> <tab> <plug>(unite_loop_cursor_down)
	"nmap <buffer> <s-tab> <plug>(unite_loop_cursor_up)
	"imap <buffer> <c-a> <plug>(unite_choose_action)
	nmap <buffer> M     <plug>(unite_disable_max_candidates)
	nmap <buffer> <tab> <plug>(unite_choose_action)
	imap <buffer> <tab> <plug>(unite_choose_action)
	" imap <buffer> jj <plug>(unite_insert_leave)
	imap <buffer> <c-w> <plug>(unite_delete_backward_word)
	imap <buffer> <c-u> <plug>(unite_delete_backward_path)
	imap <buffer> '     <plug>(unite_quick_match_default_action)
	nmap <buffer> '     <plug>(unite_quick_match_default_action)
	nmap <buffer> <c-r> <plug>(unite_redraw)
	imap <buffer> <c-r> <plug>(unite_redraw)
	inoremap <silent> <buffer> <expr> <c-s> unite#do_action('split')
	nnoremap <silent> <buffer> <expr> <c-s> unite#do_action('split')
	inoremap <silent> <buffer> <expr> <c-v> unite#do_action('vsplit')
	nnoremap <silent> <buffer> <expr> <c-v> unite#do_action('vsplit')

	let unite = unite#get_current_unite()
	if unite.buffer_name =~# '^search'
		nnoremap <silent> <buffer> <expr> r     unite#do_action('replace')
	else
		nnoremap <silent> <buffer> <expr> r     unite#do_action('rename')
	endif

	nnoremap <silent> <buffer> <expr> cd     unite#do_action('lcd')

	" Using Ctrl-\ to trigger outline, so close it using the same keystroke
	if unite.buffer_name =~# '^outline'
		imap <buffer> <c-\> <plug>(unite_exit)
	endif

	" Using Ctrl-/ to trigger line, close it using same keystroke
	if unite.buffer_name =~# '^line'
		imap <buffer> <c-_> <plug>(unite_exit)
	endif
endfunction

" Use the fuzzy matcher for everything, except grep, line and etc. see the docs.
call unite#filters#matcher_default#use(['matcher_fuzzy'])
" Use the selecta sorter for all source.
if has('ruby')
	call unite#filters#sorter_default#use(['sorter_selecta'])
else
	call unite#filters#sorter_default#use(['sorter_rank'])
endif

" Global default context
call unite#custom#profile('default', 'context', {
			\   'safe': 0,
			\   'auto_expand': 1,
			\   'start_insert': 1,
			\   'max_candidates': 0,
			\   'update_time': 200,
			\   'winheight': 20,
			\   'winwidth': 40,
			\   'direction': 'botright',
			\   'no_auto_resize': 0,
			\   'prompt_direction': 'below',
			\   'cursor_line_highlight': 'PmenuSel',
			\   'cursor_line_time': '0.2',
			\   'candidate_icon': '-',
			\   'marked_icon': '*',
			\   'prompt' : '> '
			\})

call unite#custom#profile('outline', 'context', {
			\   'auto_expand': 0,
			\   'start_insert': 1,
			\   'max_candidates': 0,
			\   'no_auto_resize': 1,
			\   'prompt_direction': 'top',
			\})

" Set up some custom ignores
call unite#custom#source('file_rec,file_rec/async,file_mru,file,buffer,grep',
			\   'ignore_pattern',
			\   join([
			\       '\.git/',
			\       '\.svn/',
			\       '\.hg/',
			\       'git5/.*/review/',
			\       'google/obj/',
			\       'tmp/',
			\       '\.sass-cache',
			\       'node_modules/',
			\       'bower_components/',
			\       'dist/',
			\       '\.git5_specs/',
			\       '\.pyc',
			\       '\.dropbox/',
			\       '\.cache/'
			\   ],
			\   '\|')
			\)

" Enable history yank source
let g:unite_source_history_yank_enable = 1

let g:neomru#file_mru_limit = 1000

let g:neomru#filename_format = ':~:.'
let g:neomru#time_format = ''

" For ack.
if executable('ack-grep')
	let g:unite_source_grep_command = 'ack-grep'
	" Match whole word only. This might/might not be a good idea
	let g:unite_source_grep_default_opts = '--no-heading --no-color -w'
	let g:unite_source_grep_recursive_opt = ''
elseif executable('ack')
	let g:unite_source_grep_command = 'ack'
	let g:unite_source_grep_default_opts = '--no-heading --no-color -w'
	let g:unite_source_grep_recursive_opt = ''
endif

let g:unite_source_rec_max_cache_files = 99999
"}}}

" Plugin: vim-session {{{
let g:session_default_overwrite = 1
let g:session_autosave = 'yes'
let g:session_autoload = 'no'
let g:session_persist_colors = 0
let g:session_menu = 0
let g:session_verbose_messages = 0

" Pop up session selection if no file is specified
autocmd MyAutoCmd VimEnter * call s:unite_session_on_enter()
function! s:unite_session_on_enter()
	if !argc() && !exists("g:start_session_from_cmdline") &&
				\   !(&ft == 'man' ||
				\   (exists("b:current_syntax") && b:current_syntax == "man"))
		Unite -buffer-name=sessions session
	endif
endfunction
"}}}

" Unite source for Xolox's vim-session {{{
" it's from https://github.com/rafi/vim-config/blob/master/autoload/unite/sources/session.vim
" it's modified by wonmin82, it can be in .vimrc now
" unite/sources/session - Xolox's vim-session
" Maintainer: Rafael Bodill <justrafi at gmail dot com>
" Author: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Jason Housley <HousleyJK@gmail.com>
" Last Modified: 01 Oct 2014
" License: MIT license
"-------------------------------------------------
" Variables
call unite#util#set_default('g:unite_source_session_allow_rename_locked', 0)

function! s:unite_sources_session_save(filename, ...)
	if unite#util#is_cmdwin()
		return
	endif
	let filename = s:get_session_path(a:filename)
	silent execute 'SaveSession!' filename
endfunction

function! s:unite_sources_session_load(filename)
	if unite#util#is_cmdwin()
		return
	endif
	let filename = s:get_session_path(a:filename)
	silent execute 'OpenSession' filename
endfunction

function! s:unite_sources_session_complete(arglead, cmdline, cursorpos)
	let directory = xolox#misc#path#absolute(g:session_directory)
	let sessions = split(glob(directory.'/*'.g:session_extension), '\n')
	" let sessions = xolox#session#complete_names_with_suggestions('', 0, 0)
	return filter(sessions, 'stridx(v:val, a:arglead) == 0')
endfunction

let s:unite_source_session = {
			\   'name': 'session',
			\   'description': 'candidates from session list',
			\   'default_action': 'load',
			\   'alias_table': { 'edit' : 'open' },
			\   'action_table': {}
			\}

function! s:unite_source_session.gather_candidates(args, context)
	let directory = xolox#misc#path#absolute(g:session_directory)
	let sessions = split(glob(directory.'/*'.g:session_extension), '\n')
	let candidates = map(copy(sessions), "{
				\   'word': xolox#session#path_to_name(v:val),
				\   'kind': 'file',
				\   'action__path': v:val,
				\   'action__directory': unite#util#path2directory(v:val)
				\}")
	return candidates
endfunction

" New session only source
let s:unite_source_session_new = {
			\   'name': 'session/new',
			\   'description': 'session candidates from input',
			\   'default_action': 'save',
			\   'action_table': {}
			\}

function! s:unite_source_session_new.change_candidates(args, context)
	let input = substitute(
				\   substitute(a:context.input, '\\ ', ' ', 'g'),
				\   '^\a\+:\zs\*/', '/', ''
				\)
	if input == ''
		return []
	endif
	" Return new session candidate
	return [{'word': input, 'abbr': '[new session] ' . input,
				\   'action__path': input }] +
				\   s:unite_source_session.gather_candidates(a:args, a:context)
endfunction

" Actions
let s:unite_source_session.action_table.load = {
			\   'description': 'load this session',
			\}

function! s:unite_source_session.action_table.load.func(candidate)
	call s:unite_sources_session_load(a:candidate.word)
endfunction

let s:unite_source_session.action_table.delete = {
			\   'description': 'delete from session list',
			\   'is_invalidate_cache': 1,
			\   'is_quit': 0,
			\   'is_selectable': 1
			\}

function! s:unite_source_session.action_table.delete.func(candidates)
	for candidate in a:candidates
		if input('Really delete session file: '
					\   . candidate.action__path . '? ') =~? 'y\%[es]'
			execute 'DeleteSession' candidate.word
		endif
	endfor
endfunction

let s:unite_source_session.action_table.rename = {
			\   'description': 'rename session name',
			\   'is_invalidate_cache': 1,
			\   'is_quit': 0,
			\   'is_selectable': 1
			\}

function! s:unite_source_session.action_table.rename.func(candidates)
	let current_session = xolox#session#find_current_session()
	let rename_locked = g:unite_source_session_allow_rename_locked
	for candidate in a:candidates
		if rename_locked || current_session != candidate.word
			let session_name = input(printf(
						\   'New session name: %s -> ', candidate.word),
						\   candidate.word)
			if session_name != '' && session_name !=# candidate.word
				let new_name = g:session_directory.'/'.session_name.g:session_extension
				let from_path = expand(candidate.action__path)
				let to_path = expand(new_name)
				call rename(from_path, to_path)
				" Rename also lock file
				if filereadable(from_path.'.lock')
					" TODO: Change vim-session current session
					call rename(from_path.'.lock', to_path.'.lock')
				endif
			endif
		else
			call unite#print_source_error(
						\   [ 'The session "'.candidate.word.'" is locked.' ],
						\   'session')
		endif
	endfor
endfunction

let s:unite_source_session.action_table.save = {
			\   'description': 'save current session as candidate',
			\   'is_invalidate_cache': 1,
			\   'is_selectable': 1
			\}

function! s:unite_source_session.action_table.save.func(candidates)
	for candidate in a:candidates
		if input('Really save the current session as: '
					\   . candidate.word . '? ') =~? 'y\%[es]'
			call s:unite_sources_session_save(candidate.word)
		endif
	endfor
endfunction

let s:unite_source_session_new.action_table.save = s:unite_source_session.action_table.save

function! s:unite_source_session_new.action_table.save.func(candidates)
	let current_tab = tabpagenr()
	tabdo windo if &ft == 'vimfiler' | bd | endif
	execute 'tabnext '.current_tab
	for candidate in a:candidates
		" Second argument means check if exists
		call s:unite_sources_session_save(candidate.word, 1)
	endfor
endfunction

function! s:get_session_path(filename)
	let filename = a:filename
	if filename == ''
		let filename = g:session_default_name
	endif
	if filename == ''
		let filename = v:this_session
	endif
	return filename
endfunction

call unite#define_source(s:unite_source_session)
call unite#define_source(s:unite_source_session_new)
"}}}

" Plugin: Vimfiler {{{
" TODO Look into Vimfiler more
" Example at: https://github.com/hrsh7th/dotfiles/blob/master/vim/.vimrc
nnoremap <silent> <expr> <leader>vf MyOpenExplorerCommand()
function! MyOpenExplorerCommand()
	return printf(":\<c-u>VimFilerBufferDir -buffer-name=%s -split -auto-cd -toggle -no-quit -winwidth=%s\<cr>",
				\   g:my_vimfiler_explorer_name,
				\   g:my_vimfiler_winwidth)
endfunction

let g:vimfiler_as_default_explorer = 1
let g:vimfiler_tree_leaf_icon = ' '
if 0
	if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
		let g:vimfiler_tree_opened_icon = '▾'
		let g:vimfiler_tree_closed_icon = '▸'
		" let g:vimfiler_file_icon = ' '
		let g:vimfiler_marked_file_icon = '✓'
	endif
endif
let g:vimfiler_tree_opened_icon = '-'
let g:vimfiler_tree_closed_icon = '+'
" let g:vimfiler_file_icon = ' '
let g:vimfiler_marked_file_icon = '*'
" let g:vimfiler_readonly_file_icon = ' '
let g:my_vimfiler_explorer_name = 'explorer'
let g:my_vimfiler_winwidth = 30
let g:vimfiler_safe_mode_by_default = 0
" let g:vimfiler_directory_display_top = 1

autocmd MyAutoCmd FileType vimfiler call s:vimfiler_settings()
function! s:vimfiler_settings()
	nmap <buffer> <expr> <cr> vimfiler#smart_cursor_map("\<plug>(vimfiler_expand_tree)", "e")
endfunction
"}}}

" Plugin: VimShell {{{
" NOTE: VimShell must be exited by 'exit' command in vimshell
"		Otherwise, syntax highlight will be turned off.
let g:vimshell_prompt = "% "
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
autocmd MyAutoCmd FileType vimshell call s:vimshell_settings()
function! s:vimshell_settings()
	call vimshell#altercmd#define('g', 'git')
	call vimshell#execute('export MANPAGER=')
endfunction
"}}}

" Plugin: bufexplorer {{{
nnoremap <silent> <expr> <f3> IsHerePluginBuffer() ? '\<nop>' : ':BufExplorer<cr>'
inoremap <silent> <expr> <f3> IsHerePluginBuffer() ? '\<nop>' : '<esc>:BufExplorer<cr>a'
"}}}

" Plugin: fugitive {{{
" :Gstatus
"nnoremap <f5> :call IsHerePluginBuffer()<cr>
nnoremap <silent> <expr> <f5> IsHerePluginBuffer() ? '\<nop>' : ':Gstatus<cr>'
inoremap <silent> <expr> <f5> IsHerePluginBuffer() ? '\<nop>' : '<esc>:Gstatus<cr>'
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gp :Git push<cr>
nnoremap <leader>gr :Gremove<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gw :Gwrite<cr>
" Quickly stage, commit, and push the current file. Useful for editing .vimrc
nnoremap <leader>gg :Gwrite<cr>:Gcommit -m 'update'<cr>:Git push<cr>
"}}}

" Plugin: Unite.vim {{{
nnoremap <c-@> :Unite -start-insert -auto-resize buffer file file_rec/async file_mru<cr>
nnoremap <leader><@> :Unite<cr>
"}}}

" Plugin: airline {{{
let g:airline_theme = 'solarized'

let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 1
let g:airline#extensions#whitespace#checks = [ 'indent', 'trailing' ]
let g:airline#extensions#bufferline#enabled = 1
let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'
"}}}

" Plugin: bufferline {{{
let g:bufferline_show_bufnr = 1
let g:bufferline_rotate = 2
"}}}

" Plugin: tagbar {{{
nnoremap <silent> <expr> <f4> @% != "[BufExplorer]" ? ':TagbarToggle<cr>' : '\<nop>'
inoremap <silent> <expr> <f4> @% != "[BufExplorer]" ? '<esc>:TagbarToggle<cr>a' : '\<nop>'

try
	let g:tagbar_ctags_bin = exepath('ctags')
catch
	let g:tagbar_ctags_bin = 'ctags'
endtry
let g:tagbar_left = 0
let g:tagbar_iconchars = ['+', '-']

if 1 " 1: open only when used, 0: open always
	" tagbar opened only when used
	let g:tagbar_width = 30
	let g:tagbar_compact = 1
	let g:tagbar_indent = 1
	let g:tagbar_autoclose = 1
	let g:tagbar_autofocus = 1
else
	" always open tagbar when available
	let g:tagbar_width = 25
	let g:tagbar_compact = 1
	let g:tagbar_indent = 1
	let g:tagbar_autoclose = 0
	let g:tagbar_autofocus = 0
	autocmd BufEnter * nested :call tagbar#autoopen(0)
endif
"}}}

" Plugin: NERDTree {{{
nnoremap <silent> <expr> <f2> @% != "[BufExplorer]" ? ':NERDTreeToggle<cr>' : '\<nop>'
inoremap <silent> <expr> <f2> @% != "[BufExplorer]" ? '<esc>:NERDTreeToggle<cr>a' : '\<nop>'

let g:NERDTreeShowHidden = 1
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '~'
let g:NERDTreeIgnore = ['\~$', '\.swp$', '\.git', '\.hg', '\.svn', '\.bzr']
" Close vim if the only window open is nerdtree
autocmd MyAutoCmd BufEnter *
			\   if (winnr("$") == 1 && exists("b:NERDTreeType")
			\      && b:NERDTreeType == "primary") |
			\       q |
			\   endif
"}}}

" Plugin: NERDCommenter {{{
" Always leave a space between the comment character and the comment
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 0
let g:NERDDefaultAlign = 'both'
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
"}}}

" Plugin: netrw {{{
let g:netrw_altv = 1 " when navigating a folder,
" hitting <v> opens a window at right side (default is left side)
"}}}

" Plugin: IndentConsistencyCop {{{
nmap <leader>icc :IndentConsistencyCop<cr>
let g:indentconsistencycop_highlighting = 'sglmf:3'
let g:indentconsistencycop_non_indent_pattern = ' \*\%([*/ \t]\|$\)'
"}}}

" Plugin: IndentConsistencyCopAutoCmds {{{
" Turn off by autocmd because the interface is so annoying.
augroup MyAutoCmd
	autocmd BufNewFile * execute ":IndentConsistencyCopAutoCmdsOff"
	autocmd BufReadPre * execute ":IndentConsistencyCopAutoCmdsOff"
augroup END
nmap <leader>ice :IndentConsistencyCopAutoCmdsOn<cr>
nmap <leader>icd :IndentConsistencyCopAutoCmdsOff<cr>
let g:indentconsistencycop_CheckOnLoad = 0
let g:indentconsistencycop_CheckAfterWrite = 1
let g:indentconsistencycop_CheckAfterWriteMaxLinesForImmediateCheck = 1000
"}}}

" Plugin: vim-better-whitespace {{{
nmap <leader>mb :ToggleWhitespace<cr>
highlight link ExtraWhitespace SpellBad
let g:better_whitespace_filetypes_blacklist = ['vimshell', 'unite', 'help']
"}}}

" Plugin: SrcExplorer {{{
" // The switch of the Source Explorer
nmap <f11> :SrcExplToggle<cr>

" // Set the height of Source Explorer window
let g:SrcExpl_winHeight = 8

" // Set 100 ms for refreshing the Source Explorer
let g:SrcExpl_refreshTime = 100

" // Set "Enter" key to jump into the exact definition context
let g:SrcExpl_jumpKey = "<enter>"

" // Set "Space" key for back from the definition context
let g:SrcExpl_gobackKey = "<space>"

" // In order to Avoid conflicts, the Source Explorer should know what plugins
" // are using buffers. And you need add their bufname into the list below
" // according to the command ":buffers!"
let g:SrcExpl_pluginList = [
			\   "__Tag_List__",
			\   "_NERD_tree_",
			\   "Source_Explorer",
			\   "[File List]",
			\   "[Buf List]",
			\   "[BufExplorer]"
			\]
" // Enable/Disable the local definition searching, and note that this is not
" // guaranteed to work, the Source Explorer doesn't check the syntax for now.
" // It only searches for a match with the keyword according to command 'gd'
let g:SrcExpl_searchLocalDef = 1

" // Let the Source Explorer update the tags file when opening
let g:SrcExpl_isUpdateTags = 1

" // Use program 'ctags' with argument '--sort=foldcase -R' to create or
" // update a tags file
let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."

" // Set "<s-f11>" key for updating the tags file artificially
let g:SrcExpl_updateTagsKey = "<s-f11>"
"}}}

" Plugin: Tabularize {{{
nmap <leader>a= :Tabularize /=<cr>
vmap <leader>a= :Tabularize /=<cr>
nmap <leader>a: :Tabularize /:<cr>
vmap <leader>a: :Tabularize /:<cr>
nmap <leader>a:: :Tabularize /:\zs<cr>
vmap <leader>a:: :Tabularize /:\zs<cr>
nmap <leader>a, :Tabularize /,<cr>
vmap <leader>a, :Tabularize /,<cr>
nmap <leader>a\| :Tabularize /\|<cr>
vmap <leader>a\| :Tabularize /\|<cr>
"}}}

" Detect clang tools {{{
let s:clang_tools_suffixes = [
			\   '',
			\   '-11',
			\   '-11.0',
			\   '-10',
			\   '-10.0',
			\   '-9',
			\   '-9.0',
			\   '-8',
			\   '-8.0',
			\   '-7',
			\   '-7.0',
			\   '-6',
			\   '-6.0',
			\   '-5',
			\   '-5.0',
			\   '-4',
			\   '-4.0',
			\   '-3.9',
			\   '-3.8',
			\   '-3.7',
			\   '-3.6',
			\   '-3.5',
			\   '-3.4'
			\]

function! s:clang_format_detect()
	let l:base_command = 'clang-format'

	for clang_tools_version in s:clang_tools_suffixes
		if executable(l:base_command . clang_tools_version)
			try
				let l:command = exepath(l:base_command . clang_tools_version)
			catch
				let l:command = l:base_command . clang_tools_version
			endtry
			return l:command
		endif
	endfor

	throw l:base_command . ' could not be detected.'
endfunction

function! s:clang_tidy_detect()
	let l:base_command = 'clang-tidy'

	for clang_tools_version in s:clang_tools_suffixes
		if executable(l:base_command . clang_tools_version)
			try
				let l:command = exepath(l:base_command . clang_tools_version)
			catch
				let l:command = l:base_command . clang_tools_version
			endtry
			return l:command
		endif
	endfor

	throw l:base_command . ' could not be detected.'
endfunction

function! s:clang_check_detect()
	let l:base_command = 'clang-check'

	for clang_tools_version in s:clang_tools_suffixes
		if executable(l:base_command . clang_tools_version)
			try
				let l:command = exepath(l:base_command . clang_tools_version)
			catch
				let l:command = l:base_command . clang_tools_version
			endtry
			return l:command
		endif
	endfor

	throw l:base_command . ' could not be detected.'
endfunction

"}}}

" Plugin: syntastic {{{
nmap <leader>ms :SyntasticToggleMode<cr>
nmap <leader>sc :SyntasticCheck<cr>
nmap <leader>sr :SyntasticReset<cr>

if 0
	let g:syntastic_error_symbol = '✘'
	let g:syntastic_warning_symbol = '⚠'
endif
let g:syntastic_error_symbol = 'E>'
let g:syntastic_warning_symbol = 'W>'
let g:syntastic_style_error_symbol = 'S>'
let g:syntastic_style_warning_symbol = 'S>'
let g:syntastic_check_on_open = 1

let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 2       " use unite location list instead.
" let g:syntastic_ignore_files = ['\m^/usr/include/', '\m\c\.h$']

try
	let s:clang_tidy_command = s:clang_tidy_detect()
	let g:syntastic_c_clang_tidy_exec = s:clang_tidy_command
	let g:syntastic_cpp_clang_tidy_exec = s:clang_tidy_command
catch
	let g:syntastic_c_clang_tidy_exec = 'clang-tidy'
	let g:syntastic_cpp_clang_tidy_exec = 'clang-tidy'
endtry
try
	let s:clang_check_command = s:clang_check_detect()
	let g:syntastic_c_clang_check_exec = s:clang_check_command
	let g:syntastic_cpp_clang_check_exec = s:clang_check_command
catch
	let g:syntastic_c_clang_check_exec = 'clang-check'
	let g:syntastic_cpp_clang_check_exec = 'clang-check'
endtry

let g:syntastic_mode_map = { "mode": "active",
			\   "active_filetypes": [],
			\   "passive_filetypes": []
			\}

" autocmd for apply localvimrc to syntastic when loading a session.
" it will trigger check twice.
" TODO: find out how to remove redundancy check.
augroup MyAutoCmd
	autocmd SessionLoadPost *
				\   if g:syntastic_check_on_open == 1 |
				\       call SyntasticCheck() |
				\   else |
				\       call SyntasticReset() |
				\   endif
augroup END
"}}}

" Plugin: YouCompleteMe {{{
" do not use ycm as syntastic checker.
let g:ycm_register_as_syntastic_checker = 0 "default 1
let g:ycm_show_diagnostics_ui = 0 "default 1

"will put icons in Vim's gutter on lines that have a diagnostic set.
"Turning this off will also turn off the YcmErrorLine and YcmWarningLine
"highlighting
let g:ycm_enable_diagnostic_signs = 0
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_always_populate_location_list = 1 "default 0
let g:ycm_open_loclist_on_ycm_diags = 1 "default 1
let g:ycm_seed_identifiers_with_syntax = 1 "default 0

let g:ycm_complete_in_strings = 1 "default 1
let g:ycm_collect_identifiers_from_tags_files = 1 "default 0, set to 0 if tag file isn't in local.
let g:ycm_path_to_python_interpreter = '' "default ''

let g:ycm_server_use_vim_stdout = 0 "default 0 (logging to console)
let g:ycm_server_log_level = 'info' "default info

let g:ycm_global_ycm_extra_conf = $DOTVIMPATH . '/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0

let g:ycm_goto_buffer_command = 'same-buffer' "[ 'same-buffer', 'horizontal-split', 'vertical-split', 'new-tab' ]
let g:ycm_filetype_whitelist = { '*': 1 }
let g:ycm_key_invoke_completion = '<c-q>'

nnoremap <f12> :YcmForceCompileAndDiagnostics<cr>

augroup MyAutoCmd
	autocmd CursorMovedI * if pumvisible() == 0 | silent! pclose | endif
	autocmd InsertLeave * if pumvisible() == 0 | silent! pclose | endif
augroup END

let g:ycm_key_list_select_completion = [ '<c-n>', '<c-j>', '<down>' ]
let g:ycm_key_list_previous_completion = [ '<c-p>', '<c-k>', '<up>' ]
"}}}

" Plugin: IndentTab {{{
let g:IndentTab = 1
" Determine where the buffer's indent settings are applied. Elsewhere, spaces
" are used for alignment. Comma-separated list of the following values:
"     indent:         Initial whitespace at the beginning of a line.
"     commentprefix:  Initial whitespace after a comment prefix, in case the line
"                     begins with the comment prefix, not any indent.
"     comment:        Inside comments, as determined by syntax highlighting.
"     string:         Inside strings, as determined by syntax highlighting.
"     let g:IndentTab_scopes = 'indent,commentprefix,string'
let g:IndentTab_scopes = 'indent,commentprefix,string'
let g:IndentTab_IsSuperTab = 0
"}}}

" Plugin: UltiSnips {{{
let g:UltiSnipsExpandTrigger = "<c-z>"
let g:UltiSnipsJumpForwardTrigger = "<c-j>"
let g:UltiSnipsJumpBackwardTrigger = "<c-k>"
let g:UltiSnipsListSnippets = "<c-s>"
"}}}

" Plugin: vim-clang-format {{{
" NOTE: clang-format 3.4 or later is required
" NOTE: currently, style options are ready for 3.4~11.0 only
" clang-format style options {{{
let g:clang_format_configs = {}

let g:clang_format_configs["v11.0"] = {
			\   'BasedOnStyle': 'GNU',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'Align',
			\   'AlignConsecutiveMacros': 'false',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignConsecutiveBitFields': 'false',
			\   'AlignConsecutiveDeclarations': 'false',
			\   'AlignEscapedNewlines': 'Left',
			\   'AlignOperands': 'Align',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllArgumentsOnNextLine': 'true',
			\   'AllowAllConstructorInitializersOnNextLine': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortEnumsOnASingleLine': 'false',
			\   'AllowShortBlocksOnASingleLine': 'Empty',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortLambdasOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'None',
			\   'AlwaysBreakAfterReturnType': 'None',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'MultiLine',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BraceWrapping':
			\   {
			\       'AfterCaseLabel': 'true',
			\       'AfterClass': 'true',
			\       'AfterControlStatement': 'Always',
			\       'AfterEnum': 'true',
			\       'AfterFunction': 'true',
			\       'AfterNamespace': 'true',
			\       'AfterObjCDeclaration': 'true',
			\       'AfterStruct': 'true',
			\       'AfterUnion': 'true',
			\       'AfterExternBlock': 'true',
			\       'BeforeCatch': 'true',
			\       'BeforeElse': 'true',
			\       'BeforeLambdaBody': 'true',
			\       'BeforeWhile': 'true',
			\       'IndentBraces': 'true',
			\       'SplitEmptyFunction': 'true',
			\       'SplitEmptyRecord': 'true',
			\       'SplitEmptyNamespace': 'true'
			\   },
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeInheritanceComma': 'false',
			\   'BreakInheritanceList': 'BeforeColon',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BreakConstructorInitializers': 'BeforeColon',
			\   'BreakAfterJavaFieldAnnotations': 'false',
			\   'BreakStringLiterals': 'true',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'CompactNamespaces': 'false',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DeriveLineEnding': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'FixNamespaceComments': 'true',
			\   'ForEachMacros':
			\   [
			\       'foreach',
			\       'Q_FOREACH',
			\       'BOOST_FOREACH'
			\   ],
			\   'IncludeBlocks': 'Regroup',
			\   'IncludeCategories':
			\   [
			\       {
			\           'Regex': '^"(llvm|llvm-c|clang|clang-c)/',
			\           'Priority': 2,
			\           'SortPriority': 0
			\       },
			\       {
			\           'Regex': '^(<|"(gtest|gmock|isl|json)/)',
			\           'Priority': 3,
			\           'SortPriority': 0
			\       },
			\       {
			\           'Regex': '.*',
			\           'Priority': 1,
			\           'SortPriority': 0
			\       }
			\   ],
			\   'IncludeIsMainRegex': '(Test)?$',
			\   'IncludeIsMainSourceRegex': '',
			\   'IndentCaseLabels': 'false',
			\   'IndentCaseBlocks': 'false',
			\   'IndentGotoLabels': 'true',
			\   'IndentPPDirectives': 'None',
			\   'IndentExternBlock': 'AfterExternBlock',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'InsertTrailingCommas': 'None',
			\   'JavaScriptQuotes': 'Leave',
			\   'JavaScriptWrapImports': 'true',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBinPackProtocolList': 'Auto',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCBreakBeforeNestedBlockParam': 'true',
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakAssignment': 2,
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyBreakTemplateDeclaration': 10,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'ReflowComments': 'true',
			\   'SortIncludes': 'true',
			\   'SortUsingDeclarations': 'true',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceAfterLogicalNot': 'false',
			\   'SpaceAfterTemplateKeyword': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeCpp11BracedList': 'false',
			\   'SpaceBeforeCtorInitializerColon': 'true',
			\   'SpaceBeforeInheritanceColon': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceBeforeRangeBasedForLoopColon': 'true',
			\   'SpaceInEmptyBlock': 'false',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInConditionalStatement': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'SpaceBeforeSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'StatementMacros':
			\   [
			\       'Q_UNUSED',
			\       'QT_REQUIRE_VERSION'
			\   ],
			\   'TabWidth': 4,
			\   'UseCRLF': 'false',
			\   'UseTab': 'Always',
			\   'WhitespaceSensitiveMacros':
			\   [
			\       'STRINGIZE',
			\       'PP_STRINGIZE',
			\       'BOOST_PP_STRINGIZE'
			\   ]
			\}

let g:clang_format_configs["v10.0"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'Align',
			\   'AlignConsecutiveMacros': 'false',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignConsecutiveDeclarations': 'false',
			\   'AlignEscapedNewlines': 'Left',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllArgumentsOnNextLine': 'true',
			\   'AllowAllConstructorInitializersOnNextLine': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'Empty',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortLambdasOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'None',
			\   'AlwaysBreakAfterReturnType': 'None',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'MultiLine',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BraceWrapping':
			\   {
			\       'AfterCaseLabel': 'true',
			\       'AfterClass': 'true',
			\       'AfterControlStatement': 'true',
			\       'AfterEnum': 'true',
			\       'AfterFunction': 'true',
			\       'AfterNamespace': 'true',
			\       'AfterObjCDeclaration': 'true',
			\       'AfterStruct': 'true',
			\       'AfterUnion': 'true',
			\       'AfterExternBlock': 'true',
			\       'BeforeCatch': 'true',
			\       'BeforeElse': 'true',
			\       'IndentBraces': 'true',
			\       'SplitEmptyFunction': 'true',
			\       'SplitEmptyRecord': 'true',
			\       'SplitEmptyNamespace': 'true'
			\   },
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeInheritanceComma': 'false',
			\   'BreakInheritanceList': 'BeforeColon',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BreakConstructorInitializers': 'BeforeColon',
			\   'BreakAfterJavaFieldAnnotations': 'false',
			\   'BreakStringLiterals': 'true',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'CompactNamespaces': 'false',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DeriveLineEnding': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'FixNamespaceComments': 'true',
			\   'ForEachMacros':
			\   [
			\       'foreach',
			\       'Q_FOREACH',
			\       'BOOST_FOREACH'
			\   ],
			\   'IncludeBlocks': 'Regroup',
			\   'IncludeCategories':
			\   [
			\       {
			\           'Regex': '^"(llvm|llvm-c|clang|clang-c)/',
			\           'Priority': 2,
			\           'SortPriority': 0
			\       },
			\       {
			\           'Regex': '^(<|"(gtest|gmock|isl|json)/)',
			\           'Priority': 3,
			\           'SortPriority': 0
			\       },
			\       {
			\           'Regex': '.*',
			\           'Priority': 1,
			\           'SortPriority': 0
			\       }
			\   ],
			\   'IncludeIsMainRegex': '(Test)?$',
			\   'IncludeIsMainSourceRegex': '',
			\   'IndentCaseLabels': 'false',
			\   'IndentGotoLabels': 'true',
			\   'IndentPPDirectives': 'None',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'JavaScriptQuotes': 'Leave',
			\   'JavaScriptWrapImports': 'true',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBinPackProtocolList': 'Auto',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakAssignment': 2,
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyBreakTemplateDeclaration': 10,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'ReflowComments': 'true',
			\   'SortIncludes': 'true',
			\   'SortUsingDeclarations': 'true',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceAfterLogicalNot': 'false',
			\   'SpaceAfterTemplateKeyword': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeCpp11BracedList': 'false',
			\   'SpaceBeforeCtorInitializerColon': 'true',
			\   'SpaceBeforeInheritanceColon': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceBeforeRangeBasedForLoopColon': 'true',
			\   'SpaceInEmptyBlock': 'false',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInConditionalStatement': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'SpaceBeforeSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'StatementMacros':
			\   [
			\       'Q_UNUSED',
			\       'QT_REQUIRE_VERSION'
			\   ],
			\   'TabWidth': 4,
			\   'UseCRLF': 'false',
			\   'UseTab': 'Always'
			\}

let g:clang_format_configs["v9.0"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'Align',
			\   'AlignConsecutiveMacros': 'false',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignConsecutiveDeclarations': 'false',
			\   'AlignEscapedNewlines': 'Left',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllArgumentsOnNextLine': 'true',
			\   'AllowAllConstructorInitializersOnNextLine': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortLambdasOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'None',
			\   'AlwaysBreakAfterReturnType': 'None',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'MultiLine',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BraceWrapping':
			\   {
			\       'AfterCaseLabel': 'true',
			\       'AfterClass': 'true',
			\       'AfterControlStatement': 'true',
			\       'AfterEnum': 'true',
			\       'AfterFunction': 'true',
			\       'AfterNamespace': 'true',
			\       'AfterObjCDeclaration': 'true',
			\       'AfterStruct': 'true',
			\       'AfterUnion': 'true',
			\       'AfterExternBlock': 'true',
			\       'BeforeCatch': 'true',
			\       'BeforeElse': 'true',
			\       'IndentBraces': 'true',
			\       'SplitEmptyFunction': 'true',
			\       'SplitEmptyRecord': 'true',
			\       'SplitEmptyNamespace': 'true'
			\   },
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeInheritanceComma': 'false',
			\   'BreakInheritanceList': 'BeforeColon',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BreakConstructorInitializers': 'BeforeColon',
			\   'BreakAfterJavaFieldAnnotations': 'false',
			\   'BreakStringLiterals': 'true',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'CompactNamespaces': 'false',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'FixNamespaceComments': 'true',
			\   'ForEachMacros':
			\   [
			\       'foreach',
			\       'Q_FOREACH',
			\       'BOOST_FOREACH'
			\   ],
			\   'IncludeBlocks': 'Regroup',
			\   'IncludeCategories':
			\   [
			\       {
			\           'Regex': '^"(llvm|llvm-c|clang|clang-c)/',
			\           'Priority': 2
			\       },
			\       {
			\           'Regex': '^(<|"(gtest|gmock|isl|json)/)',
			\           'Priority': 3
			\       },
			\       {
			\           'Regex': '.*',
			\           'Priority': 1
			\       }
			\   ],
			\   'IncludeIsMainRegex': '(Test)?$',
			\   'IndentCaseLabels': 'false',
			\   'IndentPPDirectives': 'None',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'JavaScriptQuotes': 'Leave',
			\   'JavaScriptWrapImports': 'true',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBinPackProtocolList': 'Auto',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakAssignment': 2,
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyBreakTemplateDeclaration': 10,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'ReflowComments': 'true',
			\   'SortIncludes': 'true',
			\   'SortUsingDeclarations': 'true',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceAfterLogicalNot': 'false',
			\   'SpaceAfterTemplateKeyword': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeCpp11BracedList': 'false',
			\   'SpaceBeforeCtorInitializerColon': 'true',
			\   'SpaceBeforeInheritanceColon': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceBeforeRangeBasedForLoopColon': 'true',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'StatementMacros':
			\   [
			\       'Q_UNUSED',
			\       'QT_REQUIRE_VERSION'
			\   ],
			\   'TabWidth': 4,
			\   'UseTab': 'Always'
			\}

let g:clang_format_configs["v8.0"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'Align',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignConsecutiveDeclarations': 'false',
			\   'AlignEscapedNewlines': 'Left',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'None',
			\   'AlwaysBreakAfterReturnType': 'None',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'MultiLine',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BraceWrapping':
			\   {
			\       'AfterClass': 'true',
			\       'AfterControlStatement': 'true',
			\       'AfterEnum': 'true',
			\       'AfterFunction': 'true',
			\       'AfterNamespace': 'true',
			\       'AfterObjCDeclaration': 'true',
			\       'AfterStruct': 'true',
			\       'AfterUnion': 'true',
			\       'AfterExternBlock': 'true',
			\       'BeforeCatch': 'true',
			\       'BeforeElse': 'true',
			\       'IndentBraces': 'true',
			\       'SplitEmptyFunction': 'true',
			\       'SplitEmptyRecord': 'true',
			\       'SplitEmptyNamespace': 'true'
			\   },
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeInheritanceComma': 'false',
			\   'BreakInheritanceList': 'BeforeColon',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BreakConstructorInitializers': 'BeforeColon',
			\   'BreakAfterJavaFieldAnnotations': 'false',
			\   'BreakStringLiterals': 'true',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'CompactNamespaces': 'false',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'FixNamespaceComments': 'true',
			\   'ForEachMacros':
			\   [
			\       'foreach',
			\       'Q_FOREACH',
			\       'BOOST_FOREACH'
			\   ],
			\   'IncludeBlocks': 'Preserve',
			\   'IncludeCategories':
			\   [
			\       {
			\           'Regex': '^"(llvm|llvm-c|clang|clang-c)/',
			\           'Priority': 2
			\       },
			\       {
			\           'Regex': '^(<|"(gtest|gmock|isl|json)/)',
			\           'Priority': 3
			\       },
			\       {
			\           'Regex': '.*',
			\           'Priority': 1
			\       }
			\   ],
			\   'IncludeIsMainRegex': '(Test)?$',
			\   'IndentCaseLabels': 'false',
			\   'IndentPPDirectives': 'None',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'JavaScriptQuotes': 'Leave',
			\   'JavaScriptWrapImports': 'true',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBinPackProtocolList': 'Auto',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakAssignment': 2,
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyBreakTemplateDeclaration': 10,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'ReflowComments': 'true',
			\   'SortIncludes': 'true',
			\   'SortUsingDeclarations': 'true',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceAfterTemplateKeyword': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeCpp11BracedList': 'false',
			\   'SpaceBeforeCtorInitializerColon': 'true',
			\   'SpaceBeforeInheritanceColon': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceBeforeRangeBasedForLoopColon': 'true',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'StatementMacros':
			\   [
			\       'Q_UNUSED',
			\       'QT_REQUIRE_VERSION'
			\   ],
			\   'TabWidth': 4,
			\   'UseTab': 'Always'
			\}

let g:clang_format_configs["v7.0"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'Align',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignConsecutiveDeclarations': 'false',
			\   'AlignEscapedNewlines': 'Left',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'None',
			\   'AlwaysBreakAfterReturnType': 'None',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'MultiLine',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BraceWrapping':
			\   {
			\       'AfterClass': 'true',
			\       'AfterControlStatement': 'true',
			\       'AfterEnum': 'true',
			\       'AfterFunction': 'true',
			\       'AfterNamespace': 'true',
			\       'AfterObjCDeclaration': 'true',
			\       'AfterStruct': 'true',
			\       'AfterUnion': 'true',
			\       'AfterExternBlock': 'true',
			\       'BeforeCatch': 'true',
			\       'BeforeElse': 'true',
			\       'IndentBraces': 'true',
			\       'SplitEmptyFunction': 'true',
			\       'SplitEmptyRecord': 'true',
			\       'SplitEmptyNamespace': 'true'
			\   },
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeInheritanceComma': 'false',
			\   'BreakInheritanceList': 'BeforeColon',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BreakConstructorInitializers': 'BeforeColon',
			\   'BreakAfterJavaFieldAnnotations': 'false',
			\   'BreakStringLiterals': 'true',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'CompactNamespaces': 'false',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'FixNamespaceComments': 'true',
			\   'ForEachMacros':
			\   [
			\       'foreach',
			\       'Q_FOREACH',
			\       'BOOST_FOREACH'
			\   ],
			\   'IncludeBlocks': 'Preserve',
			\   'IncludeCategories':
			\   [
			\       {
			\           'Regex': '^"(llvm|llvm-c|clang|clang-c)/',
			\           'Priority': 2
			\       },
			\       {
			\           'Regex': '^(<|"(gtest|gmock|isl|json)/)',
			\           'Priority': 3
			\       },
			\       {
			\           'Regex': '.*',
			\           'Priority': 1
			\       }
			\   ],
			\   'IncludeIsMainRegex': '(Test)?$',
			\   'IndentCaseLabels': 'false',
			\   'IndentPPDirectives': 'None',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'JavaScriptQuotes': 'Leave',
			\   'JavaScriptWrapImports': 'true',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBinPackProtocolList': 'Auto',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakAssignment': 2,
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyBreakTemplateDeclaration': 10,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'ReflowComments': 'true',
			\   'SortIncludes': 'true',
			\   'SortUsingDeclarations': 'true',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceAfterTemplateKeyword': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeCpp11BracedList': 'false',
			\   'SpaceBeforeCtorInitializerColon': 'true',
			\   'SpaceBeforeInheritanceColon': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceBeforeRangeBasedForLoopColon': 'true',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'TabWidth': 4,
			\   'UseTab': 'Always'
			\}

let g:clang_format_configs["v6.0"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'Align',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignConsecutiveDeclarations': 'false',
			\   'AlignEscapedNewlines': 'Left',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'None',
			\   'AlwaysBreakAfterReturnType': 'None',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'true',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BraceWrapping':
			\   {
			\       'AfterClass': 'true',
			\       'AfterControlStatement': 'true',
			\       'AfterEnum': 'true',
			\       'AfterFunction': 'true',
			\       'AfterNamespace': 'true',
			\       'AfterObjCDeclaration': 'true',
			\       'AfterStruct': 'true',
			\       'AfterUnion': 'true',
			\       'AfterExternBlock': 'true',
			\       'BeforeCatch': 'true',
			\       'BeforeElse': 'true',
			\       'IndentBraces': 'true',
			\       'SplitEmptyFunction': 'true',
			\       'SplitEmptyRecord': 'true',
			\       'SplitEmptyNamespace': 'true'
			\   },
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeInheritanceComma': 'false',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BreakConstructorInitializers': 'BeforeColon',
			\   'BreakAfterJavaFieldAnnotations': 'false',
			\   'BreakStringLiterals': 'true',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'CompactNamespaces': 'false',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'FixNamespaceComments': 'true',
			\   'ForEachMacros': [ 'foreach', 'Q_FOREACH', 'BOOST_FOREACH' ],
			\   'IncludeBlocks': 'Preserve',
			\   'IncludeCategories':
			\   [
			\       {
			\           'Regex': '^"(llvm|llvm-c|clang|clang-c)/',
			\           'Priority': 2
			\       },
			\       {
			\           'Regex': '^(<|"(gtest|gmock|isl|json)/)',
			\           'Priority': 3
			\       },
			\       {
			\           'Regex': '.*',
			\           'Priority': 1
			\       }
			\   ],
			\   'IncludeIsMainRegex': '(Test)?$',
			\   'IndentCaseLabels': 'false',
			\   'IndentPPDirectives': 'None',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'JavaScriptQuotes': 'Leave',
			\   'JavaScriptWrapImports': 'true',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakAssignment': 2,
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'ReflowComments': 'true',
			\   'SortIncludes': 'true',
			\   'SortUsingDeclarations': 'true',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceAfterTemplateKeyword': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'TabWidth': 4,
			\   'UseTab': 'Always'
			\}

let g:clang_format_configs["v5.0"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'Align',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignConsecutiveDeclarations': 'false',
			\   'AlignEscapedNewlines': 'Left',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'None',
			\   'AlwaysBreakAfterReturnType': 'None',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'true',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BraceWrapping':
			\   {
			\       'AfterClass': 'true',
			\       'AfterControlStatement': 'true',
			\       'AfterEnum': 'true',
			\       'AfterFunction': 'true',
			\       'AfterNamespace': 'true',
			\       'AfterObjCDeclaration': 'true',
			\       'AfterStruct': 'true',
			\       'AfterUnion': 'true',
			\       'BeforeCatch': 'true',
			\       'BeforeElse': 'true',
			\       'IndentBraces': 'true',
			\       'SplitEmptyFunction': 'true',
			\       'SplitEmptyRecord': 'true',
			\       'SplitEmptyNamespace': 'true'
			\   },
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeInheritanceComma': 'false',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BreakConstructorInitializers': 'BeforeColon',
			\   'BreakAfterJavaFieldAnnotations': 'false',
			\   'BreakStringLiterals': 'true',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'CompactNamespaces': 'false',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'FixNamespaceComments': 'true',
			\   'ForEachMacros': [ 'foreach', 'Q_FOREACH', 'BOOST_FOREACH' ],
			\   'IncludeCategories':
			\   [
			\       {
			\           'Regex': '^"(llvm|llvm-c|clang|clang-c)/',
			\           'Priority': 2
			\       },
			\       {
			\           'Regex': '^(<|"(gtest|gmock|isl|json)/)',
			\           'Priority': 3
			\       },
			\       {
			\           'Regex': '.*',
			\           'Priority': 1
			\       }
			\   ],
			\   'IncludeIsMainRegex': '(Test)?$',
			\   'IndentCaseLabels': 'false',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'JavaScriptQuotes': 'Leave',
			\   'JavaScriptWrapImports': 'true',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakAssignment': 2,
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'ReflowComments': 'true',
			\   'SortIncludes': 'true',
			\   'SortUsingDeclarations': 'true',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceAfterTemplateKeyword': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'TabWidth': 4,
			\   'UseTab': 'Always'
			\}

let g:clang_format_configs["v4.0"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'Align',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignConsecutiveDeclarations': 'false',
			\   'AlignEscapedNewlinesLeft': 'true',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'None',
			\   'AlwaysBreakAfterReturnType': 'None',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'true',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BraceWrapping':
			\   {
			\       'AfterClass': 'true',
			\       'AfterControlStatement': 'true',
			\       'AfterEnum': 'true',
			\       'AfterFunction': 'true',
			\       'AfterNamespace': 'true',
			\       'AfterObjCDeclaration': 'true',
			\       'AfterStruct': 'true',
			\       'AfterUnion': 'true',
			\       'BeforeCatch': 'true',
			\       'BeforeElse': 'true',
			\       'IndentBraces': 'true'
			\   },
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BreakAfterJavaFieldAnnotations': 'false',
			\   'BreakStringLiterals': 'true',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'ForEachMacros': [ 'foreach', 'Q_FOREACH', 'BOOST_FOREACH' ],
			\   'IncludeCategories':
			\   [
			\       {
			\           'Regex': '^"(llvm|llvm-c|clang|clang-c)/',
			\           'Priority': 2
			\       },
			\       {
			\           'Regex': '^(<|"(gtest|gmock|isl|json)/)',
			\           'Priority': 3
			\       },
			\       {
			\           'Regex': '.*',
			\           'Priority': 1
			\       }
			\   ],
			\   'IncludeIsMainRegex': '(Test)?$',
			\   'IndentCaseLabels': 'false',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'JavaScriptQuotes': 'Leave',
			\   'JavaScriptWrapImports': 'true',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'ReflowComments': 'true',
			\   'SortIncludes': 'true',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceAfterTemplateKeyword': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'TabWidth': 4,
			\   'UseTab': 'Always'
			\}

let g:clang_format_configs["v3.9"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'Align',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignConsecutiveDeclarations': 'false',
			\   'AlignEscapedNewlinesLeft': 'true',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'None',
			\   'AlwaysBreakAfterReturnType': 'None',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'true',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BraceWrapping':
			\   {
			\       'AfterClass': 'true',
			\       'AfterControlStatement': 'true',
			\       'AfterEnum': 'true',
			\       'AfterFunction': 'true',
			\       'AfterNamespace': 'true',
			\       'AfterObjCDeclaration': 'true',
			\       'AfterStruct': 'true',
			\       'AfterUnion': 'true',
			\       'BeforeCatch': 'true',
			\       'BeforeElse': 'true',
			\       'IndentBraces': 'true'
			\   },
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BreakAfterJavaFieldAnnotations': 'false',
			\   'BreakStringLiterals': 'true',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'ForEachMacros': [ 'foreach', 'Q_FOREACH', 'BOOST_FOREACH' ],
			\   'IncludeCategories':
			\   [
			\       {
			\           'Regex': '^"(llvm|llvm-c|clang|clang-c)/',
			\           'Priority': 2
			\       },
			\       {
			\           'Regex': '^(<|"(gtest|gmock|isl|json)/)',
			\           'Priority': 3
			\       },
			\       {
			\           'Regex': '.*',
			\           'Priority': 1
			\       }
			\   ],
			\   'IncludeIsMainRegex': '(Test)?$',
			\   'IndentCaseLabels': 'false',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'JavaScriptQuotes': 'Leave',
			\   'JavaScriptWrapImports': 'true',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'ReflowComments': 'true',
			\   'SortIncludes': 'true',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'TabWidth': 4,
			\   'UseTab': 'Always'
			\}

let g:clang_format_configs["v3.8"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'Align',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignConsecutiveDeclarations': 'false',
			\   'AlignEscapedNewlinesLeft': 'true',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'None',
			\   'AlwaysBreakAfterReturnType': 'None',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'true',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BraceWrapping':
			\   {
			\       'AfterClass': 'true',
			\       'AfterControlStatement': 'true',
			\       'AfterEnum': 'true',
			\       'AfterFunction': 'true',
			\       'AfterNamespace': 'true',
			\       'AfterObjCDeclaration': 'true',
			\       'AfterStruct': 'true',
			\       'AfterUnion': 'true',
			\       'BeforeCatch': 'true',
			\       'BeforeElse': 'true',
			\       'IndentBraces': 'true'
			\   },
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'ForEachMacros': [ 'foreach', 'Q_FOREACH', 'BOOST_FOREACH' ],
			\   'IncludeCategories':
			\   [
			\       {
			\           'Regex': '^"(llvm|llvm-c|clang|clang-c)/',
			\           'Priority': 2
			\       },
			\       {
			\           'Regex': '^(<|"(gtest|gmock|isl|json)/)',
			\           'Priority': 3
			\       },
			\       {
			\           'Regex': '.*',
			\           'Priority': 1
			\       }
			\   ],
			\   'IndentCaseLabels': 'false',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'ReflowComments': 'true',
			\   'SortIncludes': 'true',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'TabWidth': 4,
			\   'UseTab': 'Always'
			\}

let g:clang_format_configs["v3.7"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'true',
			\   'AlignConsecutiveAssignments': 'false',
			\   'AlignEscapedNewlinesLeft': 'true',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakAfterDefinitionReturnType': 'false',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'AlwaysBreakTemplateDeclarations': 'true',
			\   'BinPackArguments': 'true',
			\   'BinPackParameters': 'true',
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeBraces': 'Allman',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'ColumnLimit': 80,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'ContinuationIndentWidth': 4,
			\   'Cpp11BracedListStyle': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'DisableFormat': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'ForEachMacros': [ 'foreach', 'Q_FOREACH', 'BOOST_FOREACH' ],
			\   'IndentCaseLabels': 'false',
			\   'IndentWidth': 4,
			\   'IndentWrappedFunctionNames': 'false',
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'MacroBlockBegin': '',
			\   'MacroBlockEnd': '',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'SpacesInAngles': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'Standard': 'Auto',
			\   'TabWidth': 4,
			\   'UseTab': 'Always'
			\}

let g:clang_format_configs["v3.6"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'AlignAfterOpenBracket': 'true',
			\   'AlignEscapedNewlinesLeft': 'true',
			\   'AlignOperands': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortCaseLabelsOnASingleLine': 'false',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AlwaysBreakAfterDefinitionReturnType': 'false',
			\   'AlwaysBreakTemplateDeclarations': 'true',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'BreakBeforeBinaryOperators': 'None',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BinPackParameters': 'true',
			\   'BinPackArguments': 'true',
			\   'ColumnLimit': 80,
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'ConstructorInitializerIndentWidth': 4,
			\   'DerivePointerAlignment': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'IndentCaseLabels': 'false',
			\   'IndentWrappedFunctionNames': 'false',
			\   'IndentFunctionDeclarationAfterType': 'false',
			\   'MaxEmptyLinesToKeep': 1,
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'NamespaceIndentation': 'All',
			\   'ObjCBlockIndentWidth': 4,
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'SpacesBeforeTrailingComments': 2,
			\   'Cpp11BracedListStyle': 'true',
			\   'Standard': 'Auto',
			\   'IndentWidth': 4,
			\   'TabWidth': 4,
			\   'UseTab': 'Always',
			\   'BreakBeforeBraces': 'Allman',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInSquareBrackets': 'false',
			\   'SpacesInAngles': 'false',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpaceAfterCStyleCast': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'ContinuationIndentWidth': 4,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'ForEachMacros': [ 'foreach', 'Q_FOREACH', 'BOOST_FOREACH' ],
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'DisableFormat': 'false'
			\}

let g:clang_format_configs["v3.5"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'ConstructorInitializerIndentWidth': 4,
			\   'AlignEscapedNewlinesLeft': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortBlocksOnASingleLine': 'false',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AllowShortFunctionsOnASingleLine': 'None',
			\   'AlwaysBreakTemplateDeclarations': 'true',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'BreakBeforeBinaryOperators': 'false',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BinPackParameters': 'true',
			\   'ColumnLimit': 80,
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'DerivePointerAlignment': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'IndentCaseLabels': 'false',
			\   'IndentWrappedFunctionNames': 'false',
			\   'IndentFunctionDeclarationAfterType': 'false',
			\   'MaxEmptyLinesToKeep': 1,
			\   'KeepEmptyLinesAtTheStartOfBlocks': 'false',
			\   'NamespaceIndentation': 'All',
			\   'ObjCSpaceAfterProperty': 'false',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerAlignment': 'Right',
			\   'SpacesBeforeTrailingComments': 2,
			\   'Cpp11BracedListStyle': 'true',
			\   'Standard': 'Auto',
			\   'IndentWidth': 4,
			\   'TabWidth': 4,
			\   'UseTab': 'Always',
			\   'BreakBeforeBraces': 'Allman',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInAngles': 'false',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpacesInContainerLiterals': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'ContinuationIndentWidth': 4,
			\   'CommentPragmas': '^ IWYU pragma:',
			\   'ForEachMacros': [ 'foreach', 'Q_FOREACH', 'BOOST_FOREACH' ],
			\   'SpaceBeforeParens': 'ControlStatements',
			\   'DisableFormat': 'false'
			\}

let g:clang_format_configs["v3.4"] = {
			\   'BasedOnStyle': 'google',
			\   'AccessModifierOffset': -4,
			\   'ConstructorInitializerIndentWidth': 4,
			\   'AlignEscapedNewlinesLeft': 'true',
			\   'AlignTrailingComments': 'true',
			\   'AllowAllParametersOfDeclarationOnNextLine': 'true',
			\   'AllowShortIfStatementsOnASingleLine': 'false',
			\   'AllowShortLoopsOnASingleLine': 'false',
			\   'AlwaysBreakTemplateDeclarations': 'true',
			\   'AlwaysBreakBeforeMultilineStrings': 'true',
			\   'BreakBeforeBinaryOperators': 'false',
			\   'BreakBeforeTernaryOperators': 'true',
			\   'BreakConstructorInitializersBeforeComma': 'false',
			\   'BinPackParameters': 'true',
			\   'ColumnLimit': 80,
			\   'ConstructorInitializerAllOnOneLineOrOnePerLine': 'true',
			\   'DerivePointerBinding': 'false',
			\   'ExperimentalAutoDetectBinPacking': 'false',
			\   'IndentCaseLabels': 'false',
			\   'MaxEmptyLinesToKeep': 1,
			\   'NamespaceIndentation': 'All',
			\   'ObjCSpaceBeforeProtocolList': 'false',
			\   'PenaltyBreakBeforeFirstCallParameter': 19,
			\   'PenaltyBreakComment': 300,
			\   'PenaltyBreakFirstLessLess': 120,
			\   'PenaltyBreakString': 1000,
			\   'PenaltyExcessCharacter': 1000000,
			\   'PenaltyReturnTypeOnItsOwnLine': 60,
			\   'PointerBindsToType': 'false',
			\   'SpacesBeforeTrailingComments': 2,
			\   'Cpp11BracedListStyle': 'true',
			\   'Standard': 'Auto',
			\   'IndentWidth': 4,
			\   'TabWidth': 4,
			\   'UseTab': 'Always',
			\   'BreakBeforeBraces': 'Allman',
			\   'IndentFunctionDeclarationAfterType': 'true',
			\   'SpacesInParentheses': 'false',
			\   'SpacesInAngles': 'false',
			\   'SpaceInEmptyParentheses': 'false',
			\   'SpacesInCStyleCastParentheses': 'false',
			\   'SpaceAfterControlStatementKeyword': 'true',
			\   'SpaceBeforeAssignmentOperators': 'true',
			\   'ContinuationIndentWidth': 4
			\}
"}}}

function! s:has_vimproc()
	if !exists('s:exists_vimproc')
		try
			silent call vimproc#version()
			let s:exists_vimproc = 1
		catch
			let s:exists_vimproc = 0
		endtry
	endif
	return s:exists_vimproc
endfunction

function! s:system(str, ...)
	let command = a:str
	let input = a:0 >= 1 ? a:1 : ''

	if a:0 == 0
		let output = s:has_vimproc() ?
					\ vimproc#system(command) : system(command)
	elseif a:0 == 1
		let output = s:has_vimproc() ?
					\ vimproc#system(command, input) : system(command, input)
	else
		" ignores 3rd argument unless you have vimproc.
		let output = s:has_vimproc() ?
					\ vimproc#system(command, input, a:2) :
					\ system(command, input)
	endif

	return output
endfunction

function! s:clang_format_get_version()
	if &shell =~# 'csh$' && executable('/bin/bash')
		let shell_save = &shell
		set shell=/bin/bash
	endif
	try
		return matchlist(s:system(g:clang_format#command.' --version 2>&1'),
					\   '\(\d\+\)\.\(\d\+\)')[1:2]
	finally
		if exists('l:shell_save')
			let &shell = shell_save
		endif
	endtry
endfunction

let s:clang_format_is_available = 0
try
	let g:clang_format#command = s:clang_format_detect()
	let s:clang_format_is_available = 1
catch
	let s:clang_format_is_available = 0
endtry

if s:clang_format_is_available
	let v = s:clang_format_get_version()
	if v[0] >= 11
		let g:clang_format#style_options = g:clang_format_configs["v11.0"]
	elseif v[0] == 10
		let g:clang_format#style_options = g:clang_format_configs["v10.0"]
	elseif v[0] == 9
		let g:clang_format#style_options = g:clang_format_configs["v9.0"]
	elseif v[0] == 8
		let g:clang_format#style_options = g:clang_format_configs["v8.0"]
	elseif v[0] == 7
		let g:clang_format#style_options = g:clang_format_configs["v7.0"]
	elseif v[0] == 6
		let g:clang_format#style_options = g:clang_format_configs["v6.0"]
	elseif v[0] == 5
		let g:clang_format#style_options = g:clang_format_configs["v5.0"]
	elseif v[0] == 4
		let g:clang_format#style_options = g:clang_format_configs["v4.0"]
	elseif v[0] == 3 && v[1] == 9
		let g:clang_format#style_options = g:clang_format_configs["v3.9"]
	elseif v[0] == 3 && v[1] == 8
		let g:clang_format#style_options = g:clang_format_configs["v3.8"]
	elseif v[0] == 3 && v[1] == 7
		let g:clang_format#style_options = g:clang_format_configs["v3.7"]
	elseif v[0] == 3 && v[1] == 6
		let g:clang_format#style_options = g:clang_format_configs["v3.6"]
	elseif v[0] == 3 && v[1] == 5
		let g:clang_format#style_options = g:clang_format_configs["v3.5"]
	elseif v[0] == 3 && v[1] == 4
		let g:clang_format#style_options = g:clang_format_configs["v3.4"]
	endif

	" map to <Leader>cf in C++ code
	autocmd FileType c,cpp,objc
				\   nnoremap <buffer> <leader>cf :<c-u>ClangFormat<cr>
	autocmd FileType c,cpp,objc
				\   vnoremap <buffer> <leader>cf :ClangFormat<cr>
	autocmd FileType c,cpp,objc
				\   map <buffer> <leader>x <plug>(operator-clang-format)
	" map to <Leader>cf in javascript
	autocmd FileType java,proto,typescript
				\   nnoremap <buffer> <leader>cf :<c-u>ClangFormat<cr>
	autocmd FileType java,proto,typescript
				\   vnoremap <buffer> <leader>cf :ClangFormat<cr>
	autocmd FileType java,proto,typescript
				\   map <buffer> <leader>x <plug>(operator-clang-format)
	" Toggle auto formatting:
	nmap <leader>C :ClangFormatAutoToggle<cr>
endif
"}}}

" Plugin: vim-linux-coding-style {{{
let g:linuxsty_patterns = [ "/usr/src/" ]

highlight default link LinuxError SpellBad

augroup check_linuxsrc
	autocmd!

	autocmd BufEnter * call s:CheckLinuxSrc()
augroup END

function s:CheckLinuxSrc()
	let apply_style = 0

	let prpath = projectroot#guess()
	let kconfigfile = glob(prpath . '/Kconfig')
	let kerneldirectory = glob(prpath . '/kernel')
	if !empty(kconfigfile) && !empty(kerneldirectory)
		let apply_style = 1
	endif
	if apply_style
		execute ':LinuxCodingStyle'
	endif
endfunction

nnoremap <silent> <leader>k :LinuxCodingStyle<cr>
" NOTE: This will not undo LinuxKeywords() and LinuxHighlighting()
nnoremap <silent> <leader>n :NormalCodingStyle<cr>

command! NormalCodingStyle call s:NormalCodingStyle()

function s:NormalCodingStyle()
	call s:NormalFormatting()
endfunction

function s:NormalFormatting()
	setlocal tabstop=4
	setlocal shiftwidth=4
	setlocal softtabstop=4
	setlocal textwidth=80
	setlocal noexpandtab

	setlocal cindent
endfunction
"}}}

" Plugin: black {{{
autocmd FileType python
			\   nnoremap <buffer> <leader>cf :<c-u>Black<cr>
autocmd FileType python
			\   vnoremap <buffer> <leader>cf :Black<cr>

let g:black_fast = 0
let g:black_linelength = 79
let g:black_skip_string_normalization = 0
let g:black_virtualenv = $DOTVIMDATAPATH . '/black'
"}}}

" Plugin: vim-jsbeautify {{{
let g:config_Beautifier = {}

let g:config_Beautifier["js"] = {
			\   'indent_style' : 'tab',
			\}
let g:config_Beautifier["json"] = {
			\   'indent_style' : 'tab',
			\}
let g:config_Beautifier["jsx"] = {
			\   'indent_style' : 'tab',
			\}
let g:config_Beautifier["css"] = {
			\   'indent_style' : 'tab',
			\}
let g:config_Beautifier["html"] = {
			\   'indent_style' : 'tab',
			\}

autocmd FileType javascript
			\   noremap <buffer> <leader>cf :call JsBeautify()<cr>
autocmd FileType json
			\   noremap <buffer> <leader>cf :call JsonBeautify()<cr>
autocmd FileType jsx
			\   noremap <buffer> <leader>cf :call JsxBeautify()<cr>
autocmd FileType html
			\   noremap <buffer> <leader>cf :call HtmlBeautify()<cr>
autocmd FileType css
			\   noremap <buffer> <leader>cf :call CSSBeautify()<cr>

autocmd FileType javascript
			\   vnoremap <buffer> <leader>cf :call RangeJsBeautify()<cr>
autocmd FileType json
			\   vnoremap <buffer> <leader>cf :call RangeJsonBeautify()<cr>
autocmd FileType jsx
			\   vnoremap <buffer> <leader>cf :call RangeJsxBeautify()<cr>
autocmd FileType html
			\   vnoremap <buffer> <leader>cf :call RangeHtmlBeautify()<cr>
autocmd FileType css
			\   vnoremap <buffer> <leader>cf :call RangeCSSBeautify()<cr>
"}}}

" Plugin: vim-shfmt {{{
let g:shfmt_extra_args = ''

autocmd FileType sh
			\   noremap <buffer> <leader>cf :<c-u>Shfmt<cr>
"}}}

" bracket autocompletion {{{
let s:bracket_autocompletion = 0
if s:bracket_autocompletion == 1
	inoremap ( ()<esc>i
	inoremap [ []<esc>i
	inoremap { {<cr>}<esc>O
	autocmd Syntax html,vim inoremap < <lt>><esc>i| inoremap > <c-r>=ClosePair('>')<cr>
	inoremap ) <c-r>=ClosePair(')')<cr>
	inoremap ] <c-r>=ClosePair(']')<cr>
	inoremap } <c-r>=CloseBracket()<cr>
	inoremap " <c-r>=QuoteDelim('"')<cr>
	inoremap ' <c-r>=QuoteDelim("'")<cr>

	function ClosePair(char)
		if getline('.')[col('.') - 1] == a:char
			return "\<right>"
		else
			return a:char
		endif
	endf

	function CloseBracket()
		if match(getline(line('.') + 1), '\s*}') < 0
			return "\<cr>}"
		else
			return "\<esc>j0f}a"
		endif
	endf

	function QuoteDelim(char)
		let line = getline('.')
		let col = col('.')
		if line[col - 2] == "\\"
			" Inserting a quoted quotation mark into the string
			return a:char
		elseif line[col - 1] == a:char
			" Escaping out of the string
			return "\<right>"
		else
			" Starting a string
			return a:char.a:char."\<esc>i"
		endif
	endf
endif
"}}}

finish
" vim: set ft=vim ts=4 sw=4 noet fdm=marker fen fo= :
