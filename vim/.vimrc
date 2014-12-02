"*****************************************
"*                                       *
"*               .vimrc                  *
"*  by Wonmin Jung (wonmin82@gmail.com)  *
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

let $DOTVIMPATH = expand('~/.vim')
let $PLUGINPATH = $DOTVIMPATH . '/bundle'

" Set viminfo directory
call EnsureDirExists($DOTVIMPATH)
set viminfo+=n$DOTVIMPATH/viminfo

" Set swap file directory
call EnsureDirExists($DOTVIMPATH . '/swap')
set directory=$DOTVIMPATH/swap/

" Set backup file directory
call EnsureDirExists($DOTVIMPATH . '/backup')
set backupdir=$DOTVIMPATH/backup//

" Set undo data directory
call EnsureDirExists($DOTVIMPATH . '/undo')
set undodir=$DOTVIMPATH/undo//

" set unite data directory using in Shougo's unite plugin
call EnsureDirExists($DOTVIMPATH . '/unite')
let g:unite_data_directory = $DOTVIMPATH . '/unite'

" set vimfiler data directory
call EnsureDirExists($DOTVIMPATH . '/vimfiler')
let g:vimfiler_data_directory = $DOTVIMPATH . '/vimfiler'

" set neomru data directory
call EnsureDirExists($DOTVIMPATH . '/neomru')
let g:neomru#file_mru_path = $DOTVIMPATH . '/neomru/file'
let g:neomru#directory_mru_path = $DOTVIMPATH . '/neomru/directory'

" set session directory using in xolox's vim-session plugin
call EnsureDirExists($DOTVIMPATH . '/session')
let g:session_directory = $DOTVIMPATH . '/session'

" set ultisnips' data directory
call EnsureDirExists($DOTVIMPATH . '/ultisnips')
let g:UltiSnipsSnippetDirectories = [ "ultisnips" ]
"}}}

" Plugin: NeoBundle {{{
let g:neobundle#types#git#default_protocol = 'git'
" YouCompleteMe install process tooks time.
let g:neobundle#install_process_timeout = 1200

if has('vim_starting')
	" following line has moved to very first of vimrc
	" set nocompatible               " Be iMproved

	" Required:
	set runtimepath+=$PLUGINPATH/neobundle.vim/
endif

" Begin NeoBundle {{{
try
	" Required:
	call neobundle#begin(expand($PLUGINPATH))

	" Let NeoBundle manage NeoBundle
	" Required:
	NeoBundleFetch 'Shougo/neobundle.vim'
catch /^Vim\%((\a\+)\)\=:E117/
	" If NeoBundle is missing, define an installer for it
	function! NeoBundleInstaller()
		if s:is_cygwin || s:is_macos || s:is_linux64 || s:is_linux32 || s:is_unix
			execute ':silent !echo "==> Starting NeoBundle installation..."'
			let destination = expand($PLUGINPATH . '/neobundle.vim')
			if ! isdirectory(destination)
				call mkdir(destination, "p")
			endif
			let install_command = printf('git clone %s://github.com/Shougo/neobundle.vim.git %s',
				\ (exists('$http_proxy') ? 'https' : 'git'),
				\ destination)
			execute ':silent !echo "==> Executing command: ' . install_command . '"'
			execute ':silent !' . install_command
			execute ':silent !echo "==> NeoBundle has been installed. Restart vim to continue."'
			quit!
		elseif s:is_win32 || s:is_win64
			" TODO: need to be checked if it is working or not.
			execute ':silent !echo ""'
			execute ':silent !echo "==> Starting NeoBundle installation..."'
			let destination = expand($PLUGINPATH . '/neobundle.vim')
			if ! isdirectory(destination)
				call mkdir(destination, "p")
			endif
			let install_command = printf('git clone %s://github.com/Shougo/neobundle.vim.git %s',
				\ (exists('$http_proxy') ? 'https' : 'git'),
				\ destination)
			execute ':silent !echo "==> Executing command: ' . install_command . '"'
			execute ':silent !' . install_command
			execute ':silent !echo "==> NeoBundle has been installed. Restart vim to continue."'
			quit!
		endif
	endfunction

	call NeoBundleInstaller()
endtry
" }}}

" My Bundles here:
" Refer to |:NeoBundle-examples|.
" Note: You don't set neobundle setting in .gvimrc!

NeoBundle 'Shougo/vimproc', {
			\ 'build': {
			\     'windows': 'make -f make_mingw32.mak',
			\     'cygwin': 'make -f make_cygwin.mak',
			\     'mac': 'make -f make_mac.mak',
			\     'unix': 'make -f make_unix.mak',
			\ } }

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
			\ 'depends': 'xolox/vim-misc',
			\ 'augroup': 'PluginSession',
			\ 'autoload': {
			\   'commands': [
			\     { 'name': [ 'OpenSession', 'CloseSession' ],
			\       'complete': 'customlist,xolox#session#complete_names' },
			\     { 'name': [ 'SaveSession' ],
			\       'complete': 'customlist,xolox#session#complete_names_with_suggestions' }
			\   ],
			\   'functions': [ 'xolox#session#complete_names',
			\                  'xolox#session#complete_names_with_suggestions' ]
			\ }}

" Shell
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'Shougo/vimshell'
NeoBundle 'tpope/vim-dispatch'

" Git
NeoBundle 'tpope/vim-fugitive'

" Tags
NeoBundle 'majutsushi/tagbar'

" Status line
NeoBundle 'bling/vim-airline'
NeoBundle 'bling/vim-bufferline'

NeoBundle 'embear/vim-localvimrc'
NeoBundle 'scrooloose/nerdcommenter'
if has('patch-7.3.465')
	NeoBundle 'eiginn/netrw'
endif
NeoBundle 'wesleyche/SrcExpl'
NeoBundle 'jlanzarotta/bufexplorer'
NeoBundle 'godlygeek/tabular'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'vim-scripts/IndentTab', {
			\ 'depends': 'vim-scripts/ingo-library'
			\ }
NeoBundle 'vim-scripts/IndentConsistencyCop'
NeoBundle 'vim-scripts/IndentConsistencyCopAutoCmds'
NeoBundle 'SirVer/ultisnips'
NeoBundle 'honza/vim-snippets'

" ensure vim version >= 7.3.584 and not in cygwin.
if has('patch-7.3.584') && !(s:is_win32 || s:is_win64)
	NeoBundle 'Valloric/YouCompleteMe', {
				\ 'build' : {
				\     'windows' : './install.sh --clang-completer --system-libclang --omnisharp-completer',
				\     'cygwin' : './install.sh --clang-completer --system-libclang',
				\     'mac' : './install.sh --clang-completer --system-libclang --omnisharp-completer',
				\     'unix' : './install.sh --clang-completer --system-libclang --omnisharp-completer',
				\    }
				\ }
endif

NeoBundle 'tomasr/molokai'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'noahfrederick/vim-noctu'

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
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

" Open all folds initially
set foldmethod=indent
set foldlevelstart=99

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
	set fileignorecase
endif
set smartcase
set magic

set history=1000
"set km=startsel,stopsel
set laststatus=2
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

	" customizing colorschemes
	" disable bold attribute for VertSplit in molokai colorscheme,
	" because certain font(Dejavu Sans Mono Bold) lacks
	" line drawing characters.
	augroup MyAutoCmd
		autocmd ColorScheme *
					\	try |
					\		if g:colors_name == 'molokai' |
					\			execute "hi VertSplit cterm=none" |
					\			if &t_Co >= 256 |
					\				execute "hi MatchParen ctermfg=226 ctermbg=bg" |
					\			endif |
					\		endif |
					\	endtry
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
" highlight trailing space {{{
" listchar=trail is not as flexible, use the below to highlight trailing
" whitespace. Don't do it for unite windows or readonly files
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
augroup MyAutoCmd
	autocmd BufWinEnter *
				\   if &modifiable && (&ft!='unite' && &ft!='vimshell') |
				\       execute 'match ExtraWhitespace /\s\+$/' |
				\   endif
	autocmd InsertEnter *
				\   if &modifiable && (&ft!='unite' && &ft!='vimshell') |
				\       execute 'match ExtraWhitespace /\s\+\%#\@<!$/' |
				\   endif
	autocmd InsertLeave *
				\   if &modifiable && (&ft!='unite' && &ft!='vimshell') |
				\       execute 'match ExtraWhitespace /\s\+$/' |
				\   endif
	autocmd BufWinLeave *
				\   if &modifiable && (&ft!='unite' && &ft!='vimshell') |
				\       execute 'call clearmatches()' |
				\   endif
augroup END
"}}}

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
augroup MyAutoCmd
	autocmd BufWinEnter *.hpp set syntax=cpp
	" default cinoptions value
	"set cinoptions=s,e0,n0,f0,{0,}0,^0,L-1,:s,=s,l0,b0,gs,hs,N0,ps,ts,is,+s,c3,C0,/0,(2s,us,U0,w0,W0,k0,m0,j0,J0,)20,*70,#0
	autocmd Filetype c,cpp
				\ execute "setlocal tabstop=4 softtabstop=4 shiftwidth=4" |
				\ execute "setlocal smarttab noexpandtab" |
				\ execute "setlocal autoindent cindent smartindent" |
				\ execute "setlocal backspace=indent,eol,start" |
				\ execute "setlocal cinoptions=:0,l1,g0,t0,(0,W4,j1,J1" |
				\ execute "setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e" |
				\ execute "setlocal cinwords=if,else,while,do,for,switch"
	autocmd Filetype python
				\ execute "setlocal tabstop=4 softtabstop=4 shiftwidth=4" |
				\ execute "setlocal smarttab expandtab" |
				\ execute "setlocal autoindent cindent smartindent" |
				\ execute "setlocal backspace=indent,eol,start"
	autocmd Filetype perl
				\ execute "setlocal kp=perldoc\\ -f"
	autocmd Filetype tex
				\ execute "setlocal textwidth=72"
	autocmd FileType man
				\ execute "setlocal tabstop=8" |
				\ execute "setlocal nomodifiable nomodified" |
				\ execute "setlocal nolist nonumber nospell" |
				\ execute "setlocal mouse=a" |
				\ execute "setlocal nocursorline nocursorcolumn" |
				\ execute "%foldopen!" |
				\ execute "nnoremap q :qa!<cr>" |
				\ execute "nnoremap <end> G" |
				\ execute "nnoremap <home> gg" |
				\ execute "nmap K <c-]>" |
				\ execute "nnoremap : <nop>" |
				\ execute "nnoremap <f2> <nop>" |
				\ execute "nnoremap <f3> <nop>" |
				\ execute "nnoremap <f4> <nop>" |
				\ execute "nnoremap <f5> <nop>"
augroup END
"}}}

" some autocmds {{{
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

" Function: Append modeline after last line in buffer. {{{
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
	let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :",
				\ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
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
		silent execute "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q --verbose=yes"
		silent execute "!rm -fv cscope.files"
		silent execute "!find . \\( -name '*.c' -o -name '*.cpp' -o -name '*.cc' -o -name '*.h' -o -name '*.s' -o -name '*.S' \\) -print > cscope.files"
		execute "!cscope -v -q -b -i cscope.files $*"
		execute "cscope reset"
		redraw!
	elseif s:is_win32 || s:is_win64
		" TODO: add routine for generating ctags and cscope for windows.
	endif
endfunction
"}}}

" Function: Cleaning tags. {{{
function! CleaningTagsAndCscope()
	if s:is_cygwin || s:is_macos || s:is_linux64 || s:is_linux32 || s:is_unix
		execute "!rm -fv tags cscope.out cscope.in.out cscope.po.out cscope.files"
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
nmap <c-s><c-f> [unite]l
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

" Plugin: localvimrc {{{
let g:localvimrc_name = [ '.vimrc.local' ]
" add BufReadPre autocmd for apply options of Syntastic
let g:localvimrc_event = [ 'BufReadPre', 'BufWinEnter' ]
let g:localvimrc_ask = 0
"}}}

" Function: check whether current buffer is plugin's or not {{{
let s:Plugin_Buffer_List = ['\\[BufExplorer\\]', 'NERD_tree.*', '__Tagbar__']
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
nnoremap <silent> [unite]/ :<c-u>Unite -buffer-name=search_file line<cr>

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
	" <esc> overriding may cause problems at some terminal types.
	" nmap <buffer> <esc> <Plug>(unite_exit)
	" nmap <buffer> <esc> <Plug>(unite_insert_enter)
	" imap <buffer> <esc> <Plug>(unite_exit)

	" imap <buffer> <c-j> <Plug>(unite_select_next_line)
	imap <buffer> <c-j> <Plug>(unite_insert_leave)
	nmap <buffer> <c-j> <Plug>(unite_loop_cursor_down)
	nmap <buffer> <c-k> <Plug>(unite_loop_cursor_up)
	nmap <buffer> <tab> <Plug>(unite_loop_cursor_down)
	nmap <buffer> <s-tab> <Plug>(unite_loop_cursor_up)
	imap <buffer> <c-a> <Plug>(unite_choose_action)
	imap <buffer> <tab> <Plug>(unite_insert_leave)
	" imap <buffer> jj <Plug>(unite_insert_leave)
	imap <buffer> <c-w> <Plug>(unite_delete_backward_word)
	imap <buffer> <c-u> <Plug>(unite_delete_backward_path)
	imap <buffer> '     <Plug>(unite_quick_match_default_action)
	nmap <buffer> '     <Plug>(unite_quick_match_default_action)
	nmap <buffer> <c-r> <Plug>(unite_redraw)
	imap <buffer> <c-r> <Plug>(unite_redraw)
	inoremap <silent><buffer><expr> <c-s> unite#do_action('split')
	nnoremap <silent><buffer><expr> <c-s> unite#do_action('split')
	inoremap <silent><buffer><expr> <c-v> unite#do_action('vsplit')
	nnoremap <silent><buffer><expr> <c-v> unite#do_action('vsplit')

	let unite = unite#get_current_unite()
	if unite.buffer_name =~# '^search'
		nnoremap <silent><buffer><expr> r     unite#do_action('replace')
	else
		nnoremap <silent><buffer><expr> r     unite#do_action('rename')
	endif

	nnoremap <silent><buffer><expr> cd     unite#do_action('lcd')

	" Using Ctrl-\ to trigger outline, so close it using the same keystroke
	if unite.buffer_name =~# '^outline'
		imap <buffer> <c-\> <Plug>(unite_exit)
	endif

	" Using Ctrl-/ to trigger line, close it using same keystroke
	if unite.buffer_name =~# '^search_file'
		imap <buffer> <c-_> <Plug>(unite_exit)
	endif
endfunction

" Use the fuzzy matcher for everything
call unite#filters#matcher_default#use(['matcher_fuzzy'])
" Use the rank sorter for everything
" call unite#filters#sorter_default#use(['sorter_rank'])
" Use the rank sorter for files (NOTE: this is slow)
call unite#custom#source('buffer,file,file_rec',
			\ 'sorters', 'sorter_rank')

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
			\   'marked_icon': '✓',
			\   'prompt' : '> '
			\ })

call unite#custom#profile('outline', 'context', {
			\   'auto_expand': 0,
			\   'start_insert': 1,
			\   'max_candidates': 0,
			\   'no_auto_resize': 1,
			\   'prompt_direction': 'top',
			\ })

" Set up some custom ignores
call unite#custom#source('file_rec,file_rec/async,file_mru,file,buffer,grep',
			\   'ignore_pattern', join([
			\   '\.git/',
			\   '\.svn/',
			\   '\.hg/',
			\   'git5/.*/review/',
			\   'google/obj/',
			\   'tmp/',
			\   '\.sass-cache',
			\   'node_modules/',
			\   'bower_components/',
			\   'dist/',
			\   '\.git5_specs/',
			\   '\.pyc',
			\   '\.dropbox/',
			\   '\.cache/'
			\   ], '\|'))

" Enable histo  ry yank source
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
	if !argc() && !exists("g:start_session_from_cmdline")
				\ && !(&ft == 'man')
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
call unite#util#set_default('g:unite_source_session_allow_rename_locked',
			\ 0)

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
			\ 'name': 'session',
			\ 'description': 'candidates from session list',
			\ 'default_action': 'load',
			\ 'alias_table': { 'edit' : 'open' },
			\ 'action_table': {}
			\ }

function! s:unite_source_session.gather_candidates(args, context)
	let directory = xolox#misc#path#absolute(g:session_directory)
	let sessions = split(glob(directory.'/*'.g:session_extension), '\n')
	let candidates = map(copy(sessions), "{
				\ 'word': xolox#session#path_to_name(v:val),
				\ 'kind': 'file',
				\ 'action__path': v:val,
				\ 'action__directory': unite#util#path2directory(v:val)
				\ }")
	return candidates
endfunction

" New session only source
let s:unite_source_session_new = {
			\ 'name': 'session/new',
			\ 'description': 'session candidates from input',
			\ 'default_action': 'save',
			\ 'action_table': {}
			\ }

function! s:unite_source_session_new.change_candidates(args, context)
	let input = substitute(substitute(
				\ a:context.input, '\\ ', ' ', 'g'), '^\a\+:\zs\*/', '/', '')
	if input == ''
		return []
	endif
	" Return new session candidate
	return [{ 'word': input, 'abbr': '[new session] ' . input, 'action__path': input }] +
				\ s:unite_source_session.gather_candidates(a:args, a:context)
endfunction

" Actions
let s:unite_source_session.action_table.load = {
			\ 'description': 'load this session',
			\ }

function! s:unite_source_session.action_table.load.func(candidate)
	call s:unite_sources_session_load(a:candidate.word)
endfunction

let s:unite_source_session.action_table.delete = {
			\ 'description': 'delete from session list',
			\ 'is_invalidate_cache': 1,
			\ 'is_quit': 0,
			\ 'is_selectable': 1
			\ }

function! s:unite_source_session.action_table.delete.func(candidates)
	for candidate in a:candidates
		if input('Really delete session file: '
					\ . candidate.action__path . '? ') =~? 'y\%[es]'
			execute 'DeleteSession' candidate.word
		endif
	endfor
endfunction

let s:unite_source_session.action_table.rename = {
			\ 'description': 'rename session name',
			\ 'is_invalidate_cache': 1,
			\ 'is_quit': 0,
			\ 'is_selectable': 1
			\ }

function! s:unite_source_session.action_table.rename.func(candidates)
	let current_session = xolox#session#find_current_session()
	let rename_locked = g:unite_source_session_allow_rename_locked
	for candidate in a:candidates
		if rename_locked || current_session != candidate.word
			let session_name = input(printf(
						\ 'New session name: %s -> ', candidate.word),
						\ candidate.word)
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
						\ [ 'The session "'.candidate.word.'" is locked.' ], 'session')
		endif
	endfor
endfunction

let s:unite_source_session.action_table.save = {
			\ 'description': 'save current session as candidate',
			\ 'is_invalidate_cache': 1,
			\ 'is_selectable': 1
			\ }

function! s:unite_source_session.action_table.save.func(candidates)
	for candidate in a:candidates
		if input('Really save the current session as: '
					\ . candidate.word . '? ') =~? 'y\%[es]'
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
				\ g:my_vimfiler_explorer_name,
				\ g:my_vimfiler_winwidth)
endfunction

let g:vimfiler_as_default_explorer = 1
let g:vimfiler_tree_leaf_icon = ' '
if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
	let g:vimfiler_tree_opened_icon = '▾'
	let g:vimfiler_tree_closed_icon = '▸'
	" let g:vimfiler_file_icon = ' '
	let g:vimfiler_marked_file_icon = '✓'
endif
" let g:vimfiler_readonly_file_icon = ' '
let g:my_vimfiler_explorer_name = 'explorer'
let g:my_vimfiler_winwidth = 30
let g:vimfiler_safe_mode_by_default = 0
" let g:vimfiler_directory_display_top = 1

autocmd MyAutoCmd FileType vimfiler call s:vimfiler_settings()
function! s:vimfiler_settings()
	nmap <buffer><expr><cr> vimfiler#smart_cursor_map("\<PLUG>(vimfiler_expand_tree)", "e")
endfunction
"}}}

" Plugin: VimShell {{{
let g:vimshell_prompt = "% "
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
autocmd MyAutoCmd FileType vimshell call s:vimshell_settings()
function! s:vimshell_settings()
	call vimshell#altercmd#define('g', 'git')
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

if s:is_cygwin
	let g:tagbar_ctags_bin = '~/bin/ctags.exe'   "Cygwin-specific option
endif

let g:tagbar_left = 0

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
let g:NERDTreeDirArrows = 1
let g:NERDTreeIgnore = ['\~$', '\.swp$', '\.git', '\.hg', '\.svn', '\.bzr']
" Close vim if the only window open is nerdtree
autocmd MyAutoCmd BufEnter *
			\ if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
"}}}

" Plugin: NERDCommenter {{{
" Always leave a space between the comment character and the comment
let NERDSpaceDelims = 1
"}}}

" Plugin: netrw {{{
let g:netrw_altv = 1 " when navigating a folder,
" hitting <v> opens a window at right side (default is left side)
"}}}

" Plugin: IndentConsistencyCop {{{
map <leader>icc :IndentConsistencyCop<cr>
let g:indentconsistencycop_highlighting = 'sglmf:3'
let g:indentconsistencycop_non_indent_pattern = ' \*\%([*/ \t]\|$\)'
"}}}

" Plugin: IndentConsistencyCopAutoCmds {{{
" DOES NOT WORK
" TODO: investigate why it's not working
map <leader>ice :IndentConsistencyCopAutoCmdsOn<cr>
map <leader>icd :IndentConsistencyCopAutoCmdsOff<cr>
let g:indentconsistencycop_CheckOnLoad = 0
let g:indentconsistencycop_CheckAfteRWrite = 1
let g:indentconsistencycop_CheckAfterWriteMaxLinesForImmediateCheck = 1000
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
			\ "__Tag_List__",
			\ "_NERD_tree_",
			\ "Source_Explorer",
			\ "[File List]",
			\ "[Buf List]",
			\ "[BufExplorer]"
			\ ]
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

" Plugin: syntastic {{{
map <leader>ms :SyntasticToggleMode<cr>
let g:syntastic_error_symbol = '✘'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_check_on_open = 1

let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1
let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_ignore_files = ['\m^/usr/include/', '\m\c\.h$']
let g:syntastic_mode_map = { "mode": "active",
			\ "active_filetypes": [],
			\ "passive_filetypes": [] }

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
let g:Show_diagnostics_ui = 1 "default 1

"will put icons in Vim's gutter on lines that have a diagnostic set.
"Turning this off will also turn off the YcmErrorLine and YcmWarningLine
"highlighting
let g:ycm_enable_diagnostic_signs = 1
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_always_populate_location_list = 1 "default 0
let g:ycm_open_loclist_on_ycm_diags = 1 "default 1
let g:ycm_seed_identifiers_with_syntax = 1 "default 0

let g:ycm_complete_in_strings = 1 "default 1
let g:ycm_collect_identifiers_from_tags_files = 1 "default 0, set to 0 if tag file isn't in local.
let g:ycm_path_to_python_interpreter = '' "default ''

let g:ycm_server_use_vim_stdout = 0 "default 0 (logging to console)
let g:ycm_server_log_level = 'info' "default info

let g:ycm_global_ycm_extra_conf = $PLUGINPATH . '/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
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

" Settings which is not either completed or used. {{{
" " Plugin: neocomplete {{{
" "Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" " Disable AutoComplPop.
" let g:acp_enableAtStartup = 0
" " Use neocomplete.
" let g:neocomplete#enable_at_startup = 1
" " Use smartcase.
" let g:neocomplete#enable_smart_case = 1
" " Set minimum syntax keyword length.
" let g:neocomplete#sources#syntax#min_keyword_length = 3
" let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" " Define dictionary.
" let g:neocomplete#sources#dictionary#dictionaries = {
			" \ 'default' : '',
			" \ 'vimshell' : $HOME.'/.vimshell_hist',
			" \ 'scheme' : $HOME.'/.gosh_completions'
			" \ }

" " Define keyword.
" if !exists('g:neocomplete#keyword_patterns')
	" let g:neocomplete#keyword_patterns = {}
" endif
" let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" " Plugin key-mappings.
" inoremap <expr><c-g>     neocomplete#undo_completion()
" inoremap <expr><c-l>     neocomplete#complete_common_string()

" " Recommended key-mappings.
" " <cr>: close popup and save indent.
" inoremap <silent> <cr> <c-r>=<sid>my_cr_function()<cr>
" function! s:my_cr_function()
	" return neocomplete#close_popup() . "\<cr>"
	" " For no inserting <cr> key.
	" " return pumvisible() ? neocomplete#close_popup() : "\<cr>"
" endfunction
" " <tab>: completion.
" inoremap <expr><tab>  pumvisible() ? "\<c-n>" : "\<tab>"
" " <C-h>, <BS>: close popup and delete backword char.
" inoremap <expr><cr>-h> neocomplete#smart_close_popup()."\<c-h>"
" inoremap <expr><bs> neocomplete#smart_close_popup()."\<c-h>"
" inoremap <expr><c-y> neocomplete#close_popup()
" inoremap <expr><c-e> neocomplete#cancel_popup()
" " Close popup by <Space>.
" "inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"

" " For cursor moving in insert mode(Not recommended)
" "inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
" "inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
" "inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
" "inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
" " Or set this.
" let g:neocomplete#enable_cursor_hold_i = 1
" " Or set this.
" "let g:neocomplete#enable_insert_char_pre = 1

" " AutoComplPop like behavior.
" "let g:neocomplete#enable_auto_select = 1

" " Shell like behavior(not recommended).
" "set completeopt+=longest
" "let g:neocomplete#enable_auto_select = 1
" "let g:neocomplete#disable_auto_complete = 1
" "inoremap <expr><tab>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" " Enable omni completion.
" autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
" autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
" autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
" autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
" autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" " Enable heavy omni completion.
" if !exists('g:neocomplete#sources#omni#input_patterns')
	" let g:neocomplete#sources#omni#input_patterns = {}
" endif
" "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
" "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
" "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" " For perlomni.vim setting.
" " https://github.com/c9s/perlomni.vim
" let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
" "}}}

" " Plugin: neosnippet {{{
" let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

" " Plugin key-mappings.
" imap <c-k>     <Plug>(neosnippet_expand_or_jump)
" smap <c-k>     <Plug>(neosnippet_expand_or_jump)
" xmap <c-k>     <Plug>(neosnippet_expand_target)

" " SuperTab like snippets behavior.
" " imap <expr><tab> neosnippet#expandable_or_jumpable() ?
			" " \ "\<Plug>(neosnippet_expand_or_jump)"
			" " \: pumvisible() ? "\<C-n>" : "\<tab>"
" " smap <expr><tab> neosnippet#expandable_or_jumpable() ?
			" " \ "\<Plug>(neosnippet_expand_or_jump)"
			" " \: "\<tab>"

" " For snippet_complete marker.
" if has('conceal')
	" set conceallevel=2 concealcursor=i
" endif
" "}}}

" " Plugin: SuperTab {{{
" " TODO: it's not working now.
" let g:SuperTabMappingForward = '<c-s-tab>'
" let g:SuperTabMappingBackward = '<c-tab>'
" "}}}

" " Plugin: OmniCppComplete {{{
" autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
" autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" let OmniCpp_GlobalScopeSearch = 1
" let OmniCpp_NamespaceSearch = 1
" let OmniCpp_DisplayMode = 0
" let OmniCpp_ShowScopeInAbbr = 0
" let OmniCpp_ShowPrototypeInAbbr = 0
" let OmniCpp_ShowAccess = 1
" let OmniCpp_DefaultNamespaces = []
" let OmniCpp_MayCompleteDot = 1
" let OmniCpp_MayCompleteArrow = 1
" let OmniCpp_MayCompleteScope = 0
" let OmniCpp_SelectFirstItem = 0
" let OmniCpp_LocalSearchDecl = 0
" "}}}

" Plugin: taglist - replaced by tagbar {{{
"nnoremap <silent> <f7> :TlistUpdate<cr>
"nnoremap <silent> <f8> :TlistToggle<cr>
"nnoremap <silent> <f9> :TlistSync<cr>

"let Tlist_Inc_Winwidth = 0
"let Tlist_Auto_Open = 0
"let Tlist_Process_File_Always = 0
"let Tlist_Enable_Fold_Column = 0
"let Tlist_Display_Tag_Scope = 0
"let Tlist_Sort_Type = "name"
"let Tlist_Use_Right_Window = 1
"let Tlist_Display_Prototype = 0
"let Tlist_Exit_OnlyWindow = 1
"let Tlist_File_Fold_Auto_Close = 1

"if has('win32unix')
	"let Tlist_Ctags_Cmd = '$HOME/bin/ctags.exe'   "Cygwin-specific option
"endif
"}}}

" " Plugin: Unite Sessions {{{
" " Save session automatically.
" let g:unite_source_session_enable_auto_save = 1

" " Pop up session selection if no file is specified
" autocmd MyAutoCmd VimEnter * call s:unite_session_on_enter()
" function! s:unite_session_on_enter()
	" if !argc() && !exists("g:start_session_from_cmdline")
				" \ && !(&ft == 'man')
		" Unite -buffer-name=sessions session
	" endif
" endfunction
" "}}}

"}}}

finish
" vim: set ft=vim ts=4 sw=4 noet fdm=marker fen fo= :
