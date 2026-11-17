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
" toggle syntax highlight
nnoremap <silent> <leader>h
			\ :if exists("syntax_on")<BAR>
			\    syntax off<BAR>
			\ else<BAR>
			\    syntax enable<BAR>
			\ endif<CR>

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

" <leader>s: Spell checking shortcuts
nnoremap <leader>ss :setlocal spell!<cr>
nnoremap <leader>sj ]s
nnoremap <leader>sk [s
nnoremap <leader>sa zg]s
nnoremap <leader>sd 1z=
nnoremap <leader>sf z=

" <leader>f: Open Quickfix
nnoremap <silent> <leader>f :botright copen<cr>

" Backspace: Toggle search highlight
nnoremap <bs> :set hlsearch! hlsearch?<cr>

" Enter: Highlight visual selections
xnoremap <silent> <cr> y:let @/ = @"<cr>:set hlsearch<cr>
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
