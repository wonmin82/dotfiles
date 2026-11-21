# macOS Zsh installation

The macOS installer keeps differing Zsh files by default. Review the file-level
output when upgrading. The `--force` option backs up differing regular files
before replacing them.

Interactive login and non-login shells initialize Homebrew for their running
architecture. The standard prefix for that architecture takes priority, followed
by the other prefix if its executable can provide the shell environment. The
initializer runs once per shell. Non-interactive startup keeps the inherited
Homebrew environment. The Linux and Synology install modes keep their existing
keymap files and aliases.

macOS Zsh first looks for the user's existing map in `.zkbd`, then uses the
current `$TERM`'s terminfo when there is no matching map. If a terminal profile
uses custom escape sequences, run `zkbd` in that terminal and keep its generated
map. Check the actual bindings with `bindkey` in each terminal profile and in
tmux. A keymap test for a `TERM` value exercises its terminfo capabilities.

## Startup directory check

On macOS the installer uses a time-limited, read-only Zsh startup probe when
the host sandbox supports it. The probe uses Zsh from `PATH`, falling back to
`/bin/zsh`, and evaluates early startup with system profile and interactive
files omitted. `--dry-run` reports the current result and the expected result
after installation. The prediction uses the managed `.zshenv` default if that
file will be installed, or the current startup result if it will be preserved.
User hooks and full login or interactive startup can affect the final result.

A different startup directory, disabled startup files, or an unavailable probe
leaves the installed files in `~/.zsh` and reports how to check the affected
shell. Run `print -r -- "${ZDOTDIR-$HOME}"` there and reconcile its startup
files with the installed paths. A symlinked `~/.zshenv` is preserved in the
macOS skip-existing mode. Incompatible destination types, missing sources,
lock failures and file I/O errors stop the installation with an error.

On Apple Silicon, check the native and Rosetta shells separately when both
are in use. In each interactive shell, run `/usr/bin/uname -m`,
`print -r -- "$HOMEBREW_PREFIX"`, and `command -v brew`.

Run `python3 -B tests/verify_installers.py` from the checkout for the isolated
installer tests. Set `DOTFILES_TEST_HOMEBREW_ZSH` to test a specific Homebrew
Zsh executable. `DOTFILES_REQUIRE_PROBE=1` and `DOTFILES_REQUIRE_TMUX=1` make
the corresponding tests fail when the local sandbox blocks them.
