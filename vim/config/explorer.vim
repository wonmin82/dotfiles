" Function: check whether current buffer is plugin's or not {{{
let s:Plugin_Buffer_List = ["\\[unite\\].*", "\\[BufExplorer\\]", "NERD_tree.*", "__Tagbar__"]
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
	if &buftype ==# 'quickfix' || &filetype ==# 'fzf'
		return 1
	endif
	return 0
endfunc
"}}}
" Plugin: Vimfiler {{{
" TODO Look into Vimfiler more
" Example at: https://github.com/hrsh7th/dotfiles/blob/master/vim/.vimrc
nnoremap <silent> <leader>vf :<C-U>call <SID>ToggleFileTree()<CR>

function! s:ToggleFileTree() abort
    if exists(':NERDTreeToggle') == 2
        let l:dir = empty(expand('%')) || &buftype !=# '' || &filetype ==# 'nerdtree'
                    \ ? getcwd() : expand('%:p:h')
        execute 'NERDTreeToggle ' . fnameescape(l:dir)
    elseif exists(':VimFilerBufferDir') == 2
        call feedkeys(MyOpenExplorerCommand(), 'n')
    else
        Explore
    endif
endfunction
function! MyOpenExplorerCommand()
	return printf(":\<c-u>VimFilerBufferDir -buffer-name=%s -split -auto-cd -toggle -no-quit -winwidth=%s\<cr>",
				\   g:my_vimfiler_explorer_name,
				\   g:my_vimfiler_winwidth)
endfunction

let g:vimfiler_as_default_explorer = 0
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
if has('terminal')
    command! DotVimTerminal terminal
else
    command! DotVimTerminal VimShell
endif
let g:vimshell_prompt = "% "
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
autocmd MyAutoCmd FileType vimshell call s:vimshell_settings()
function! s:vimshell_settings()
	call vimshell#altercmd#define('g', 'git')
	call vimshell#execute('export MANPAGER=')
endfunction
"}}}

" Plugin: bufexplorer {{{
function! s:BrowseBuffers() abort
    if IsHerePluginBuffer()
        return
    endif
    if exists(':Buffers') == 2 && executable('fzf')
        Buffers
    elseif exists(':BufExplorer') == 2
        BufExplorer
    else
        ls
    endif
endfunction

nnoremap <silent> <F3> :<C-U>call <SID>BrowseBuffers()<CR>
inoremap <silent> <F3> <Esc>:call <SID>BrowseBuffers()<CR>a
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
