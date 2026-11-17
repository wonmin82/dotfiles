"*****************************************
"*                                       *
"*                .vimrc                 *
"*                                       *
"*            by Wonmin Jung             *
"*          wonmin82@gmail.com           *
"*      https://github.com/wonmin82      *
"*                                       *
"*****************************************
" TODO: Check compatibility in windows.
" TODO: Move cursor by display lines when wrapping
"       - http://vim.wikia.com/wiki/Move_cursor_by_display_lines_when_wrapping

set nocompatible

" Support both the checkout and an installed ~/.vimrc.
let s:vimrc_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let g:dotvim_root = isdirectory(s:vimrc_dir . '/config/clang-format')
            \ ? s:vimrc_dir : expand('~/.vim/dotvim')
let &runtimepath = escape(g:dotvim_root, ',') . ',' . &runtimepath

execute 'source ' . fnameescape(g:dotvim_root . '/config/paths.vim')
let g:c_syntax_for_h = 1
if filereadable(expand('~/.vimrc.local'))
    execute 'source ' . fnameescape(expand('~/.vimrc.local'))
endif

execute 'source ' . fnameescape(g:dotvim_root . '/config/plugins.vim')
filetype plugin indent on

for s:module in ['options', 'appearance', 'filetypes',
            \ 'tags', 'mappings', 'project', 'explorer', 'git', 'navigation',
            \ 'search', 'sessions', 'editing', 'languages', 'coc', 'formatting']
    execute 'source ' . fnameescape(g:dotvim_root . '/config/' . s:module . '.vim')
endfor
