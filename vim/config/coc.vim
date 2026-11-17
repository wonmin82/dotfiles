" Plugin: coc.nvim {{{
if g:dotvim_coc_enabled
    let s:coc_config = $DOTVIMPATH . '/coc.vim'
    execute 'source ' . fnameescape(filereadable(s:coc_config) ? s:coc_config : g:dotvim_root . '/coc.vim')
endif
"}}}
