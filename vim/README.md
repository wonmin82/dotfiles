# Vim completion migration

The configuration uses coc.nvim's `release` branch and coc-clangd instead of
YouCompleteMe. Vim 9.0.0438+ and Node.js 22.15+ on PATH are required. Older
environments skip Coc; they do not regain YCM or Syntastic automatically.

## Installation

Run `bash install-vim-config.sh` from this checkout. It copies the vimrc,
local vimrc template, `coc.vim`, and `coc-settings.json` to your home directory;
existing copies are overwritten. Restart Vim after dein installs the plugins.
Coc installs `coc-clangd` and `coc-json` on startup. Use `:CocInfo` and
`:CocList extensions` to check installation. If clangd is missing, run
`:CocCommand clangd.install`. The old installed `.ycm_extra_conf.py` is no
longer read; it is not deleted automatically.

Coc settings live in `~/.vim/coc-settings.json`; extensions and state live in
`~/.vim_data/coc` via `g:coc_data_home`. To migrate existing data, quit all Vim
instances and move `~/.config/coc` to `~/.vim_data/coc` if the destination does
not already exist. Restart Vim after changing the path.

Optional servers are registered when their executables are on PATH:
`gopls`, `rust-analyzer`, `pylsp`, and `typescript-language-server`. Install
the servers needed for your projects, then restart Vim. Do not also install a
Coc extension that launches the same server. Other languages need a server
or extension configured separately; syntax plugins still work without one.

## Project configuration

Generate `compile_commands.json` from the real build (for example with
`cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`, or Bear for Make).
Coc also checks the `build` directory. Use `:CocLocalConfig` to specify
`clangd.compilationDatabasePath` for other build directories.

The old Python configuration and `.clang_complete` files are not consumed by
clangd. Move project-specific flags to the compilation database or a project
`.clangd` file. For example, a project without a compilation database can use:

```yaml
CompileFlags:
  Add: [-Iinclude]
---
If:
  PathMatch: .*\.c
CompileFlags:
  Add: [-std=c11]
---
If:
  PathMatch: .*\.(cpp|cc|cxx)
CompileFlags:
  Add: [-std=c++17]
```

Choose the standards used by that project. No global language standard or
recursive include-directory scan is imposed. Cross-compiled projects also
need their target/toolchain options in the compilation database.

## Keys

| Key | Action |
| --- | --- |
| Ctrl-Q | Trigger completion |
| Ctrl-N / Ctrl-P | Next / previous completion |
| Ctrl-Y / Ctrl-E | Confirm / cancel completion |
| Ctrl-Z, Ctrl-J / Ctrl-K | Existing UltiSnips expansion and jumps |
| gd / gr / gi / gy | Definition / references / implementation / type |
| K | Hover, with Python pydoc or Vim keyword lookup as fallback |
| F4 or Space-o | Toggle Coc outline, falling back to Tagbar |
| F11 | Definition hover preview |
| F12 or Leader-sc | Diagnostics list |
| [g / ]g | Previous / next diagnostic |
| Leader-ms / Leader-sr | Toggle diagnostic display / refresh display |
| Leader-rn / Leader-ca | Rename / code action |

Completion confirmation uses Ctrl-Y; Enter keeps its normal newline behavior.
Diagnostic refresh is a UI refresh, not a replacement for a full compiler run.

## Removed and retained functionality

Removed bundles: YouCompleteMe, YCM-Generator, color_coded, Syntastic, SrcExpl.
Coc owns completion, LSP diagnostics, semantic highlighting, and definition
preview. Old YCM/Syntastic settings and Syntastic session callbacks are removed.

clangd runs supported clang-tidy checks. It does not reproduce all previous
GCC, cppcheck, Go linter, or Cargo checks. Run actual build/test checks through
`:make` or the retained dispatch/quickrun tools. `:Cppcheck` fills quickfix
from the current directory's `compile_commands.json`, or checks the saved
current file when none exists. Run it from the project root; cppcheck must be
installed separately. For Go, use `go vet ./...`; for Rust, `cargo check`.
Existing external `golint`/`errcheck` workflows must be run separately too.

Tagbar, unite-outline, unite-tag, and ctags/cscope remain as fallbacks for
files without language servers (including BitBake/QML). Unite's other file,
grep, history, session, and quickfix sources remain. Go's competing completion,
definition mapping, and automatic type info are disabled when Coc and gopls are available.
Its build/test commands and syntax highlighting remain.

The existing vim-clang-format styles and its operator dependency remain because
their output has not been verified against clangd formatting. Black,
JSBeautify, shfmt, RustFmt, and GoFmt also retain Leader-cf. Format on save is
disabled in Coc. Do not remove these formatters until equivalent server-side
formatting has been configured and compared on representative files.

Obsolete installed plugin directories are not deleted automatically. After
validating the new setup, review `dein#check_clean()` before manually removing
only the five removed bundles. Keep the checkout changes together for rollback.
