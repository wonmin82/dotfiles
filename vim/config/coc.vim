" Plugin: coc.nvim {{{
" Keep completion mappings explicit. Coc's compatibility check can copy a
" buffer-local expression mapping (such as Unite's Enter) into the global map.
let g:coc_disable_mappings_check = 1
if g:dotvim_coc_enabled
    let s:coc_config = $DOTVIMPATH . '/coc.vim'
    execute 'source ' . fnameescape(filereadable(s:coc_config) ? s:coc_config : g:dotvim_root . '/coc.vim')
endif
"}}}
