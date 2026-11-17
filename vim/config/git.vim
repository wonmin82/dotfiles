" Plugin: fugitive {{{
" :Git
"nnoremap <f5> :call IsHerePluginBuffer()<cr>
nnoremap <silent> <expr> <f5> IsHerePluginBuffer() ? '' : ':Git<cr>'
inoremap <silent> <expr> <f5> IsHerePluginBuffer() ? '' : '<esc>:Git<cr>'
nnoremap <leader>gb :Git blame<cr>
nnoremap <leader>gc :Git commit<cr>
nnoremap <leader>gd :Gdiffsplit<cr>
nnoremap <leader>gp :Git push<cr>
nnoremap <leader>gr :GRemove<cr>
nnoremap <leader>gs :Git<cr>
nnoremap <leader>gw :Gwrite<cr>
" Quickly stage, commit, and push the current file. Useful for editing .vimrc
nnoremap <leader>gg :Gwrite<cr>:Git commit -m 'update'<cr>:Git push<cr>
"}}}
