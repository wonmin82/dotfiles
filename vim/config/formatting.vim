" Plugin: vim-linux-coding-style {{{
let g:linuxsty_patterns = [ "/usr/src/" ]

highlight default link LinuxError SpellBad

augroup check_linuxsrc
	autocmd!

	autocmd BufEnter * call s:CheckLinuxSrc()
augroup END

function s:CheckLinuxSrc()
	if exists(':ProjectRootCD') != 2 || exists(':LinuxCodingStyle') != 2
		return
	endif
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
" Reuse an existing Black virtualenv without creating one on first use.
let g:black_use_virtualenv = get(g:, 'black_use_virtualenv', isdirectory(g:black_virtualenv))
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

" clang-format commands and mappings
execute 'source ' . fnameescape(g:dotvim_root . '/config/clang-format/legacy.vim')
let g:clang_format#auto_format = get(g:, 'clang_format#auto_format', 0)
let g:clang_format#auto_filetypes = get(g:, 'clang_format#auto_filetypes',
            \ ['c', 'cpp', 'objc', 'java', 'javascript', 'typescript',
            \  'proto', 'arduino', 'cuda', 'vala'])

command! -range=% ClangFormat call dotvim#format#replace(<line1>, <line2>)
command! -range=% ClangFormatEchoFormattedCode echo dotvim#format#run(<line1>, <line2>)
command! ClangFormatAutoToggle call dotvim#format#toggle()
command! ClangFormatAutoEnable let g:clang_format#auto_format = 1
command! ClangFormatAutoDisable let g:clang_format#auto_format = 0

nnoremap <expr> <Plug>(operator-clang-format) dotvim#format#start_operator()
xnoremap <Plug>(operator-clang-format) :ClangFormat<CR>
nnoremap <leader>C :ClangFormatAutoToggle<CR>

function! s:clang_mappings() abort
    nnoremap <buffer> <leader>cf :<C-U>ClangFormat<CR>
    xnoremap <buffer> <leader>cf :ClangFormat<CR>
    nmap <buffer> <leader>x <Plug>(operator-clang-format)
    xmap <buffer> <leader>x <Plug>(operator-clang-format)
endfunction

augroup DotVimClangFormat
    autocmd!
    autocmd FileType c,cpp,objc,java,proto,typescript call s:clang_mappings()
    autocmd BufWritePre *
                \ if g:clang_format#auto_format && index(g:clang_format#auto_filetypes, &filetype) >= 0 |
                \     call dotvim#format#replace(1, line('$')) |
                \ endif
augroup END
