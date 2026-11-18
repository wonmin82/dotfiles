" Invoked by verify.py with an isolated home and an installed clang-format.
execute 'edit ' . fnameescape($DOTVIM_TEST_SOURCE)
let g:clang_format#command = $DOTVIM_TEST_CLANG

call assert_equal('cpp', &filetype)
call assert_equal(4, &l:shiftwidth)
call assert_equal(0, &l:expandtab)
call assert_match('ClangFormat', maparg(',cf', 'n'))
call assert_match('ClangFormat', maparg(',cf', 'x'))
call assert_match('operator-clang-format', maparg(',x', 'n'))
call assert_match('ClangFormatAutoToggle', maparg(',C', 'n'))
call assert_match('BrowseBuffers', maparg('<F3>', 'n'))
call assert_match('DotVimFiles', maparg('[unite]f', 'n'))
call assert_match('UniteResume', maparg('<C-r>', 'n'))
call assert_match('VimFiler\|ToggleFileTree', maparg(',vf', 'n'))
call assert_match('Git', maparg(',gs', 'n'))
call assert_match('DotVimOutline', maparg('<F4>', 'n'))
call assert_equal(1, g:localvimrc_ask)
call assert_equal(1, g:localvimrc_sandbox)
call assert_equal(expand('~/.vim_data/session'), g:session_directory)
call assert_equal('indent,commentprefix,string', g:IndentTab_scopes)
call assert_equal(0, g:dotvim_coc_enabled)
call assert_match(escape($TMPDIR, '\'), tempname())

execute 'normal ,cf'
let s:formatted = getline(1, '$')
call writefile(s:formatted, $DOTVIM_TEST_OUTPUT . '/vim.cpp')
ClangFormat
call assert_equal(s:formatted, getline(1, '$'))
call assert_equal(0, g:clang_format#auto_format)

let s:path = $PATH
let $PATH = $DOTVIM_TEST_PATH
unlet g:clang_format#command
call assert_equal(s:formatted, split(dotvim#format#run(1, line('$')), "\n"), 'Versioned PATH entry')
let $PATH = s:path
let g:clang_format#command = $DOTVIM_TEST_CLANG

execute 'edit! ' . fnameescape($DOTVIM_TEST_RANGE)
let s:unformatted = getline(1, '$')
let s:expected = split(substitute(dotvim#format#run(1, 2), '\n$', '', ''), "\n", 1)
execute 'normal ggVj,cf'
call assert_equal(s:expected, getline(1, '$'), 'Visual range')
call assert_equal(s:unformatted[-1], getline('$'), 'Outside visual range')
edit!
call cursor(1, 1)
execute 'normal ,xj'
call assert_equal(s:expected, getline(1, '$'), 'Operator range')
call assert_equal(1, line('.'), 'Operator restores view')

execute 'edit! ' . fnameescape($DOTVIM_TEST_PROJECT)
execute 'normal ,C'
call assert_equal(1, g:clang_format#auto_format)
write
call assert_equal(['int *p;', 'void f() {', '  ++p;', '}'], getline(1, '$'))
execute 'normal ,C'
call assert_equal(0, g:clang_format#auto_format)

execute 'edit! ' . fnameescape($DOTVIM_TEST_BAD_STYLE)
let s:unformatted = getline(1, '$')
try
    ClangFormat
    call assert_report('Invalid project style was accepted')
catch /clang-format: exit/
    call assert_equal(s:unformatted, getline(1, '$'))
endtry

let g:clang_format#command = $DOTVIM_TEST_UNSUPPORTED
try
    call dotvim#format#run(1, line('$'))
    call assert_report('Unsupported executable was accepted')
catch /^clang-format: unsupported version 24\.0/
endtry
let g:clang_format#command = '/nonexistent/dotvim-clang-format'
try
    call dotvim#format#run(1, line('$'))
    call assert_report('Missing explicit executable was accepted')
catch /^clang-format: executable not found/
endtry

setlocal filetype=python
call assert_match('Black', maparg(',cf', 'n'))
call writefile(v:errors, $DOTVIM_TEST_OUTPUT . '/vim-errors')
if !empty(v:errors)
    cquit
endif
qa!
