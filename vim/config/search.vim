" <f1>: Help
nmap <f1> [unite]h<cr>

" Ctrl-e: Find (e)verything
nmap <c-e> [unite]f

" Ctrl-r: Command history using Unite

"nmap <c-r> [unite];

" Ctrl-r: Reopen last unite window
nnoremap <c-r> :UniteResume<cr>

" Ctrl-y: Yanks
nmap <c-y> [unite]y

" Ctrl-p: Find MRU and buffers
nmap <c-p> [unite]u

" Ctrl-\: Quick outline
nmap <silent> <c-\> [unite]o

" Ctrl-sa: Reopen last grep window
nnoremap <c-s><c-a> :UniteResume -buffer-name=grep<cr>
" Ctrl-ss: (S)earch word under cur(s)or in current directory
nnoremap <c-s><c-s> :Unite -buffer-name=grep grep:.::<c-r><c-w><cr>
" Ctrl-sd: (S)earch word in current (d)irectory (prompt for word)
nnoremap <c-s><c-d> :Unite -buffer-name=grep grep:.<cr>
" Ctrl-sf: Quickly (s)earch in (f)ile
nmap <c-s><c-f> [unite]/
" Ctrl-sr: Easier (s)earch and (r)eplace
nnoremap <c-s><c-r> :%s/<c-r><c-w>//gc<left><left><left>
" Ctrl-sw: Quickly surround word
nmap <c-s><c-w> ysiw
" Ctrl-c: (C)hange (c)urrent directory
nmap <c-c> [unite]d
" Ctrl-/: A more powerful '/'
nmap <c-_> [unite]/
" Plugin: Unite {{{
" Map space to the prefix for Unite
nnoremap [unite] <nop>
nmap <space> [unite]

" General fuzzy search
nnoremap <silent> [unite]<space> :<c-u>Unite
			\ -buffer-name=files buffer file_mru bookmark file_rec/async<cr>

" Quick registers
nnoremap <silent> [unite]r :<c-u>Unite -buffer-name=register register<cr>

" Quick buffer and mru
nnoremap <silent> [unite]u :<c-u>Unite -buffer-name=buffers file_mru buffer<cr>

" Quick yank history
nnoremap <silent> [unite]y :<c-u>Unite -buffer-name=yanks history/yank<cr>

" Quick outline
nnoremap <silent> [unite]o :<c-u>call DotVimOutline()<cr>

" Quick tag
nnoremap <silent> [unite]t :<c-u>Unite -buffer-name=tag tag<cr>

" Quick sessions (projects)
nnoremap <silent> [unite]p :<c-u>Unite -buffer-name=sessions session<cr>

" Quick quickfix
nnoremap <silent> [unite]q :<c-u>Unite -buffer-name=quickfix quickfix<cr>

" Quick location list
nnoremap <silent> [unite]l :<c-u>Unite -buffer-name=location_list location_list<cr>

" Quick sources
nnoremap <silent> [unite]a :<c-u>Unite -buffer-name=sources source<cr>

" Quick snippet
" nnoremap <silent> [unite]s :<c-u>Unite -buffer-name=snippets snippet<cr>
nnoremap <silent> [unite]s :<c-u>Unite -buffer-name=snippets ultisnips<cr>

" Quickly switch lcd
nnoremap <silent> [unite]d
			\ :<c-u>Unite -buffer-name=change-cwd -default-action=cd directory_mru directory_rec/async<cr>

" Quick file search
nnoremap <silent> [unite]f :<c-u>call DotVimFiles()<cr>
nnoremap <silent> [unite]F :<c-u>Unite -buffer-name=files file_rec/async file/new<cr>

function! DotVimFiles() abort
    if exists(':Files') == 2 && executable('fzf')
        Files
    elseif exists(':Unite') == 2
        Unite -buffer-name=files file_rec/async file/new
    else
        echoerr 'File search requires fzf.vim or Unite'
    endif
endfunction

" Quick grep from cwd
nnoremap <silent> [unite]g :<c-u>Unite -buffer-name=grep grep:.<cr>

" Quick help
nnoremap <silent> [unite]h :<c-u>Unite -buffer-name=help help<cr>

" Quick line using the word under cursor
" nnoremap <silent> [unite]l :<c-u>UniteWithCursorWord -buffer-name=search_file line<cr>

" Quick line
nnoremap <silent> [unite]/ :<c-u>Unite -buffer-name=line line<cr>

" Quick MRU search
nnoremap <silent> [unite]m :<c-u>Unite -buffer-name=mru file_mru<cr>

" Quick find
nnoremap <silent> [unite]n :<c-u>Unite -buffer-name=find find:.<cr>

" Quick commands
nnoremap <silent> [unite]c :<c-u>Unite -buffer-name=commands command<cr>

" Quick bookmarks
nnoremap <silent> [unite]b :<c-u>Unite -buffer-name=bookmarks bookmark<cr>

" Fuzzy search from current buffer
" nnoremap <silent> [unite]b :<c-u>UniteWithBufferDir
" \ -buffer-name=files -prompt=%\  buffer file_mru bookmark file<cr>

" Quick commands
nnoremap <silent> [unite]; :<c-u>Unite -buffer-name=history -default-action=edit history/command command<cr>

" Quick mappings
nnoremap <silent> [unite]k :<c-u>Unite -buffer-name=mapping mapping<cr>

" Custom Unite settings
autocmd MyAutoCmd FileType unite call s:unite_settings()
function! s:unite_settings()
	" map <esc> key overriding and some escape sequence handling. {{{
	" NOTE: frankly speaking, I doubt that if I am doing right..
	nmap <buffer> <esc> <plug>(unite_exit)
	imap <buffer> <esc> <plug>(unite_insert_leave)
	imap <buffer> <esc><esc> <plug>(unite_exit)
	nnoremap <buffer> <esc>[ <esc>[
	inoremap <buffer> <esc>[ <esc>[
	nnoremap <buffer> <esc>[O <esc>[O
	inoremap <buffer> <esc>[O <esc>[O
	nnoremap <buffer> <esc>[[ <esc>[[
	inoremap <buffer> <esc>[[ <esc>[[
	inoremap <buffer> <esc><esc>[ <esc><esc>[
	"}}}

	nmap <buffer> <home> <plug>(unite_cursor_top)
	nmap <buffer> <end> <plug>(unite_cursor_bottom)
	" imap <buffer> <c-j> <plug>(unite_select_next_line)
	imap <buffer> <c-j> <plug>(unite_insert_leave)
	nmap <buffer> <c-j> <plug>(unite_loop_cursor_down)
	nmap <buffer> <c-k> <plug>(unite_loop_cursor_up)
	"nmap <buffer> <tab> <plug>(unite_loop_cursor_down)
	"nmap <buffer> <s-tab> <plug>(unite_loop_cursor_up)
	"imap <buffer> <c-a> <plug>(unite_choose_action)
	nmap <buffer> M     <plug>(unite_disable_max_candidates)
	nmap <buffer> <tab> <plug>(unite_choose_action)
	imap <buffer> <tab> <plug>(unite_choose_action)
	" imap <buffer> jj <plug>(unite_insert_leave)
	imap <buffer> <c-w> <plug>(unite_delete_backward_word)
	imap <buffer> <c-u> <plug>(unite_delete_backward_path)
	imap <buffer> '     <plug>(unite_quick_match_default_action)
	nmap <buffer> '     <plug>(unite_quick_match_default_action)
	nmap <buffer> <c-r> <plug>(unite_redraw)
	imap <buffer> <c-r> <plug>(unite_redraw)
	inoremap <silent> <buffer> <expr> <c-s> unite#do_action('split')
	nnoremap <silent> <buffer> <expr> <c-s> unite#do_action('split')
	inoremap <silent> <buffer> <expr> <c-v> unite#do_action('vsplit')
	nnoremap <silent> <buffer> <expr> <c-v> unite#do_action('vsplit')

	let unite = unite#get_current_unite()
	if unite.buffer_name =~# '^search'
		nnoremap <silent> <buffer> <expr> r     unite#do_action('replace')
	else
		nnoremap <silent> <buffer> <expr> r     unite#do_action('rename')
	endif

	nnoremap <silent> <buffer> <expr> cd     unite#do_action('lcd')

	" Using Ctrl-\ to trigger outline, so close it using the same keystroke
	if unite.buffer_name =~# '^outline'
		imap <buffer> <c-\> <plug>(unite_exit)
	endif

	" Using Ctrl-/ to trigger line, close it using same keystroke
	if unite.buffer_name =~# '^line'
		imap <buffer> <c-_> <plug>(unite_exit)
	endif
endfunction

" Use the fuzzy matcher for everything, except grep, line and etc. see the docs.
if empty(globpath(&runtimepath, 'autoload/unite.vim'))
    finish
endif

call unite#filters#matcher_default#use(['matcher_fuzzy'])
" Use the selecta sorter for all source.
if has('ruby')
	call unite#filters#sorter_default#use(['sorter_selecta'])
else
	call unite#filters#sorter_default#use(['sorter_rank'])
endif

" Global default context
call unite#custom#profile('default', 'context', {
			\   'safe': 0,
			\   'auto_expand': 1,
			\   'start_insert': 1,
			\   'max_candidates': 0,
			\   'update_time': 200,
			\   'winheight': 20,
			\   'winwidth': 40,
			\   'direction': 'botright',
			\   'no_auto_resize': 0,
			\   'prompt_direction': 'below',
			\   'cursor_line_highlight': 'PmenuSel',
			\   'cursor_line_time': '0.2',
			\   'candidate_icon': '-',
			\   'marked_icon': '*',
			\   'prompt' : '> '
			\})

call unite#custom#profile('outline', 'context', {
			\   'auto_expand': 0,
			\   'start_insert': 1,
			\   'max_candidates': 0,
			\   'no_auto_resize': 1,
			\   'prompt_direction': 'top',
			\})

" Set up some custom ignores
call unite#custom#source('file_rec,file_rec/async,file_mru,file,buffer,grep',
			\   'ignore_pattern',
			\   join([
			\       '\.git/',
			\       '\.svn/',
			\       '\.hg/',
			\       'git5/.*/review/',
			\       'google/obj/',
			\       'tmp/',
			\       '\.sass-cache',
			\       'node_modules/',
			\       'bower_components/',
			\       'dist/',
			\       '\.git5_specs/',
			\       '\.pyc',
			\       '\.dropbox/',
			\       '\.cache/'
			\   ],
			\   '\|')
			\)

" Enable history yank source
let g:unite_source_history_yank_enable = 1

let g:neomru#file_mru_limit = 1000

let g:neomru#filename_format = ':~:.'
let g:neomru#time_format = ''

" Preserve the Unite grep buffer and its resume and edit actions.
if executable('rg')
    let g:unite_source_grep_command = 'rg'
    let g:unite_source_grep_default_opts = '--line-number --with-filename --no-heading --no-color -w'
    let g:unite_source_grep_recursive_opt = ''
elseif executable('ack-grep')
	let g:unite_source_grep_command = 'ack-grep'
	" Match whole word only. This might/might not be a good idea
	let g:unite_source_grep_default_opts = '--no-heading --no-color -w'
	let g:unite_source_grep_recursive_opt = ''
elseif executable('ack')
	let g:unite_source_grep_command = 'ack'
	let g:unite_source_grep_default_opts = '--no-heading --no-color -w'
	let g:unite_source_grep_recursive_opt = ''
endif

let g:unite_source_rec_max_cache_files = 99999
"}}}
" Plugin: Unite.vim {{{
nnoremap <c-@> :Unite -start-insert -auto-resize buffer file file_rec/async file_mru<cr>
nnoremap <leader><@> :Unite<cr>
"}}}
