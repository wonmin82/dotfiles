" Optional smoke test for existing bundles, using the isolated test home.
for s:repo in ['Shougo/unite.vim', 'Shougo/neomru.vim', 'osyo-manga/unite-quickfix',
            \ 'jlanzarotta/bufexplorer', 'tpope/vim-fugitive',
            \ 'preservim/nerdtree', 'scrooloose/nerdtree',
            \ 'preservim/tagbar', 'majutsushi/tagbar',
            \ 'xolox/vim-session', 'xolox/vim-misc']
    let s:path = $DOTVIM_TEST_BUNDLES . '/' . s:repo
    if isdirectory(s:path)
        let &runtimepath .= ',' . escape(s:path, ',')
    endif
endfor

let g:start_session_from_cmdline = 1
execute 'source ' . fnameescape($DOTVIM_TEST_VIMRC)
set nomodified
for s:plugin in ['unite', 'neomru', 'bufexplorer', 'fugitive', 'NERD_tree', 'tagbar', 'session']
    execute 'runtime plugin/' . s:plugin . '.vim'
endfor
execute 'edit ' . fnameescape($DOTVIM_TEST_OUTPUT . '/answer.c')
call assert_equal(2, exists(':OpenSession'))
call assert_equal(2, exists(':Unite'))
call assert_equal(2, exists(':Git'))
call assert_equal(2, exists(':TagbarToggle'))
call assert_equal(2, exists(':NERDTreeToggle'))
call assert_equal(2, exists(':BufExplorer'))

SaveSession! dotvim-smoke
call assert_true(filereadable(g:session_directory . '/dotvim-smoke.vim'))
enew
OpenSession dotvim-smoke
call assert_equal('answer.c', expand('%:t'))
call assert_match('/dotvim-smoke\.vim$', v:this_session)

execute "normal \<F3>"
call assert_match('BufExplorer', bufname('%'))
buffer answer.c
execute 'normal ,vf'
call assert_equal('nerdtree', &filetype)
NERDTreeClose

call unite#custom#profile('default', 'context', {'start_insert': 0})
call setqflist([{'filename': expand('%:p'), 'lnum': 1, 'text': 'Answer'}])
call feedkeys("\<Space>q", 'xt')
call assert_equal('quickfix', get(unite#get_current_unite(), 'buffer_name', ''))
close
execute "normal \<C-P>"
call assert_equal('buffers', get(unite#get_current_unite(), 'buffer_name', ''))
close

execute 'edit ' . fnameescape($DOTVIM_TEST_VIMRC)
execute "normal \<F5>"
call assert_match('fugitive', bufname('%'))

call writefile(v:errors, $DOTVIM_TEST_OUTPUT . '/vim-errors')
if !empty(v:errors)
    cquit
endif
qa!
