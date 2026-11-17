let s:legacy_suffixes = ['-4.0', '-3.9', '-3.8', '-3.7', '-3.6', '-3.5', '-3.4']
let s:versions = {}

function! s:command() abort
    let l:explicit = get(g:, 'clang_format#command', '')
    let l:names = empty(l:explicit)
                \ ? ['clang-format'] + map(reverse(range(4, 23)), '"clang-format-" . v:val')
                \   + map(copy(s:legacy_suffixes), '"clang-format" . v:val')
                \ : [expand(l:explicit)]
    for l:name in l:names
        if executable(l:name)
            return exists('*exepath') ? exepath(l:name) : l:name
        endif
    endfor
    throw 'clang-format: executable not found (' . join(l:names, ', ') . ')'
endfunction

function! s:profile(command) abort
    " Recheck after the executable is changed or replaced.
    let l:identity = [getftime(a:command), getfsize(a:command), resolve(a:command)]
    let l:cached = get(s:versions, a:command, {})
    if get(l:cached, 'identity', []) ==# l:identity
        return l:cached.key
    endif

    let l:output = system(shellescape(a:command) . ' --version')
    let l:version = matchlist(l:output, '\cclang-format\s\+version\s\+\(\d\+\)\.\(\d\+\)')
    if v:shell_error || empty(l:version)
        throw 'clang-format: could not determine the version of ' . a:command
    endif
    let l:major = str2nr(l:version[1])
    let l:key = 'v' . l:major . '.' . (l:major == 3 ? str2nr(l:version[2]) : 0)
    if l:major < 3 || l:major > 23 || (l:major == 3 && !has_key(g:clang_format_configs, l:key))
        throw 'clang-format: unsupported version ' . l:version[1] . '.' . l:version[2]
                    \ . ' (supported: 3.4–23)'
    endif
    if l:major >= 14 && !has_key(g:clang_format_configs, l:key)
        execute 'source ' . fnameescape(g:dotvim_root . '/config/clang-format/v' . l:major . '.vim')
    endif
    let s:versions[a:command] = {'identity': l:identity, 'key': l:key}
    return l:key
endfunction

function! s:has_style_file(filename) abort
    let l:dir = fnamemodify(a:filename, ':h')
    while !empty(l:dir)
        if filereadable(l:dir . '/.clang-format') || filereadable(l:dir . '/_clang-format')
            return 1
        endif
        let l:parent = fnamemodify(l:dir, ':h')
        if l:dir ==# l:parent
            break
        endif
        let l:dir = l:parent
    endwhile
    return 0
endfunction

function! s:style(profile) abort
    let l:options = copy(g:clang_format_configs[a:profile])
    if str2nr(a:profile[1:]) < 14
        call extend(l:options, {'BasedOnStyle': get(g:, 'clang_format#code_style', 'Google')}, 'keep')
    endif
    call extend(l:options, get(g:, 'clang_format#style_options', {}))
    call extend(l:options, get(get(g:, 'clang_format#filetype_style_options', {}), &filetype, {}))
    " JSON flow mappings are valid YAML and preserve nested lists, booleans,
    " regular expressions and empty strings in every supported schema.
    return exists('*json_encode') ? json_encode(l:options) : string(l:options)
endfunction

function! dotvim#format#run(first, last) abort
    let l:command = s:command()
    let l:profile = s:profile(l:command)
    let l:filename = expand('%:p')
    if empty(l:filename)
        let l:extension = get({'cpp': 'cpp', 'objc': 'm', 'java': 'java',
                    \ 'javascript': 'js', 'typescript': 'ts', 'cuda': 'cu',
                    \ 'proto': 'proto', 'arduino': 'ino', 'vala': 'vala'}, &filetype, 'c')
        let l:filename = getcwd() . '/untitled.' . l:extension
    endif

    let l:source = join(getline(1, '$'), "\n") . (&l:endofline ? "\n" : '')
    if get(g:, 'clang_format#detect_style_file', 1) && s:has_style_file(l:filename)
        let l:style = 'file'
    elseif get(g:, 'clang_format#enable_fallback_style', 1)
        let l:style = s:style(l:profile)
    else
        return l:source
    endif

    let l:range = a:first == 1 && a:last == line('$') ? ''
                \ : printf(' -lines=%d:%d', a:first, a:last)
    let l:args = get(g:, 'clang_format#extra_args', '')
    if type(l:args) == type([])
        let l:args = join(map(copy(l:args), 'shellescape(v:val)'), ' ')
    endif
    let l:errors = tempname()
    try
        let l:output = system(shellescape(l:command) . l:range
                    \ . ' ' . shellescape('-style=' . l:style)
                    \ . ' ' . shellescape('-assume-filename=' . l:filename)
                    \ . ' ' . l:args . ' -- 2>' . shellescape(l:errors), l:source)
        let l:status = v:shell_error
        let l:diagnostic = filereadable(l:errors) ? join(readfile(l:errors), "\n") : ''
        if l:status
            throw 'clang-format: exit ' . l:status . (empty(l:diagnostic) ? ' ' . l:output : "\n" . l:diagnostic)
        endif
        if !empty(l:diagnostic)
            echomsg l:diagnostic
        endif
        return substitute(l:output, '\r\n', "\n", 'g')
    finally
        call delete(l:errors)
    endtry
endfunction

function! dotvim#format#replace(first, last) abort
    if !&l:modifiable
        return
    endif
    try
        let l:output = dotvim#format#run(a:first, a:last)
    catch /^clang-format:/
        echoerr v:exception
        return
    endtry
    let l:lines = split(substitute(l:output, '\n$', '', ''), "\n", 1)
    if empty(l:lines)
        let l:lines = ['']
    endif
    if l:lines ==# getline(1, '$')
        return
    endif
    let l:view = winsaveview()
    try
        keepjumps call setline(1, l:lines)
        if len(l:lines) < line('$')
            undojoin
            execute 'keepjumps ' . (len(l:lines) + 1) . ',$delete _'
        endif
    finally
        call winrestview(l:view)
    endtry
endfunction

function! dotvim#format#start_operator() abort
    let s:operator_view = winsaveview()
    let &operatorfunc = 'dotvim#format#operator'
    return 'g@'
endfunction

function! dotvim#format#operator(type) abort
    let l:view = get(s:, 'operator_view', winsaveview())
    unlet! s:operator_view
    try
        call dotvim#format#replace(line("'["), line("']"))
    finally
        call winrestview(l:view)
    endtry
endfunction

function! dotvim#format#toggle() abort
    let g:clang_format#auto_format = !g:clang_format#auto_format
    echo 'Auto clang-format: ' . (g:clang_format#auto_format ? 'enabled' : 'disabled')
endfunction
