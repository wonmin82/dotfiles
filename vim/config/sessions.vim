" Plugin: vim-session {{{
let g:session_default_overwrite = 1
let g:session_autosave = 'yes'
let g:session_autoload = 'no'
let g:session_persist_colors = 0
let g:session_menu = 0
let g:session_verbose_messages = 0

" Pop up session selection if no file is specified
autocmd MyAutoCmd VimEnter * call s:unite_session_on_enter()
function! s:unite_session_on_enter()
	if exists(':Unite') == 2 && exists(':OpenSession') == 2 && !argc() && !exists("g:start_session_from_cmdline") &&
				\   !(&ft == 'man' ||
				\   (exists("b:current_syntax") && b:current_syntax == "man"))
		Unite -buffer-name=sessions session
	endif
endfunction
"}}}

" Unite source for Xolox's vim-session {{{
" it's from https://github.com/rafi/vim-config/blob/master/autoload/unite/sources/session.vim
" it's modified by wonmin82, it can be in .vimrc now
" unite/sources/session - Xolox's vim-session
" Maintainer: Rafael Bodill <justrafi at gmail dot com>
" Author: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Jason Housley <HousleyJK@gmail.com>
" Last Modified: 01 Oct 2014
" License: MIT license
"-------------------------------------------------
" Variables
if empty(globpath(&runtimepath, 'autoload/unite.vim'))
    finish
endif

call unite#util#set_default('g:unite_source_session_allow_rename_locked', 0)

function! s:unite_sources_session_save(filename, ...)
	if unite#util#is_cmdwin()
		return
	endif
	let filename = s:get_session_path(a:filename)
	silent execute 'SaveSession!' filename
endfunction

function! s:unite_sources_session_load(filename)
	if unite#util#is_cmdwin()
		return
	endif
	let filename = s:get_session_path(a:filename)
	silent execute 'OpenSession' filename
endfunction

function! s:unite_sources_session_complete(arglead, cmdline, cursorpos)
	let directory = xolox#misc#path#absolute(g:session_directory)
	let sessions = split(glob(directory.'/*'.g:session_extension), '\n')
	" let sessions = xolox#session#complete_names_with_suggestions('', 0, 0)
	return filter(sessions, 'stridx(v:val, a:arglead) == 0')
endfunction

let s:unite_source_session = {
			\   'name': 'session',
			\   'description': 'candidates from session list',
			\   'default_action': 'load',
			\   'alias_table': { 'edit' : 'open' },
			\   'action_table': {}
			\}

function! s:unite_source_session.gather_candidates(args, context)
	let directory = xolox#misc#path#absolute(g:session_directory)
	let sessions = split(glob(directory.'/*'.g:session_extension), '\n')
	let candidates = map(copy(sessions), "{
				\   'word': xolox#session#path_to_name(v:val),
				\   'kind': 'file',
				\   'action__path': v:val,
				\   'action__directory': unite#util#path2directory(v:val)
				\}")
	return candidates
endfunction

" New session only source
let s:unite_source_session_new = {
			\   'name': 'session/new',
			\   'description': 'session candidates from input',
			\   'default_action': 'save',
			\   'action_table': {}
			\}

function! s:unite_source_session_new.change_candidates(args, context)
	let input = substitute(
				\   substitute(a:context.input, '\\ ', ' ', 'g'),
				\   '^\a\+:\zs\*/', '/', ''
				\)
	if input == ''
		return []
	endif
	" Return new session candidate
	return [{'word': input, 'abbr': '[new session] ' . input,
				\   'action__path': input }] +
				\   s:unite_source_session.gather_candidates(a:args, a:context)
endfunction

" Actions
let s:unite_source_session.action_table.load = {
			\   'description': 'load this session',
			\}

function! s:unite_source_session.action_table.load.func(candidate)
	call s:unite_sources_session_load(a:candidate.word)
endfunction

let s:unite_source_session.action_table.delete = {
			\   'description': 'delete from session list',
			\   'is_invalidate_cache': 1,
			\   'is_quit': 0,
			\   'is_selectable': 1
			\}

function! s:unite_source_session.action_table.delete.func(candidates)
	for candidate in a:candidates
		if input('Really delete session file: '
					\   . candidate.action__path . '? ') =~? 'y\%[es]'
			execute 'DeleteSession' candidate.word
		endif
	endfor
endfunction

let s:unite_source_session.action_table.rename = {
			\   'description': 'rename session name',
			\   'is_invalidate_cache': 1,
			\   'is_quit': 0,
			\   'is_selectable': 1
			\}

function! s:unite_source_session.action_table.rename.func(candidates)
	let current_session = xolox#session#find_current_session()
	let rename_locked = g:unite_source_session_allow_rename_locked
	for candidate in a:candidates
		if rename_locked || current_session != candidate.word
			let session_name = input(printf(
						\   'New session name: %s -> ', candidate.word),
						\   candidate.word)
			if session_name != '' && session_name !=# candidate.word
				let new_name = g:session_directory.'/'.session_name.g:session_extension
				let from_path = expand(candidate.action__path)
				let to_path = expand(new_name)
				call rename(from_path, to_path)
				" Rename also lock file
				if filereadable(from_path.'.lock')
					" TODO: Change vim-session current session
					call rename(from_path.'.lock', to_path.'.lock')
				endif
			endif
		else
			call unite#print_source_error(
						\   [ 'The session "'.candidate.word.'" is locked.' ],
						\   'session')
		endif
	endfor
endfunction

let s:unite_source_session.action_table.save = {
			\   'description': 'save current session as candidate',
			\   'is_invalidate_cache': 1,
			\   'is_selectable': 1
			\}

function! s:unite_source_session.action_table.save.func(candidates)
	for candidate in a:candidates
		if input('Really save the current session as: '
					\   . candidate.word . '? ') =~? 'y\%[es]'
			call s:unite_sources_session_save(candidate.word)
		endif
	endfor
endfunction

let s:unite_source_session_new.action_table.save = s:unite_source_session.action_table.save

function! s:unite_source_session_new.action_table.save.func(candidates)
	let current_tab = tabpagenr()
	tabdo windo if &ft == 'vimfiler' | bd | endif
	execute 'tabnext '.current_tab
	for candidate in a:candidates
		" Second argument means check if exists
		call s:unite_sources_session_save(candidate.word, 1)
	endfor
endfunction

function! s:get_session_path(filename)
	let filename = a:filename
	if filename == ''
		let filename = g:session_default_name
	endif
	if filename == ''
		let filename = v:this_session
	endif
	return filename
endfunction

call unite#define_source(s:unite_source_session)
call unite#define_source(s:unite_source_session_new)
"}}}
