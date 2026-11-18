" cscope settings {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CSCOPE settings for vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" This file contains some boilerplate settings for vim's cscope interface,
" plus some keyboard mappings that I've found useful.
"
" USAGE:
" -- vim 6:     Stick this file in your ~/.vim/plugin directory (or in a
"               'plugin' directory in some other directory that is in your
"               'runtimepath'.
"
" -- vim 5:     Stick this file somewhere and 'source cscope.vim' it from
"               your ~/.vimrc file (or cut and paste it into your .vimrc).
"
" NOTE:
" These key maps use multiple keystrokes (2 or 3 keys).  If you find that vim
" keeps timing you out before you can complete them, try changing your timeout
" settings, as explained below.
"
" Happy cscoping,
"
" Jason Duell       jduell@alumni.princeton.edu     2002/3/7
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim...
if has("cscope")

	""""""""""""" Standard cscope/vim boilerplate

	" use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
	" set cscopetag
	" disable above
	set nocscopetag

	" check cscope for definition of a symbol before checking ctags: set to 1
	" if you want the reverse search order.
	set csto=0

	" add any cscope database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
		" else add the database pointed to by environment variable
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif

	" show msg when any other cscope db added
	set cscopeverbose


	""""""""""""" My cscope/vim key mappings
	"
	" The following maps all invoke one of the following cscope search types:
	"
	"   's'   symbol: find all references to the token under cursor
	"   'g'   global: find global definition(s) of the token under cursor
	"   'c'   calls:  find all calls to the function name under cursor
	"   't'   text:   find all instances of the text under cursor
	"   'e'   egrep:  egrep search for the word under cursor
	"   'f'   file:   open the filename under cursor
	"   'i'   includes: find files that include the filename under cursor
	"   'd'   called: find functions that function under cursor calls
	"
	" Below are three sets of the maps: one set that just jumps to your
	" search result, one that splits the existing vim window horizontally and
	" diplays your search result in the new window, and one that does the same
	" thing, but does a vertical split instead (vim 6 only).
	"
	" I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
	" unlikely that you need their default mappings (CTRL-\'s default use is
	" as part of CTRL-\ CTRL-N typemap, which basically just does the same
	" thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
	" If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
	" of these maps to use other keys.  One likely candidate is 'CTRL-_'
	" (which also maps to CTRL-/, which is easier to type).  By default it is
	" used to switch between Hebrew and English keyboard mode.
	"
	" All of the maps involving the <cfile> macro use '^<cfile>$': this is so
	" that searches over '#include <time.h>" return only references to
	" 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
	" files that contain 'time.h' as part of their name).


	" To do the first type of search, hit 'CTRL-\', followed by one of the
	" cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
	" search will be displayed in the current window.  You can use CTRL-T to
	" go back to where you were before the search.
	"

	nmap <c-\>s :cs find s <c-R>=expand("<cword>")<cr><cr>
	nmap <c-\>g :cs find g <c-R>=expand("<cword>")<cr><cr>
	nmap <c-\>c :cs find c <c-R>=expand("<cword>")<cr><cr>
	nmap <c-\>t :cs find t <c-R>=expand("<cword>")<cr><cr>
	nmap <c-\>e :cs find e <c-R>=expand("<cword>")<cr><cr>
	nmap <c-\>f :cs find f <c-R>=expand("<cfile>")<cr><cr>
	nmap <c-\>i :cs find i ^<c-R>=expand("<cfile>")<cr>$<cr>
	nmap <c-\>d :cs find d <c-R>=expand("<cword>")<cr><cr>


	" Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
	" makes the vim window split horizontally, with search result displayed in
	" the new window.
	"
	" (Note: earlier versions of vim may not have the :scs command, but it
	" can be simulated roughly via:
	"    nmap <c-@>s <c-W><c-S> :cs find s <c-R>=expand("<cword>")<cr><cr>

	nmap <c-@>s :scs find s <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@>g :scs find g <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@>c :scs find c <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@>t :scs find t <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@>e :scs find e <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@>f :scs find f <c-R>=expand("<cfile>")<cr><cr>
	nmap <c-@>i :scs find i ^<c-R>=expand("<cfile>")<cr>$<cr>
	nmap <c-@>d :scs find d <c-R>=expand("<cword>")<cr><cr>


	" Hitting CTRL-space *twice* before the search type does a vertical
	" split instead of a horizontal one (vim 6 and up only)
	"
	" (Note: you may wish to put a 'set splitright' in your .vimrc
	" if you prefer the new window on the right instead of the left

	nmap <c-@><c-@>s :vert scs find s <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@><c-@>g :vert scs find g <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@><c-@>c :vert scs find c <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@><c-@>t :vert scs find t <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@><c-@>e :vert scs find e <c-R>=expand("<cword>")<cr><cr>
	nmap <c-@><c-@>f :vert scs find f <c-R>=expand("<cfile>")<cr><cr>
	nmap <c-@><c-@>i :vert scs find i ^<c-R>=expand("<cfile>")<cr>$<cr>
	nmap <c-@><c-@>d :vert scs find d <c-R>=expand("<cword>")<cr><cr>


	""""""""""""" key map timeouts
	"
	" By default Vim will only wait 1 second for each keystroke in a mapping.
	" You may find that too short with the above typemaps.  If so, you should
	" either turn off mapping timeouts via 'notimeout'.
	"
	"set notimeout
	"
	" Or, you can keep timeouts, by uncommenting the timeoutlen line below,
	" with your own personal favorite value (in milliseconds):
	"
	"set timeoutlen=4000
	"
	" Either way, since mapping timeout settings by default also set the
	" timeouts for multicharacter 'keys codes' (like <f1>), you should also
	" set ttimeout and ttimeoutlen: otherwise, you will experience strange
	" delays as vim waits for a keystroke after you hit ESC (it will be
	" waiting to see if the ESC is actually part of a key code like <f1>).
	"
	"set ttimeout
	"
	" personally, I find a tenth of a second to work well for key code
	" timeouts. If you experience problems and have a slow terminal or network
	" connection, set it higher.  If you don't set ttimeoutlen, the value for
	" timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
	"
	"set ttimeoutlen=100

endif
"}}}

" Load ctag and cscope database {{{
function! LoadCtags()
	let currentdir = getcwd()
	try
		execute "cd %:p:h"
	catch
	endtry
	let db = findfile("tags", ".;")

	if (!empty(db))
		let db = fnamemodify(db, ':p')
		let path = strpart(db, 0, match(db, "/tags$"))
		let path = fnamemodify(path, ':p')
		let &l:tags = escape(db, ' ,')
		let b:ctags_db_path = path
	else
		let b:ctags_db_path = getcwd()
		if exists(':ProjectRootCD') == 2
			let b:ctags_db_path = projectroot#guess()
		endif
	endif
	execute "cd " . fnameescape(currentdir)
endfunction

function! LoadCscope()
	let currentdir = getcwd()
	try
		execute "cd %:p:h"
	catch
	endtry
	let db = findfile("cscope.out", ".;")

	if (!empty(db))
		let db = fnamemodify(db, ':p')
		let path = strpart(db, 0, match(db, "/cscope.out$"))
		let path = fnamemodify(path, ':p')
		set nocsverb " suppress 'duplicate connection' error
		execute "cscope add " . db . " " . path
		let b:cscope_db_path = path
		set csverb   " switch back to verbose mode
	else
		let b:cscope_db_path = getcwd()
		if exists(':ProjectRootCD') == 2
			let b:cscope_db_path = projectroot#guess()
		endif
	endif
	execute "cd " . fnameescape(currentdir)
endfunction

augroup MyAutoCmd
	autocmd Filetype c,cpp
				\   execute "call LoadCtags()"  |
				\   if has("cscope") | call LoadCscope() | endif
augroup END
"}}}
" Function: Generating tags. {{{
function! MakeTagsAndCscope()
	if g:dotvim_platform.cygwin || g:dotvim_platform.macos || g:dotvim_platform.linux64 || g:dotvim_platform.linux32 || g:dotvim_platform.unix
		let more_save = &more
		set nomore
		let currentdir = getcwd()
		if (!exists('b:ctags_db_path'))
			let b:ctags_db_path = getcwd()
		if exists(':ProjectRootCD') == 2
			let b:ctags_db_path = projectroot#guess()
		endif
		elseif (empty(b:ctags_db_path))
			let b:ctags_db_path = getcwd()
		if exists(':ProjectRootCD') == 2
			let b:ctags_db_path = projectroot#guess()
		endif
		endif
		silent execute "cd " . b:ctags_db_path
		call system("make --silent --dry-run tags")
		if v:shell_error == 0
			silent execute "!make tags"
		else
			silent execute "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q --verbose=yes"
		endif
		silent execute "set tags=" . b:ctags_db_path
		silent execute "cd " . fnameescape(currentdir)

		let currentdir = getcwd()
		if (!exists('b:cscope_db_path'))
			let b:cscope_db_path = getcwd()
		if exists(':ProjectRootCD') == 2
			let b:cscope_db_path = projectroot#guess()
		endif
		elseif (empty(b:cscope_db_path))
			let b:cscope_db_path = getcwd()
		if exists(':ProjectRootCD') == 2
			let b:cscope_db_path = projectroot#guess()
		endif
		endif
		silent execute "cd " . b:cscope_db_path
		call system("make --silent --dry-run cscope")
		if v:shell_error == 0
			silent execute "!make cscope"
		else
			silent execute "!rm -fv cscope.files"
			silent execute "!find . \\( -name '*.c' -o -name '*.cpp' -o -name '*.cc' -o -name '*.h' -o -name '*.s' -o -name '*.S' \\) -print > cscope.files"
			silent execute "!cscope -v -q -b -i cscope.files $*"
		endif
		set nocsverb " suppress 'duplicate connection' error
		silent execute "cscope add " . b:cscope_db_path . "/cscope.out " . b:cscope_db_path
		silent execute "cscope reset"
		set csverb   " switch back to verbose mode
		execute "cd " . fnameescape(currentdir)
		let &more = more_save
		redraw!
	elseif g:dotvim_platform.win32 || g:dotvim_platform.win64
		" TODO: add routine for generating ctags and cscope for windows.
	endif
endfunction
"}}}

" Function: Cleaning tags. {{{
function! CleaningTagsAndCscope()
	if g:dotvim_platform.cygwin || g:dotvim_platform.macos || g:dotvim_platform.linux64 || g:dotvim_platform.linux32 || g:dotvim_platform.unix
		let more_save = &more
		set nomore
		let currentdir = getcwd()

		if (exists('b:ctags_db_path'))
			if (!empty(b:ctags_db_path))
				silent execute "cd " . b:ctags_db_path
			endif
		endif
		silent execute "!rm -fv tags TAGS"

		if (exists('b:cscope_db_path'))
			if (!empty(b:cscope_db_path))
				silent execute "cd " . b:cscope_db_path
			endif
		endif
		silent execute "!rm -fv cscope.out cscope.in.out cscope.po.out cscope.out.in cscope.out.po cscope.files"

		execute "cd " . fnameescape(currentdir)
		let &more = more_save
		redraw!
	elseif g:dotvim_platform.win32 || g:dotvim_platform.win64
		" TODO: add routine for cleaning ctags and cscope for windows.
	endif
endfunction
"}}}

" <leader>tg <leader>te : generating/cleaning ctags and cscope
nmap <leader>tg :call MakeTagsAndCscope()<cr>
nmap <leader>te :call CleaningTagsAndCscope()<cr>
