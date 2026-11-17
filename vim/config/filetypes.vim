" Settings per filetype {{{
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
	silent execute ":!pydoc3 " . shellescape(a:word, 1)
	redraw!
endfunction

function s:set_buffer_env_for_python()
	setlocal tabstop=4 softtabstop=4 shiftwidth=4
	setlocal smarttab expandtab
	setlocal autoindent cindent smartindent
	setlocal backspace=indent,eol,start
	nnoremap <silent> <buffer> K :call DotVimDocumentation()<CR>
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
	autocmd FileType godoc
				\   execute "setlocal nolist nonumber nospell" |
				\   execute "nnoremap <buffer> q :<c-u>bdelete<cr>"
	if exists('+colorcolumn')
		autocmd FileType godoc
					\   execute "setlocal colorcolumn="
	endif
	autocmd FileType vimshell
				\   execute "setlocal nolist nonumber nospell"
augroup END
"}}}
