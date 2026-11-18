# Vim configuration

`.vimrc` loads the platform and data paths first, then dein and the modules in
`config/`. General options, appearance, filetypes, mappings, search, sessions,
Git, completion and formatting have separate files. `autoload/dotvim/format.vim`
implements the clang-format commands. Vim data stays in `~/.vim_data`, including
the existing session, Unite, NeoMRU, swap, undo, snippet and Coc directories.

## Installation and recovery

Run `bash install-vim-config.sh` from this checkout. It deploys `~/.vimrc` and
the managed files under `~/.vim/dotvim`. Identical files are safe to reinstall.
If a managed file differs, review the paths printed by the script and rerun
with `--backup` to save those files under a new `~/.dotvim-backup.*` directory
before replacement. The installer keeps existing `~/.vimrc.local`,
`~/.vim/coc-settings.json`, `~/.vim/coc.vim`, and all Vim data. A customized
`~/.vim/coc.vim` takes precedence over the shipped Coc mapping file.

To recover, quit Vim and copy the backed-up files to their original paths,
including `.vimrc`. A restored legacy vimrc uses its original plugin cache.
For a fresh install, remove or move the installed `.vimrc` and the
`~/.vim/dotvim` directory to disable the configuration.

On startup Vim shows Git's progress when installing dein into `~/.vim_data/bundle/dein.vim`,
then shows dein's progress while installing missing bundles. Vim exits when
the bundles are ready. Restart it to load them. Put `let g:dotvim_auto_install_plugins = 0` in
`~/.vimrc.local` for offline startup. With dein present, `:DotVimInstall`
installs missing bundles on demand. Use `:call DeinUpdate()` to update
existing bundles explicitly. Dein's runtime cache is
`~/.vim_data/cache/dein-dotvim`. Existing installed bundles are reused in place.
Paths for NERDTree, Tagbar, NERDCommenter and EasyMotion use their current
repository names and fall back to the old checkout directories.

### Personal and project settings

The main vimrc sources your personal `~/.vimrc.local` once before loading the
plugins. Project files named `.vimrc.local` are handled by vim-localvimrc. It
prompts before sourcing each project file and uses Vim's sandbox by default.
Review the file before answering `y`. Use uppercase `Y` to remember an explicit
approval. The persistence file is in `~/.vim_data/cache`. For settings that
need commands restricted by the sandbox, move the settings into your personal
vimrc, or review the project file before opting out of the sandbox in your
personal vimrc with `let g:localvimrc_sandbox = 0`. Project files still require
confirmation.

## Search, navigation and sessions

Install fzf and ripgrep separately to enable the modern search paths. With
fzf.vim and an existing fzf executable, Space-f and Ctrl-E open `:Files`, and
F3 opens `:Buffers`. Otherwise they use Unite and BufExplorer respectively.
`:Rg` is available through fzf.vim and ripgrep. Existing grep mappings keep the
Unite results window and resume behavior and use ripgrep when on PATH. Ack
and the built-in Unite grep configuration remain fallbacks.

| Key | Action |
| --- | --- |
| Space-f / Ctrl-E | File search |
| Space-F | Legacy file search and new-file action |
| Space-Space / Ctrl-Space | Combined Unite pickers |
| Ctrl-P / Space-u / Space-m | Buffers and recent files / recent files |
| Space-g / Ctrl-S Ctrl-S / Ctrl-S Ctrl-D | Search project contents |
| Ctrl-S Ctrl-A / Ctrl-R | Resume grep / last Unite picker |
| Space-/ / Ctrl-S Ctrl-F / Ctrl-/ | Search current buffer |
| Space-t / F1 or Space-h | Tags / help |
| Space-; / Space-c | Command history and commands |
| Space-r / Ctrl-Y or Space-y | Registers / yank history |
| Space-p / Space-q / Space-l | Sessions / quickfix / location list |
| Space-b / Space-d or Ctrl-C / Space-s | Bookmarks / directories / snippets |
| F2 / Leader-vf | NERDTree toggle / toggle rooted at current buffer's directory |
| F3 / F4 / F5 | Buffers / Coc outline or Tagbar / Fugitive status |

Unite also retains its source and mapping lists, search history source and
buffer-local actions. Use `:Unite history/search` for search history. Vimfiler
remains available via `:VimFiler` for its file operations and existing session
data. Vim's bundled netrw is available where it ships. `:DotVimTerminal` uses
Vim's terminal when available, with VimShell as the fallback. The Airline
tabline shows buffer names and numbers. The old bufferline plugin is removed.

`:SaveSession`, `:OpenSession` and Space-p use the existing vim-session store
and preserve the existing startup picker and autosave. Unite keeps its session
save, rename and delete actions. When `:mksession` emits Vim9 code, the
compatibility adapter marks the boundary before vim-session appends special
window commands. It validates the generated script before vim-session writes
the session file. Legacy sessions use the original script format and can
still be opened. Sessions saved with Vim9-generated state require Vim9 to
restore. When BufExplorer shares a tab with other splits, vim-session can
restore the tab with a different focused buffer.

### Plugin inventory

| Area | Bundles and integrations |
| --- | --- |
| Search | fzf and fzf.vim for files and buffers, Unite and unite-help for pickers, neomru.vim for file/directory history, unite-outline and unite-tag for symbols, unite-quickfix for quickfix/location lists, vim-unite-history for Ex/search history, ack.vim for the explicit `:Ack` workflow |
| Navigation and state | NERDTree, Vimfiler, BufExplorer, vim-projectroot, EasyMotion, Tagbar, vim-session and vim-misc |
| Shell and Git | vimproc.vim for legacy async sources, VimShell, vim-quickrun, vim-dispatch and vim-fugitive |
| Editing | NERDCommenter, Tabular, vim-localvimrc, IndentTab and ingo-library, IndentConsistencyCop and its autocmds, vim-better-whitespace, FastFold |
| Language support | coc.nvim, rust.vim, vim-go, vim-toml, vim-bitbake, vim-qml, ultisnips and vim-snippets |
| Formatting | Black, vim-jsbeautify, vim-shfmt, vim-linux-coding-style and the built-in configuration's clang-format commands |
| Appearance | Vim Airline and Airline themes, Molokai, Solarized, Jellybeans and Noctu |

IndentTab is retained for tabs in indentation, comment prefixes and strings,
and spaces for alignment. The retained JavaScript, JSON, JSX, CSS and HTML
formatter uses JSBeautify's tab settings. The corresponding Black, GoFmt,
RustFmt and shfmt commands remain on Leader-cf. These workflows require their
formatters and any existing plugin-specific runtime dependencies. Black formats
the whole Python buffer from either Normal or Visual mode. Black prefers
Homebrew's existing virtualenv under `$HOMEBREW_PREFIX/opt/black/libexec`.
On macOS it also checks `/opt/homebrew` and `/usr/local`, so this works
when Vim starts without Homebrew on `PATH`. If Homebrew Black is absent,
the plugin checks `~/.vim_data/black` and Vim's Python environment.
An explicit `g:black_virtualenv` or `g:black_use_virtualenv` setting takes
precedence. Use Homebrew to manage the formula's virtualenv. Black's Python
environment must be compatible with the Python linked into Vim.
Tag navigation uses ctags, with gotags for the configured Go outline.
Legacy Unite asynchronous sources still require a working vimproc build.
Use the installed Go/Rust and shell tooling for builds and format commands.

## Coc and project language servers

The Coc release branch requires Vim 9.0.0438+ with jobs and channels and
Node.js 22.15+. Coc uses `~/.vim/coc-settings.json` and stores extensions and
state in `~/.vim_data/coc`. Coc reuses installed extensions and installs
`coc-clangd` and `coc-json` on startup when automatic installation is enabled.
Vim shows the progress in its message area when the original editor is empty,
or in Coc's progress split while a file is open. The split closes after a
successful install. Failed installs leave diagnostics available.
With it disabled, use `:CocInstall coc-clangd coc-json` when needed.
Use `:CocInfo` or `:CocList extensions` to inspect the result.
`gopls`, `rust-analyzer`, `pylsp` and `typescript-language-server` are
registered when present on PATH. Coc owns completion/definition for Go when
gopls is available. Vim and Coc diagnostics do not substitute for project builds.

Generate a `compile_commands.json` from the real C/C++ build. The provided
settings also check the `build` directory. Use `.clangd` or `:CocLocalConfig`
for project-specific compilation flags and database paths. Install a separate
clangd if needed. `:Cppcheck` can populate quickfix from the compilation
database or the current saved file.

| Key | Action |
| --- | --- |
| Ctrl-Q | Trigger completion |
| Ctrl-N / Ctrl-P | Next / previous completion |
| Ctrl-Y / Ctrl-E | Confirm / cancel completion |
| Ctrl-Z / Ctrl-J / Ctrl-K | UltiSnips expansion / forward / backward |
| gd / gr / gi / gy | Definition / references / implementation / type |
| K / F11 | Hover documentation / definition hover |
| F12 or Leader-sc / [g / ]g | Diagnostics list / previous / next |
| Leader-ms / Leader-sr | Toggle diagnostics / refresh display |
| Leader-rn / Leader-ca | Rename / code action |

## clang-format 3.4 through 23

Set `g:clang_format#command` in your personal vimrc to select an explicit
executable, including a path with spaces. Otherwise Vim checks `clang-format`
on PATH first, then version-suffixed commands. It reads the executable's actual
version and selects the matching profile. An unsupported version or invalid
style produces an error without replacing buffer text. The formatter uses
the nearest applicable `.clang-format` or `_clang-format` through clang-format's
project lookup.

Leader-cf formats a buffer or the Visual selection in C, C++, Objective-C,
Java, Protocol Buffers and TypeScript. Leader-x takes a motion such as
Leader-x followed by `ip`, or formats the Visual selection. Leader-C toggles
clang-format on save for its configured filetypes. The shipped Coc settings
leave LSP format-on-save disabled. JavaScript retains JSBeautify for the
explicit mapping.

The original dictionaries for 3.4–13 are in `config/clang-format/legacy.vim`.
They retain their option values and use their configured preset or the plugin's
original Google default. The full 14–23 profiles come from each version's
`--dump-config` after applying the v13 settings to the Google preset. The JSON
flow mapping passed to clang-format preserves nested maps and lists, which
includes the include categories and raw string formats. The old Vim formatter
and operator plugin are replaced by the repository's commands.

Update the applicable `vNN.vim` file (or the legacy dictionary) to change the
shipped profile. For personal overrides, use `g:clang_format#style_options` or
`g:clang_format#filetype_style_options` with keys supported by the selected
binary. A project style file takes precedence. The full profiles already
include their base values, so `g:clang_format#code_style` applies to legacy
profiles only.

### Style migrations

- The same four-column tabs, 80-column limit, Allman braces, right-aligned
  pointer symbols, nested namespace indentation and legacy include ordering
  are carried forward. The include and attribute macro lists use the explicit
  v13 entries. This avoids extra entries retained by newer preset list parsing.
- LLVM's compatibility parser was used to move constructor packing to
  `PackConstructorInitializers: NextLine`, requires indentation to
  `IndentRequiresClause`, and line endings to `LineEnding: DeriveLF`.
- Consecutive alignment, trailing comments, parentheses, blank lines, include
  sorting, bracket alignment, and argument/parameter packing use each version's
  canonical map, Boolean or enum form. v23 uses the `PackArguments` and
  `PackParameters` maps with bin packing enabled, and its corresponding return
  type and binary operation options.
- New style controls take the version's Google values where those preserve
  the earlier intent. The profiles retain full comment and macro settings,
  leave source-changing options such as brace insertion and semicolon removal
  off, disable the long-braced-list packing override in 21+, and use
  `Cpp11BracedListStyle: FunctionCall` in 22+ to retain continuation indentation
  around braced-list comments.
- The checked C++ fixture produced identical output in 14–23. Other inputs
  can reflect formatter engine changes. A direct comparison against v13 or
  earlier requires those binaries.

## Verification

```sh
bash -n install-vim-config.sh
python3 -B vim/tests/verify.py ~/work/clang-format
```

The formatter test expects `<root>/<major>/bin/clang-format` for majors 14
through 23 and Vim on PATH. It uses an isolated home and temp paths in the
checkout, without loading plugins. It checks the version, full dump schema,
strict parsing, formatting and idempotence, C++ style invariants, version
comparisons, key mappings, range/operator formatting, project styles, and
save formatting. Missing binaries are reported as `BLOCKED`.
The test also loads a copy of the installed layout in a home path with spaces
and checks the startup installation paths with stub Git and dein commands.
Use `--installed-bundles ~/.vim_data/bundle/repos/github.com` to exercise
existing bundles for Unite quickfix and MRU, BufExplorer, NERDTree, Fugitive
and vim-session with disposable test data.

Verified with Vim 9.2 on Apple Silicon macOS and clang-format 14.0.6,
15.0.7, 16.0.6, 17.0.6, 18.1.8, 19.1.7, 20.1.8, 21.1.8, 22.1.8 and 23.1.5.
Runtime verification for clang-format 3.4–13, an installer run, Windows,
Linux and Synology is **NOT RUN**. The older platform branches are preserved.
Coc's interactive language servers, fzf's UI and external language formatters
also require their dependencies for runtime verification.
