" Run with the installed plugins under the isolated smoke-test home.
let g:session_autosave = 'no'
let g:session_lock_directory = g:session_directory
let s:directory = $DOTVIM_TEST_OUTPUT
let s:second = s:directory . '/second file.txt'
call writefile(['first', 'second line', 'third'], s:second)
let s:fixture = s:directory . '/answer.c'

CloseSession
execute 'edit ' . fnameescape(s:fixture)
execute 'split ' . fnameescape(s:second)
normal! 2G4|
tabnew
execute 'edit ' . fnameescape(s:second)
split
normal! 3G2|
let s:layout_window = winnr()
SaveSession! layout
CloseSession
OpenSession layout
call assert_equal(2, tabpagenr('$'))
call assert_equal(2, tabpagenr())
call assert_equal(s:layout_window, winnr())
call assert_equal(2, winnr('$'))
call assert_equal(s:second, expand('%:p'))
call assert_equal([3, 2], getpos('.')[1:2])

tabfirst
call setqflist([{'filename': s:fixture, 'lnum': 1, 'text': 'saved quickfix'}])
copen
execute 'NERDTree ' . fnameescape(s:directory)
tablast
BufExplorerHorizontalSplit
let s:tab = tabpagenr()
let s:windows = map(gettabinfo(), 'len(v:val.windows)')
SaveSession! structured
let s:path = xolox#session#name_to_path('structured')
let s:lock = glob(g:session_lock_directory . '/*structured.vim.lock', 0, 1)
call assert_equal(1, len(s:lock))
call assert_equal(s:path, v:this_session)
call assert_true(index(xolox#session#complete_names('str', '', 0), 'structured') >= 0)

" Check the Vim9 companion path and the ordering of native and special windows.
call writefile(['let g:dotvim_session_companion = v:this_session'], fnamemodify(s:path, ':r') . 'x.vim')
let g:dotvim_session_events = []
augroup DotVimTestSessionLoad
    autocmd!
    autocmd SessionLoadPost * call add(g:dotvim_session_events, [bufname('%'),
                \ !empty(filter(getwininfo(), 'v:val.quickfix'))])
augroup END

CloseSession
call assert_equal('', v:this_session)
call assert_equal([], glob(g:session_lock_directory . '/*structured.vim.lock', 0, 1))
OpenSession structured
call assert_equal(s:path, v:this_session)
call assert_equal(s:path, g:dotvim_session_companion)
call assert_equal(s:tab, tabpagenr())
call assert_equal(s:windows, map(gettabinfo(), 'len(v:val.windows)'))
call assert_equal('saved quickfix', get(get(getqflist(), 0, {}), 'text', ''))
let s:filetypes = map(getwininfo(), 'getbufvar(v:val.bufnr, "&filetype")')
call assert_true(index(s:filetypes, 'nerdtree') >= 0)
call assert_true(index(s:filetypes, 'bufexplorer') >= 0)
call assert_true(!empty(filter(getwininfo(), 'v:val.quickfix')))
let s:post = filter(copy(g:dotvim_session_events), 'fnamemodify(v:val[0], ":t") ==# "answer.c"')
call assert_equal(1, len(s:post))
call assert_equal(1, get(get(s:post, 0, []), 1, 0))

tabfirst
let s:saved_windows = filter(getwininfo(), 'v:val.tabnr == 1 && fnamemodify(bufname(v:val.bufnr), ":t") ==# "second file.txt"')
call assert_equal(1, len(s:saved_windows))
if !empty(s:saved_windows)
    call win_gotoid(s:saved_windows[0].winid)
    call assert_equal([2, 4], getpos('.')[1:2])
endif

let g:session_autosave = 'yes'
let g:session_autosave_to = 'automatically saved'
call xolox#session#auto_save()
let s:auto = xolox#session#name_to_path(g:session_autosave_to)
call assert_true(filereadable(s:auto))
unlet g:session_autosave_to
let g:session_autosave = 'no'
CloseSession
DeleteSession! automatically\ saved
call assert_false(filereadable(s:auto))

" Restore a legacy on-disk session and retain empty editor sessions.
let s:legacy = xolox#session#name_to_path('legacy')
call writefile(['let v:this_session = expand("<sfile>:p")', 'edit ' . fnameescape(s:fixture)], s:legacy)
OpenSession legacy
call assert_equal(s:legacy, v:this_session)
call assert_equal('answer.c', expand('%:t'))
CloseSession
SaveSession! empty
CloseSession
OpenSession empty
call assert_equal('', bufname('%'))
call assert_equal([''], getline(1, '$'))
CloseSession
execute 'edit ' . fnameescape(s:fixture)
