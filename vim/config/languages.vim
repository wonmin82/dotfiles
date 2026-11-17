" Plugin: rust.vim {{{
let g:rustfmt_autosave = 0
autocmd FileType rust
			\   noremap <buffer> <leader>cf :<c-u>RustFmt<cr>
"}}}

" Plugin: vim-go {{{
let s:coc_handles_go = g:dotvim_coc_enabled && executable('gopls')
let g:go_auto_type_info = !s:coc_handles_go
let g:go_code_completion_enabled = !s:coc_handles_go
let g:go_def_mapping_enabled = !s:coc_handles_go
let g:go_doc_keywordprg_enabled = !s:coc_handles_go
let g:go_template_autocreate = 0

let g:go_highlight_build_constraints = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1

let g:go_fmt_command = 'goreturns'
let g:go_fmt_options = {
			\   'gofmt': '-s',
			\   'goreturns': ''
			\}
let g:go_fmt_autosave = 0
let g:go_imports_mode = 'goimports'
let g:go_imports_autosave = 0
let g:go_mod_fmt_autosave = 0
let g:go_metalinter_autosave = 0

autocmd FileType go
			\   noremap <buffer> <leader>cf :<c-u>GoFmt<cr>
autocmd FileType gomod
			\   noremap <buffer> <leader>cf :<c-u>GoModFmt<cr>
"}}}
