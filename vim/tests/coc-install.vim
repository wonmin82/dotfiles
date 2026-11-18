" Mimic the Coc release's installation buffer without starting its service.
function! s:show_progress() abort
    let l:buf = bufadd('[Coc Extensions]')
    execute 'vertical sbuffer ' . l:buf
    setlocal buftype=nofile bufhidden=wipe
    call setline(1, ['Installing, 1 remaining...', '', '- * coc-json'])
    sleep 300m
    return l:buf
endfunction

let s:editor = bufnr('%')
let s:progress = s:show_progress()
call assert_equal(s:editor, bufnr('%'))
call assert_equal([], win_findbuf(s:progress))
call assert_true(bufloaded(s:progress))
call setbufline(s:progress, 1, ['Install finished', '', "- \u2713 coc-json"])
sleep 300m
call assert_false(bufexists(s:progress))
call assert_equal(s:editor, bufnr('%'))

file editing.txt
let s:progress = s:show_progress()
call assert_equal(s:progress, bufnr('%'))
call assert_equal(2, winnr('$'))
call setbufline(s:progress, 1, ['Install finished', '', "- \u2713 coc-json"])
sleep 300m
call assert_false(bufexists(s:progress))
call assert_equal(s:editor, bufnr('%'))

let s:progress = s:show_progress()
call setbufline(s:progress, 1, ['Install finished', '', "- \u2717 coc-json failed"])
sleep 300m
call assert_equal(s:progress, bufnr('%'))
call assert_true(bufloaded(s:progress))

if !empty(v:errors)
    for s:error in v:errors
        echomsg s:error
    endfor
    cquit
endif
qa!
