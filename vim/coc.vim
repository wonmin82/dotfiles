" Completion uses Coc's popup; keep Ctrl-J/K for UltiSnips.
inoremap <silent><expr> <C-q> coc#refresh()
inoremap <silent><expr> <C-n> coc#pum#visible() ? coc#pum#next(1) : "\<C-n>"
inoremap <silent><expr> <C-p> coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"
inoremap <silent><expr> <C-y> coc#pum#visible() ? coc#pum#confirm() : "\<C-y>"
inoremap <silent><expr> <C-e> coc#pum#visible() ? coc#pum#cancel() : "\<C-e>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> <leader>rn <Plug>(coc-rename)
nmap <silent> <leader>ca <Plug>(coc-codeaction-cursor)
nnoremap <silent> K :call DotVimDocumentation()<CR>
nnoremap <silent> <F11> :call CocActionAsync('definitionHover')<CR>
nnoremap <silent> <F12> :CocList diagnostics<CR>
nnoremap <silent> <leader>sc :CocList diagnostics<CR>
nnoremap <silent> <leader>ms :call CocActionAsync('diagnosticToggle')<CR>
nnoremap <silent> <leader>sr :call CocActionAsync('diagnosticRefresh')<CR>

" Go/Rust servers are optional: enable them only when installed.
let s:servers = {}
if executable('gopls')
    let s:servers.go = {'command': 'gopls', 'filetypes': ['go', 'gomod'],
                \ 'rootPatterns': ['go.work', 'go.mod', '.git/']}
endif
if executable('rust-analyzer')
    let s:servers.rust = {'command': 'rust-analyzer', 'filetypes': ['rust'],
                \ 'rootPatterns': ['Cargo.toml', '.git/']}
endif
if executable('pylsp')
    let s:servers.python = {'command': 'pylsp', 'filetypes': ['python'],
                \ 'rootPatterns': ['pyproject.toml', 'setup.py', '.git/']}
endif
if executable('typescript-language-server')
    let s:servers.typescript = {'command': 'typescript-language-server',
                \ 'args': ['--stdio'],
                \ 'filetypes': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact'],
                \ 'rootPatterns': ['tsconfig.json', 'jsconfig.json', 'package.json', '.git/']}
endif
if !empty(s:servers)
    call coc#config('languageserver', s:servers)
endif

" Explicit supplemental analysis: run in the project root after saving files.
function! s:Cppcheck() abort
    if !executable('cppcheck')
        echoerr 'cppcheck is not installed'
        return
    endif
    let l:args = filereadable('compile_commands.json')
                \ ? '--project=compile_commands.json' : shellescape(expand('%:p'))
    let l:output = system('cppcheck --enable=warning,style,performance,portability '
                \ . '--template=gcc ' . l:args . ' 2>&1')
    call setqflist([], 'r', {'title': 'cppcheck', 'lines': split(l:output, "\n"),
                \ 'efm': '%f:%l:%c: %t%*[^:]: %m,%f:%l: %t%*[^:]: %m,%-G%.%#'})
    cwindow
endfunction
command! Cppcheck call <SID>Cppcheck()
