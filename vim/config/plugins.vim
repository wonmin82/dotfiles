" My Bundles here:
" Note: You don't set dein.vim setting in .gvimrc!
let g:dotvim_vim_go_enabled = 0
" Coc release requires Vim 9.0.0438+ and Node.js 22.15+.
let g:dotvim_coc_enabled = has('patch-9.0.0438') && has('job') && has('channel')
            \ && !get(g:, 'dotvim_disable_plugins', 0) && executable('node')
if g:dotvim_coc_enabled
    let s:node_version = split(substitute(system('node --version'), '^v', '', ''), '\.')
    let g:dotvim_coc_enabled = len(s:node_version) >= 2
                \ && (str2nr(s:node_version[0]) > 22
                \ || (str2nr(s:node_version[0]) == 22 && str2nr(s:node_version[1]) >= 15))
endif
if get(g:, 'dotvim_disable_plugins', 0)
    finish
endif

let s:auto_install = has('vim_starting') && &loadplugins
            \ && get(g:, 'dotvim_auto_install_plugins', 1)
let g:dein#install_max_processes = 4        " default is 8
let g:dein#types#git#default_protocol = 'https'
let g:dein#types#git#clone_depth = 0
let g:dein#install_process_timeout = 1200
" Use a separate cache so obsolete bundles in the previous aggregate stay inactive.
let g:dein#cache_directory = $DOTVIMDATAPATH . '/cache/dein-dotvim'

function! s:bootstrap_dein(path) abort
    if !executable('git')
        echomsg 'dotvim: Git is required to install dein.vim.'
        return 0
    endif
    call EnsureDirExists(fnamemodify(a:path, ':h'))
    let l:branch = v:version < 802 ? ' --branch 1.5' : ''
    execute 'silent !git clone --progress' . l:branch
                \ . ' https://github.com/Shougo/dein.vim.git ' . shellescape(a:path, 1)
    if v:shell_error || !filereadable(a:path . '/autoload/dein.vim')
        echomsg 'dotvim: Could not install dein.vim. See Git output above.'
        return 0
    endif
    return 1
endfunction

let s:dein_path = $PLUGINPATH . '/dein.vim'
let s:managed_dein_path = $PLUGINPATH . '/repos/github.com/Shougo/dein.vim'
if !filereadable(s:dein_path . '/autoload/dein.vim')
            \ && filereadable(s:managed_dein_path . '/autoload/dein.vim')
    let s:dein_path = s:managed_dein_path
endif
if filereadable(s:dein_path . '/autoload/dein.vim')
            \ || (s:auto_install && empty(globpath(&runtimepath, 'autoload/dein.vim'))
            \     && s:bootstrap_dein(s:dein_path))
    let &runtimepath .= ',' . escape(s:dein_path, ',')
endif
if empty(globpath(&runtimepath, 'autoload/dein.vim'))
    let g:dotvim_coc_enabled = 0
    finish
endif

function! s:add(repo, ...) abort
    " Load each installed bundle directly to preserve its own runtime paths.
    let l:options = a:0 ? copy(a:1) : {}
    call dein#add(a:repo, extend(l:options, {'merged': 0}, 'keep'))
endfunction

function! s:add_moved(repo, previous) abort
    let l:base = $PLUGINPATH . '/repos/github.com/'
    let l:old_path = l:base . a:previous
    let l:options = !isdirectory(l:base . a:repo) && isdirectory(l:old_path)
                \ ? {'path': l:old_path} : {}
    call s:add(a:repo, l:options)
endfunction

let s:vimrcs = [expand('$MYVIMRC'), expand('~/.vimrc.local'), expand('<sfile>:p')]
call filter(s:vimrcs, 'filereadable(v:val)')
if dein#begin($PLUGINPATH, s:vimrcs) == 1
    let g:dotvim_coc_enabled = 0
    finish
endif
if v:version >= 802
    let s:dein_options = filereadable(s:dein_path . '/autoload/dein.vim')
                \ && !filereadable(s:managed_dein_path . '/autoload/dein.vim') ? {'path': s:dein_path} : {}
    call s:add('Shougo/dein.vim', s:dein_options)
else
    call s:add(s:dein_path)
endif

if !g:dotvim_platform.synology
	call s:add('Shougo/vimproc.vim', {
				\ 'build' : 'make'
				\})
endif

" Fuzzy search
if executable('fzf') && has('terminal') && v:version >= 800
    call s:add('junegunn/fzf')
    call s:add('junegunn/fzf.vim', {'depends': 'fzf'})
endif
call s:add('Shougo/unite.vim')
call s:add('Shougo/unite-outline')
call s:add('Shougo/unite-help')
call s:add('Shougo/neomru.vim')
call s:add('tsukkee/unite-tag')
call s:add('osyo-manga/unite-quickfix')
call s:add('thinca/vim-unite-history')
call s:add('mileszs/ack.vim')

" File browsing
call s:add_moved('preservim/nerdtree', 'scrooloose/nerdtree')
call s:add('Shougo/vimfiler')

" Session
call s:add('xolox/vim-misc')
call s:add('xolox/vim-session', {
			\   'lazy': 0,
			\   'depends': 'xolox/vim-misc',
			\   'augroup': 'PluginSession',
			\   'autoload': {
			\   'commands': [
			\   {
			\       'name': [ 'OpenSession', 'CloseSession' ],
			\       'complete': 'customlist,xolox#session#complete_names'
			\   },
			\   {
			\       'name': [ 'SaveSession' ],
			\       'complete': 'customlist,xolox#session#complete_names_with_suggestions'
			\   }
			\   ],
			\       'functions': [ 'xolox#session#complete_names',
			\                      'xolox#session#complete_names_with_suggestions' ]
			\}})

" Shell
call s:add('thinca/vim-quickrun')
call s:add('Shougo/vimshell')
call s:add('tpope/vim-dispatch')

" Git
call s:add('tpope/vim-fugitive')

" Tags
call s:add_moved('preservim/tagbar', 'majutsushi/tagbar')

" Status line
call s:add('vim-airline/vim-airline')
call s:add('vim-airline/vim-airline-themes')

call s:add('embear/vim-localvimrc')
call s:add_moved('preservim/nerdcommenter', 'scrooloose/nerdcommenter')
call s:add('jlanzarotta/bufexplorer')
call s:add('dbakker/vim-projectroot')
call s:add('godlygeek/tabular')
call s:add_moved('easymotion/vim-easymotion', 'Lokaltog/vim-easymotion')
call s:add('vim-scripts/ingo-library')
call s:add('vim-scripts/IndentTab', {
			\   'depends': 'vim-scripts/ingo-library'
			\})
call s:add('vim-scripts/IndentConsistencyCop')
call s:add('vim-scripts/IndentConsistencyCopAutoCmds')
call s:add('ntpeters/vim-better-whitespace')

call s:add('rust-lang/rust.vim')
call s:add('cespare/vim-toml')
if has('nvim') ? has('nvim-0.4.0') : has('patch-8.2.5072')
    call s:add('fatih/vim-go')
    let g:dotvim_vim_go_enabled = 1
endif

call s:add('kergoth/vim-bitbake')
call s:add('peterhoeg/vim-qml')

call s:add('Konfekt/FastFold')
call s:add('vivien/vim-linux-coding-style')
if v:version >= 700 && !g:dotvim_platform.raspbian && !g:dotvim_platform.synology
	call s:add('psf/black')
endif
call s:add('maksimr/vim-jsbeautify')
call s:add('z0mbix/vim-shfmt')
if v:version >= 704 && !g:dotvim_platform.raspbian && !g:dotvim_platform.synology
	call s:add('SirVer/ultisnips')
endif
call s:add('honza/vim-snippets')

if g:dotvim_coc_enabled
    let g:coc_config_home = $DOTVIMPATH
    let g:coc_data_home = $DOTVIMDATAPATH . '/coc'
    let g:coc_global_extensions = get(g:, 'coc_global_extensions',
                \ s:auto_install ? ['coc-clangd', 'coc-json'] : [])
    call s:add('neoclide/coc.nvim', {'rev': 'release', 'merged': 0})
    let g:dotvim_coc_enabled = isdirectory(get(dein#get('coc.nvim'), 'path', ''))
endif

call s:add('tomasr/molokai')
call s:add('altercation/vim-colors-solarized')
call s:add('nanotech/jellybeans.vim')
call s:add('noahfrederick/vim-noctu')


call dein#end()

command! DotVimInstall call dein#install()

function! s:install_startup_bundles() abort
    let l:more = &more
    let l:autosave = get(g:, 'session_autosave', 'no')
    set nomore
    let g:session_autosave = 'no'
    try
        echomsg 'dotvim: Installing missing plugins.'
        if dein#install() == 0 && dein#check_install() == 0
            redraw!
            echomsg 'dotvim: Plugin installation complete. Restart Vim to continue.'
            qall
        endif
        echomsg 'dotvim: Plugin installation did not finish. See :messages for details.'
    finally
        let &more = l:more
        let g:session_autosave = l:autosave
    endtry
endfunction

if s:auto_install
    silent let s:missing = dein#check_install()
    if s:missing > 0
        call s:install_startup_bundles()
    endif
endif
" Function: Helper function for dein.vim {{{
function! DeinUpdate()
	let autosave_save = g:session_autosave
	let g:session_autosave = 'no'

	let more_save = &more
	let showcmd_save = &showcmd
	let ruler_save = &ruler
	let cmdheight_save = &cmdheight

	set nomore
	set noshowcmd
	set noruler
	set cmdheight=10

	try
		call dein#update()
	finally
		let &more = more_save
		let &showcmd = showcmd_save
		let &ruler = ruler_save
		let &cmdheight = cmdheight_save
		let g:session_autosave = autosave_save
	endtry
endfunc
"}}}
