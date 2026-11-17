function! DotVimDocumentation() abort
    if get(g:, 'coc_service_initialized', 0) && CocHasProvider('hover')
        call CocActionAsync('doHover')
    elseif &filetype ==# 'python'
        call PydocFind()
    else
        normal! K
    endif
endfunction

function! DotVimOutline() abort
    if get(g:, 'coc_service_initialized', 0) && CocHasProvider('documentSymbol')
        let l:win = coc#window#find('cocViewId', 'OUTLINE')
        if l:win == -1
            call CocActionAsync('showOutline', 1)
        else
            call coc#window#close(l:win)
        endif
    else
        TagbarToggle
    endif
endfunction

" Plugin: tagbar {{{
nnoremap <silent> <expr> <f4> @% != "[BufExplorer]" ? ':call DotVimOutline()<cr>' : '\<nop>'
inoremap <silent> <expr> <f4> @% != "[BufExplorer]" ? '<esc>:call DotVimOutline()<cr>a' : '\<nop>'

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

" tagbar configuration for go language
" https://github.com/jstemmer/gotags
let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds'     : [
		\ 'p:package',
		\ 'i:imports:1',
		\ 'c:constants',
		\ 'v:variables',
		\ 't:types',
		\ 'n:interfaces',
		\ 'w:fields',
		\ 'e:embedded',
		\ 'm:methods',
		\ 'r:constructor',
		\ 'f:functions'
	\ ],
	\ 'sro' : '.',
	\ 'kind2scope' : {
		\ 't' : 'ctype',
		\ 'n' : 'ntype'
	\ },
	\ 'scope2kind' : {
		\ 'ctype' : 't',
		\ 'ntype' : 'n'
	\ },
	\ 'ctagsbin'  : 'gotags',
	\ 'ctagsargs' : '-sort -silent'
\ }
"}}}
