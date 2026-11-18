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

" remember last editing position {{{
" Uncomment the following to have Vim jump to the last position when
" reopening a file
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
"    \| exe "normal g'\"" | endif
"endif
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
