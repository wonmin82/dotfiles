function! dotvim#session#source(commands, session) abort
    let l:commands = copy(a:commands)
    for l:index in range(len(l:commands))
        let l:line = l:commands[l:index]
        " The generated session and its optional x.vim companion use the
        " original session path even though the native block is sourced here.
        if l:line =~# '^\%(v\|t\):this_session = '
            let l:commands[l:index] = matchstr(l:line, '^\a:this_session = ') . string(a:session)
        elseif l:line =~# '^var sx: string = expand('
            let l:commands[l:index] = 'var sx: string = ' . string(fnamemodify(a:session, ':r') . 'x.vim')
        endif
    endfor
    let l:script = tempname()
    try
        call writefile(l:commands, l:script)
        execute 'source ' . fnameescape(l:script)
    finally
        call delete(l:script)
    endtry
endfunction
