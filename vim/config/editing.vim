" Plugin: NERDCommenter {{{
" Always leave a space between the comment character and the comment
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 0
let g:NERDDefaultAlign = 'both'
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
"}}}
" Plugin: IndentConsistencyCop {{{
nmap <leader>icc :IndentConsistencyCop<cr>
let g:indentconsistencycop_highlighting = 'sglmf:3'
let g:indentconsistencycop_non_indent_pattern = ' \*\%([*/ \t]\|$\)'
"}}}

" Plugin: IndentConsistencyCopAutoCmds {{{
" Turn off by autocmd because the interface is so annoying.
augroup MyAutoCmd
	autocmd BufNewFile * if exists(':IndentConsistencyCopAutoCmdsOff') == 2 | IndentConsistencyCopAutoCmdsOff | endif
	autocmd BufReadPre * if exists(':IndentConsistencyCopAutoCmdsOff') == 2 | IndentConsistencyCopAutoCmdsOff | endif
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
let g:better_whitespace_filetypes_blacklist = [
			\	'vimshell',
			\	'unite',
			\	'help',
			\	'man'
			\]
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
