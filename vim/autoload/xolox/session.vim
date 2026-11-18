" Keep vim-session's commands, state and locks while adapting Vim9 session output.
if exists('s:SaveState')
    finish
endif
if !exists('*xolox#session#save_state')
    let s:here = resolve(expand('<sfile>:p'))
    let s:providers = globpath(&runtimepath, 'autoload/xolox/session.vim', 0, 1)
    call filter(s:providers, 'resolve(fnamemodify(v:val, ":p")) !=# s:here')
    if empty(s:providers)
        finish
    endif
    execute 'source ' . fnameescape(s:providers[0])
endif
if !exists('*funcref') || !exists('*xolox#session#save_state')
            \ || !exists('*xolox#session#save_special_windows')
    finish
endif

" funcref() retains the original definition after its name is rebound.
let s:SaveState = funcref('xolox#session#save_state')
let s:SaveSpecialWindows = funcref('xolox#session#save_special_windows')
let s:boundary = {}
let s:marker = '" dotvim: end of native Vim9 session'
let s:vim9 = '^\s*vim9script\%(\s\|$\)'

function! xolox#session#save_special_windows(commands) abort
    if !empty(s:boundary) && match(a:commands, s:vim9) >= 0
        let s:boundary.calls += 1
        let s:boundary.offset = len(a:commands)
        call add(a:commands, s:marker)
    endif
    return s:SaveSpecialWindows(a:commands)
endfunction

function! xolox#session#save_state(commands) abort
    let l:generated = []
    let l:previous = s:boundary
    let l:boundary = {'offset': -1, 'calls': 0}
    let l:session = v:this_session
    let s:boundary = l:boundary
    try
        let l:result = s:SaveState(l:generated)
    finally
        let s:boundary = l:previous
        " :mksession sets this to its output path, which is temporary here.
        let v:this_session = l:session
    endtry

    let l:first = match(l:generated, s:vim9)
    if l:first < 0 && l:boundary.offset < 0
        call extend(a:commands, l:generated)
        return l:result
    endif

    let l:tail = index(l:generated, s:marker)
    let l:prefix = l:first > 0 ? l:generated[: l:first - 1] : []
    if l:first < 0 || l:boundary.calls != 1 || l:tail <= l:first + 1
                \ || l:tail != l:boundary.offset
                \ || count(l:generated, s:marker) != 1
                \ || match(l:generated, s:vim9, l:first + 1) >= 0
                \ || !empty(filter(copy(l:prefix), 'v:val !~# ''^\s*\%("\|$\)'''))
        throw 'vim-session: Invalid Vim9 session boundary. The session was not saved.'
    endif

    let l:native = l:generated[l:first : l:tail - 1]
    " vim-session fires SessionLoadPost after restoring its special windows.
    let l:post = '^\s*doautoall\s\+SessionLoadPost\s*$'
    let l:unload = '^\s*unlet\s\+g:SessionLoad\s*$'
    let l:post_at = match(l:native, l:post)
    let l:unload_at = match(l:native, l:unload)
    if l:post_at < 0 || l:unload_at <= l:post_at
                \ || match(l:native, l:post, l:post_at + 1) >= 0
                \ || match(l:native, l:unload, l:unload_at + 1) >= 0
        throw 'vim-session: Unexpected Vim9 session cleanup. The session was not saved.'
    endif
    call remove(l:native, l:unload_at)
    call remove(l:native, l:post_at)
    " The provider's state filter can introduce legacy comments.
    call filter(l:native, 'v:val !~# ''^\s*\%(#\s*vim:\|"\)''')
    if match(l:generated, '^NERDTree\s', l:tail + 1) >= 0
        " Current NERDTree names tab buffers NERD_tree_tab_N. The plugin
        " restores these windows itself, and an existing tree may own the name.
        call filter(l:native, 'v:val !~# ''^\s*file\s\+NERD_tree_tab_\d\+\s*$''')
    endif
    let l:source = ['call dotvim#session#source([']
                \ + map(l:native, "'    \\ ' . string(v:val) . ','")
                \ + ['    \ ], expand("<sfile>:p"))']
    call extend(a:commands, l:prefix + l:source + l:generated[l:tail + 1 :])
    return l:result
endfunction
