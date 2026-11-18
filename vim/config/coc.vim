" Plugin: coc.nvim {{{
" Keep completion mappings explicit. Coc's compatibility check can copy a
" buffer-local expression mapping (such as Unite's Enter) into the global map.
let g:coc_disable_mappings_check = 1

function! s:coc_install_progress(buf, state, timer) abort
    if !bufloaded(a:buf) || getbufvar(a:buf, '&buftype') !=# 'nofile'
        call timer_stop(a:timer)
        return
    endif
    let l:lines = getbufline(a:buf, 1, '$')
    let l:status = get(l:lines, 0, '')
    if empty(l:status)
        return
    endif
    " Coc writes this header once every extension has a terminal status.
    if l:status ==# 'Install finished'
        call timer_stop(a:timer)
        let l:items = l:lines[2:]
        let l:incomplete = filter(copy(l:items), 'v:val !~# ''^- \%u2713 ''')
        if !empty(l:items) && empty(l:incomplete)
            execute 'silent bwipeout ' . a:buf
            redraw
            echomsg 'Coc: Extension installation complete.'
        elseif a:state.in_messages
            echomsg 'Coc: Extension installation failed. See :CocOpenLog for details.'
        endif
        return
    endif
    if l:status !~# '^Installing, \d\+ remaining\.\.\.$'
        call timer_stop(a:timer)
        return
    endif

    if a:state.use_messages && !a:state.in_messages && win_id2win(a:state.win) > 0 && winnr('$') > 1
        " Keep the scratch buffer loaded so Coc can continue updating it.
        call setbufvar(a:buf, '&bufhidden', 'hide')
        call win_execute(a:state.win, 'silent close')
        let a:state.in_messages = 1
    endif
    if a:state.in_messages && l:status !=# a:state.status
        let a:state.status = l:status
        redraw
        echo 'Coc: ' . l:status
    endif
endfunction

function! s:watch_coc_install() abort
    if get(b:, 'dotvim_coc_install_watched', 0)
        return
    endif
    let b:dotvim_coc_install_watched = 1
    let l:previous = winbufnr(winnr('#'))
    let l:use_messages = !argc() && l:previous > 0 && empty(bufname(l:previous))
                \ && empty(getbufvar(l:previous, '&buftype')) && !getbufvar(l:previous, '&modified')
    let l:state = {'win': win_getid(), 'use_messages': l:use_messages, 'in_messages': 0, 'status': ''}
    call timer_start(200, function('s:coc_install_progress', [bufnr('%'), l:state]), {'repeat': -1})
endfunction

augroup DotVimCocInstall
    autocmd!
    if exists('*timer_start') && exists('*win_execute')
        autocmd BufWinEnter \[Coc\ Extensions\] call s:watch_coc_install()
    endif
augroup END

if g:dotvim_coc_enabled
    let s:coc_config = $DOTVIMPATH . '/coc.vim'
    execute 'source ' . fnameescape(filereadable(s:coc_config) ? s:coc_config : g:dotvim_root . '/coc.vim')
endif
"}}}
