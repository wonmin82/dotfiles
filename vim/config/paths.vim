" Judging OS "{{{
let g:dotvim_platform = {}
let g:dotvim_platform.win64 = 0
let g:dotvim_platform.win32 = 0
let g:dotvim_platform.cygwin = 0
let g:dotvim_platform.macos = 0
let g:dotvim_platform.raspbian = 0
let g:dotvim_platform.synology = 0
let g:dotvim_platform.linux64 = 0
let g:dotvim_platform.linux32 = 0
let g:dotvim_platform.unix = 0

if has('win32')
	if has('win64')
		" Windows 64-bit
		let g:dotvim_platform.win64 = 1
	else
		" Windows 32-bit
		let g:dotvim_platform.win32 = 1
	endif
elseif has('win32unix')
	" cygwin
	let g:dotvim_platform.cygwin = 1
elseif !has('win32') && (has('mac') || has('macunix') || has('gui_macvim') ||
			\ (!isdirectory('/proc') && executable('sw_vers')))
	" MacOS
	let g:dotvim_platform.macos = 1
elseif glob('/etc/rpi-issue') != ''
	" Synology DSM
	let g:dotvim_platform.raspbian = 1
elseif glob('/etc/synouser.conf') != ''
	" Synology DSM
	let g:dotvim_platform.synology = 1
elseif glob('/lib*/ld-linux*64.so.2') != ''
	" Linux 64-bit
	let g:dotvim_platform.linux64 = 1
elseif glob('/lib*/ld-linux*.so.2') != ''
	" Linux 32-bit
	let g:dotvim_platform.linux32 = 1
else
	" Unix
	let g:dotvim_platform.unix = 1
endif
"}}}

" Set directories {{{
" Function: Make directory if doesn't exist "{{{
function! EnsureDirExists(dir)
	let rdir = expand(a:dir)
	if ! isdirectory(rdir)
		if exists("*mkdir")
			call mkdir(rdir, 'p')
			echon "Created directory: " . rdir . "\n\r"
		else
			echon "Please create directory: " . rdir . "\n\r"
		endif
	endif
endfunction
"}}}

" set data directories
let $DOTVIMPATH = expand('~/.vim')
let $DOTVIMDATAPATH = expand('~/.vim_data')
let $PLUGINPATH = $DOTVIMDATAPATH . '/bundle'
let $SWAPPATH = $DOTVIMDATAPATH . '/swap'
let $BACKUPPATH = $DOTVIMDATAPATH . '/backup'
let $UNDOPATH = $DOTVIMDATAPATH . '/undo'
let $SESSIONPATH = $DOTVIMDATAPATH . '/session'
let $ULTISNIPSPATH = $DOTVIMDATAPATH . '/UltiSnips'
let $UNITEPATH = $DOTVIMDATAPATH . '/cache/unite'
let $VIMFILERPATH = $DOTVIMDATAPATH . '/cache/vimfiler'
let $VIMSHELLPATH = $DOTVIMDATAPATH . '/cache/vimshell'
let $NEOMRUPATH = $DOTVIMDATAPATH . '/cache/neomru'

call EnsureDirExists($DOTVIMDATAPATH)
let s:viminfo = substitute(&viminfo, '\%(^\|,\)n.*$', '', '')
let &viminfo = (empty(s:viminfo) ? '' : s:viminfo . ',') . 'n' . $DOTVIMDATAPATH . '/viminfo'

call EnsureDirExists($SWAPPATH)
let &directory = escape($SWAPPATH, ',') . '//'

call EnsureDirExists($BACKUPPATH)
let &backupdir = escape($BACKUPPATH, ',') . '//'

call EnsureDirExists($UNDOPATH)
let &undodir = escape($UNDOPATH, ',') . '//'

call EnsureDirExists($SESSIONPATH)
let g:session_directory = $SESSIONPATH

call EnsureDirExists($ULTISNIPSPATH)
let g:UltiSnipsSnippetsDir = $ULTISNIPSPATH

call EnsureDirExists($UNITEPATH)
let g:unite_data_directory = $UNITEPATH

call EnsureDirExists($VIMFILERPATH)
let g:vimfiler_data_directory = $VIMFILERPATH

call EnsureDirExists($VIMSHELLPATH)
let g:vimshell_data_directory = $VIMSHELLPATH

call EnsureDirExists($NEOMRUPATH)
let g:neomru#file_mru_path = $NEOMRUPATH . '/file'
let g:neomru#directory_mru_path = $NEOMRUPATH . '/directory'
"}}}
