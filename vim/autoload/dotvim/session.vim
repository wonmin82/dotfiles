function! dotvim#session#source(commands, session) abort
    if get(a:commands, 0, '') !~# '^\s*vim9script\%(\s\|$\)'
        throw 'vim-session: Expected a Vim9 script in ' . a:session
    endif
    let l:commands = copy(a:commands)
    for l:index in range(len(l:commands))
        let l:line = l:commands[l:index]
        " Use the original session and companion paths inside the temporary script.
        if l:line =~# '^\s*\%(v\|t\):this_session\s*=\s*expand("<sfile>:p")\s*$'
            let l:commands[l:index] = matchstr(l:line, '^\s*\a:this_session\s*=\s*') . string(a:session)
        elseif l:line =~# '^\s*var sx:\s*string\s*=\s*expand("<sfile>:p:r")\s*\.\.\s*"x\.vim"\s*$'
            let l:commands[l:index] = 'var sx: string = ' . string(fnamemodify(a:session, ':r') . 'x.vim')
        endif
    endfor
    let l:script = tempname()
    let l:previous_session = v:this_session
    let l:had_session_load = exists('g:SessionLoad')
    let l:session_load = get(g:, 'SessionLoad', 0)
    let l:restored = 0
    try
        if writefile(l:commands, l:script) != 0
            throw 'vim-session: Could not write the temporary Vim9 script for ' . a:session
        endif
        execute 'source ' . fnameescape(l:script)
        let l:restored = 1
    finally
        call delete(l:script)
        if !l:restored
            let v:this_session = l:previous_session
            if l:had_session_load
                let g:SessionLoad = l:session_load
            else
                unlet! g:SessionLoad
            endif
        endif
    endtry
endfunction
