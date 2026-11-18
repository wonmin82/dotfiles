" The copied provider in runtimepath changes only the special-window call site.
let &runtimepath .= ',' . escape($DOTVIM_TEST_PROVIDER, ',')
let &runtimepath .= ',' . escape($DOTVIM_TEST_BUNDLES . '/xolox/vim-session', ',')
let &runtimepath .= ',' . escape($DOTVIM_TEST_BUNDLES . '/xolox/vim-misc', ',')
set nomodified
execute 'source ' . fnameescape($DOTVIM_TEST_VIMRC)
set nomodified
let g:session_autosave = 'no'
let g:session_lock_directory = g:session_directory
runtime plugin/session.vim

let s:file = $DOTVIM_TEST_OUTPUT . '/boundary file.txt'
call writefile(['one', 'two'], s:file)
execute 'edit ' . fnameescape(s:file)
SaveSession! boundary
let s:path = xolox#session#name_to_path('boundary')
let s:original = readfile(s:path, 'b')
call assert_true(!empty(s:original))
call assert_equal(-1, match(s:original, 'dotvim: end of native Vim9 session'))
call assert_equal(-1, match(s:original, 'Support for special windows'))
CloseSession
OpenSession boundary
call assert_equal(s:file, expand('%:p'))
call assert_equal(s:path, v:this_session)

if match(s:original, '^call dotvim#session#source(') >= 0
    call writefile(['Vim9'], $DOTVIM_TEST_OUTPUT . '/format')
    let s:tempdir = fnamemodify(tempname(), ':h')
    let s:before = sort(readdir(s:tempdir))
    for g:dotvim_test_boundary in ['missing', 'duplicate', 'moved', 'unexpected', 'special failure']
        try
            SaveSession! boundary
            call assert_report('Save succeeded with invalid provider output: ' . g:dotvim_test_boundary)
        catch /^vim-session:/
            call assert_match('The session was not saved', v:exception)
        catch /^dotvim test: special window failure$/
            call assert_equal('special failure', g:dotvim_test_boundary)
        endtry
        call assert_equal(s:path, v:this_session)
        call assert_equal(s:original, readfile(s:path, 'b'))
        call assert_equal(s:before, sort(readdir(s:tempdir)))
    endfor
    unlet g:dotvim_test_boundary

    try
        call dotvim#session#source(['vim9script', 'g:SessionLoad = 1',
                    \ 'v:this_session = expand("<sfile>:p")', 'throw "dotvim test: restore failure"'],
                    \ s:path . '.other')
        call assert_report('Restore should have thrown')
    catch /^dotvim test: restore failure$/
    endtry
    call assert_false(exists('g:SessionLoad'))
    call assert_equal(s:path, v:this_session)
    call assert_equal(s:before, sort(readdir(s:tempdir)))
    call assert_equal(s:original, readfile(s:path, 'b'))
    try
        call dotvim#session#source([], s:path)
        call assert_report('Restore should reject a missing Vim9 directive')
    catch /^vim-session: Expected a Vim9 script/
    endtry

    let s:permissions = getfperm(s:path)
    call assert_true(setfperm(s:path, 'r--------'))
    try
        SaveSession! boundary
        call assert_report('Save should have failed with a read-only session')
    catch /^Vim\%((\a\+)\)\=:E482:/
    finally
        call setfperm(s:path, s:permissions)
    endtry
    call assert_equal(s:original, readfile(s:path, 'b'))
    call assert_equal(s:path, v:this_session)

    " Verify that a failing capture does not leave a marker or stale state behind.
    SaveSession! boundary
    CloseSession
    OpenSession boundary
    call assert_equal(s:file, expand('%:p'))
else
    call writefile(['legacy Vimscript'], $DOTVIM_TEST_OUTPUT . '/format')
    " Exercise the native legacy writer with the provider call bypassed.
    let g:dotvim_test_boundary = 'missing'
    SaveSession! boundary
    let s:legacy = readfile(s:path, 'b')
    call assert_equal(-1, match(s:legacy, '^call dotvim#session#source('))
    CloseSession
    OpenSession boundary
    call assert_equal(s:file, expand('%:p'))
endif

if !empty(v:errors)
    for s:error in v:errors
        echomsg s:error
    endfor
    cquit
endif
qa!
