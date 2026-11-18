scriptencoding utf-8

function! s:load_colorscheme(name) abort
    if !empty(globpath(&runtimepath, 'colors/' . a:name . '.vim'))
        execute 'colorscheme ' . a:name
    endif
endfunction
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
	call s:load_colorscheme("molokai")
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
		call s:load_colorscheme("molokai")
	elseif &t_Co >= 88
		set background=dark
		call s:load_colorscheme("noctu")
		set nocursorcolumn
		set nocursorline
	else
		set background=dark
		let g:jellybeans_use_lowcolor_black = 0
		call s:load_colorscheme("jellybeans")
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
" Plugin: airline {{{
let g:airline_theme = 'solarized'

let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 1
let g:airline#extensions#whitespace#checks = [ 'indent', 'trailing' ]
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'
"}}}
