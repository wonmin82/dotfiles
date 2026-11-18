" Plugin: vim-projectroot {{{
let g:rootmarkers = ['.projectroot', '.git', '.hg', '.svn', '.bzr', '_darcs', 'build.xml', 'tags', 'TAGS', 'cscope.out']
function! <SID>AutoProjectRootCD()
	try
		if &buftype ==# '' && &ft != 'help' && &ft != 'vimshell' && &ft != 'unite'
			ProjectRootCD
		endif
	catch
		" Silently ignore invalid buffers
	endtry
endfunction
autocmd MyAutoCmd BufEnter * call <SID>AutoProjectRootCD()

nnoremap <leader>g :ProjectRootExe grep<space>
nnoremap <expr> <leader>ep ':edit '.projectroot#guess().'/'
nnoremap <expr> <leader>rg ':!touch '.getcwd().'/.projectroot'
nnoremap <expr> <leader>re ':!rm -f '.projectroot#guess().'/.projectroot'
"}}}

" Plugin: localvimrc {{{
let g:localvimrc_name = [ '.vimrc.local' ]
" Load project-local settings before reading buffers.
let g:localvimrc_event = [ 'BufReadPre', 'BufWinEnter' ]
let g:localvimrc_sandbox = get(g:, 'localvimrc_sandbox', 1)
let g:localvimrc_ask = 1
" The personal file is sourced once by the main vimrc.
let s:personal_pattern = '^' . escape(resolve(expand('~/.vimrc.local')), '\.^$~[]*') . '$'
let g:localvimrc_blacklist = get(g:, 'localvimrc_blacklist', [])
if type(g:localvimrc_blacklist) == type('')
    let g:localvimrc_blacklist = [g:localvimrc_blacklist]
endif
call add(g:localvimrc_blacklist, s:personal_pattern)
let g:localvimrc_persistent = 1
let g:localvimrc_persistence_file = $DOTVIMDATAPATH . '/cache/localvimrc'
"}}}
