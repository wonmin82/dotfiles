" Keep vim-session's commands, state and locks while adapting Vim9 session output.
let s:here = resolve(expand('<sfile>:p'))
let s:providers = globpath(&runtimepath, 'autoload/xolox/session.vim', 0, 1)
call filter(s:providers, 'resolve(fnamemodify(v:val, ":p")) !=# s:here')
if empty(s:providers)
    finish
endif
execute 'source ' . fnameescape(s:providers[0])
if !exists('*funcref') || !exists('*xolox#session#save_state')
    finish
endif
let s:SaveState = funcref('xolox#session#save_state')

function! xolox#session#save_state(commands) abort
    let l:start = len(a:commands)
    call s:SaveState(a:commands)
    let l:first = index(a:commands, 'vim9script', l:start)
    if l:first < 0
        return
    endif

    " vim-session appends its legacy commands after the native :mksession body.
    let l:tail = match(a:commands, '^" Support for special windows', l:first + 1)
    if l:tail < 0
        throw 'vim-session: could not identify the native session section'
    endif
    let l:native = remove(a:commands, l:first, l:tail - 1)
    " vim-session fires SessionLoadPost after restoring its own windows.
    call filter(l:native, 'v:val !~# ''^\%(doautoall SessionLoadPost\|unlet g:SessionLoad\|# vim:\)''')
    let l:source = ['call dotvim#session#source([']
                \ + map(l:native, "'    \\ ' . string(v:val) . ','")
                \ + ['    \ ], expand("<sfile>:p"))']
    call extend(a:commands, l:source, l:first)
endfunction
