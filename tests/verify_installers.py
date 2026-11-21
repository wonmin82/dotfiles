"""Exercise the installers and shell configuration in temporary homes."""

import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
from tempfile import TemporaryDirectory
import unittest


ROOT = Path(__file__).resolve().parents[1]
SYSTEM_PATH = "/usr/bin:/bin:/usr/sbin:/sbin"
MAC = sys.platform == "darwin"


def executable(path, text):
    path.write_text("#!/bin/sh\n" + text)
    path.chmod(0o755)


class Installers(unittest.TestCase):
    def setUp(self):
        temporary = TemporaryDirectory(prefix="dotfiles-test.", dir="/tmp")
        self.addCleanup(temporary.cleanup)
        self.work = Path(temporary.name).resolve()
        self.home = self.work / "home with spaces"
        self.home.mkdir()
        self.bin = self.home / "bin"
        self.bin.mkdir()
        self.env = {"HOME": str(self.home), "PATH": f"{self.bin}:{SYSTEM_PATH}",
                    "TERM": "xterm-256color", "LC_ALL": "en_US.UTF-8"}

    def command(self, *argv, status=0, **env):
        result = subprocess.run(argv, env={**self.env, **env}, cwd=self.work,
                                stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=20)
        if status is not None:
            self.assertEqual(result.returncode, status, result.stdout + result.stderr)
        return result

    def install(self, name, *options, status=0):
        result = self.command("/bin/bash", ROOT / f"install-{name}-config.sh", *options, status=status)
        return result.stdout + result.stderr

    def snapshot(self, include_directories=True):
        return {path: (path.lstat().st_mtime_ns, path.read_bytes() if path.is_file() else None)
                for path in self.home.rglob("*") if include_directories or not path.is_dir()}

    def test_vim_partial_install_and_backup(self):
        vimrc = self.home / ".vimrc"
        local = self.home / ".vimrc.local"
        vimrc.write_text('" Custom loader\n')
        local.write_text('" Personal settings\n')
        before = self.snapshot()
        preview = self.install("vim", "--skip-existing", "--dry-run")
        self.assertIn(f"Skipped {vimrc} (existing file differs)", preview)
        self.assertIn(f"Would install {self.home / '.vim/dotvim/config/options.vim'}", preview)
        self.assertEqual(self.snapshot(), before)
        output = self.install("vim", "--skip-existing")
        self.assertIn("Warning: Preserved Vim files", output)
        self.assertEqual(vimrc.read_text(), '" Custom loader\n')
        self.assertEqual(local.read_text(), '" Personal settings\n')
        options = self.home / ".vim/dotvim/config/options.vim"
        appearance = self.home / ".vim/dotvim/config/appearance.vim"
        self.assertEqual(options.read_bytes(), (ROOT / "vim/config/options.vim").read_bytes())
        options.write_text('" Custom runtime\n')
        appearance.unlink()
        coc = self.home / ".vim/coc-settings.json"
        coc.write_text('{"personal": true}\n')
        output = self.install("vim", "--skip-existing")
        self.assertIn(f"Skipped {options} (existing file differs)", output)
        self.assertIn(f"Installed {appearance}", output)
        self.assertEqual(options.read_text(), '" Custom runtime\n')
        self.assertIn("Existing configuration differs", self.install("vim", status=1))
        output = self.install("vim", "--backup")
        self.assertIn(f"Backed up and installed {vimrc}", output)
        self.assertIn(f"Backed up and installed {options}", output)
        backup, = self.home.glob(".dotvim-backup.*")
        self.assertEqual((backup / ".vimrc").read_text(), '" Custom loader\n')
        self.assertEqual((backup / options.relative_to(self.home)).read_text(), '" Custom runtime\n')
        self.assertEqual(coc.read_text(), '{"personal": true}\n')
        before = self.snapshot(include_directories=False)
        self.assertIn(f"Skipped {vimrc} (already matches)", self.install("vim"))
        self.assertEqual(self.snapshot(include_directories=False), before)

    @unittest.skipUnless(MAC, "requires macOS")
    def test_macos_fresh_install_dry_run_and_force(self):
        before = self.snapshot()
        output = self.install("mac", "--dry-run")
        self.assertIn("ZDOTDIR before installation", output)
        self.assertIn("ZDOTDIR after planned installation", output)
        self.assertEqual(self.snapshot(), before)
        output = self.install("mac")
        for relative in (".vimrc", ".zshenv", ".zsh/.zprofile", ".zsh/homebrew.zsh", ".wgetrc", ".tmux.conf"):
            self.assertIn(f"Installed {self.home / relative}", output)
        self.assertFalse((self.home / ".zsh/.zkbd").exists())
        for name in (".vimrc", ".wgetrc", ".zsh/.zprofile"):
            (self.home / name).write_text("local settings\n")
        before = self.snapshot()
        self.assertEqual(self.install("mac", "--force", "--dry-run").count("Would back up and install"), 3)
        self.assertEqual(self.snapshot(), before)
        self.assertEqual(self.install("mac", "--force").count("Backed up and installed"), 3)
        for pattern, path in ((".dotvim-backup.*", ".vimrc"), (".dotfiles-mac-backup.*", ".wgetrc"),
                              (".dotfiles-zsh-backup.*", ".zsh/.zprofile")):
            backup, = self.home.glob(pattern)
            self.assertEqual((backup / path).read_text(), "local settings\n")

    @unittest.skipUnless(MAC, "requires the macOS read-only startup probe")
    def test_existing_zdotdir_is_evaluated_without_writes(self):
        startup = self.home / "custom zshenv"
        startup.write_text('ZDOTDIR="${HOME}/custom config"\nprint unsafe > "$HOME/canary"\n')
        (self.home / ".zshenv").symlink_to(startup)
        before = self.snapshot()
        preview = self.install("zsh", "--macos", "--skip-existing", "--dry-run")
        self.assertEqual(self.snapshot(), before)
        if "could not be verified" in preview and not os.environ.get("DOTFILES_REQUIRE_PROBE"):
            self.skipTest("read-only sandbox unavailable in this process")
        custom_dir = self.home / "custom config"
        self.assertIn(f"ZDOTDIR before installation {custom_dir}", preview)
        self.assertIn(f"ZDOTDIR after planned installation {custom_dir}", preview)
        self.assertIn(f"but the installer targets {self.home / '.zsh'}", preview)
        output = self.install("zsh", "--macos", "--skip-existing")
        self.assertIn(f"ZDOTDIR after installation {custom_dir}", output)
        self.assertIn(f"Warning: Zsh looks for .zprofile and .zshrc in {custom_dir}", output)
        self.assertTrue((self.home / ".zshenv").is_symlink())
        self.assertFalse((self.home / "canary").exists())
        self.install("zsh", "--macos", "--backup", status=1)
        (self.home / ".zshenv").unlink()
        (self.home / ".zshenv").write_text(startup.read_text())
        before = self.snapshot()
        preview = self.install("zsh", "--macos", "--backup", "--dry-run")
        self.assertIn(f"ZDOTDIR before installation {custom_dir}", preview)
        self.assertIn(f"ZDOTDIR after planned installation {self.home / '.zsh'}", preview)
        self.assertEqual(self.snapshot(), before)

    def prepare_zsh(self):
        self.install("zsh", "--macos", "--skip-existing")
        data = self.home / ".zsh_data"
        (data / "antigen").mkdir(parents=True)
        (data / "antigen/antigen.zsh").write_text("antigen() { return 0; }\ncompdef() { return 0; }\n")
        (data / "LS_COLORS/.git").mkdir(parents=True)
        (data / "LS_COLORS/LS_COLORS").write_text("")
        homebrew_zsh = os.environ.get("DOTFILES_TEST_HOMEBREW_ZSH") or shutil.which("zsh", path="/opt/homebrew/bin:/usr/local/bin")
        if homebrew_zsh and (bottle_root := os.environ.get("DOTFILES_TEST_ZSH_BOTTLE")):
            bottle = shlex.quote(bottle_root)
            (self.home / ".zshenv.path").write_text(
                f'module_path=({bottle}/lib "$module_path[@]")\n'
                f'fpath=({bottle}/share/zsh/functions "$fpath[@]")\n'
            )
        return homebrew_zsh

    def check_zsh_startup_and_keys(self, shell):
        probe = 'print -r -- "RESULT $HOMEBREW_PREFIX $path[1] $ZDOTDIR"'
        machine = self.command("/usr/bin/uname", "-m").stdout.strip()
        prefix = "/opt/homebrew" if machine == "arm64" else "/usr/local"
        if not os.access(prefix + "/bin/brew", os.X_OK):
            self.skipTest(f"native Homebrew unavailable at {prefix}")
        for flag in ("-dilc", "-dic"):
            output = self.command(shell, flag, probe).stdout
            self.assertIn(f"RESULT {prefix} {prefix}/bin {self.home / '.zsh'}", output)
        with_existing_path = f"{prefix}/bin:{prefix}/sbin:{self.env['PATH']}"
        output = self.command(shell, "-dic", probe, PATH=with_existing_path).stdout
        self.assertIn(f"RESULT {prefix} {prefix}/bin {self.home / '.zsh'}", output)
        for flag in ("-dc", "-dlc"):
            self.assertIn("RESULT  ", self.command(shell, flag, probe).stdout)

        bindings = {"khome": "beginning-of-line", "kend": "end-of-line", "kich1": "overwrite-mode",
                    "kdch1": "delete-char", "kcuu1": "up-line-or-history", "kcud1": "down-line-or-history",
                    "kcub1": "backward-char", "kcuf1": "forward-char", "kpp": "beginning-of-buffer-or-history",
                    "knp": "end-of-buffer-or-history"}
        check = "\n".join(f'[[ -n $terminfo[{cap}] && $(bindkey "$terminfo[{cap}]") == *" {widget}" ]] || exit 1'
                          for cap, widget in bindings.items())
        for terminal in ("xterm-256color", "screen-256color", "tmux-256color"):
            with self.subTest(terminal=terminal):
                self.command(shell, "-dic", check, TERM=terminal)

        platform = self.command(shell, "-dfc", 'print -r -- "$VENDOR-$OSTYPE"').stdout.strip()
        custom = self.home / f".zsh/.zkbd/xterm-256color-{platform}"
        custom.parent.mkdir()
        custom.write_text("typeset -A key\nkey[Home]=$'\\e[99~'\n")
        self.install("zsh", "--macos", "--backup")
        binding = self.command(shell, "-dic", 'bindkey "$key[Home]"').stdout
        self.assertIn('"^[[99~" beginning-of-line', binding)

    @unittest.skipUnless(MAC, "requires native macOS Zsh and Homebrew")
    def test_system_zsh_startup_and_keys(self):
        self.prepare_zsh()
        self.check_zsh_startup_and_keys("/bin/zsh")

    @unittest.skipUnless(MAC, "requires a macOS Homebrew Zsh")
    def test_homebrew_zsh_startup_and_keys(self):
        shell = self.prepare_zsh()
        if not shell:
            self.skipTest("Homebrew Zsh unavailable")
        self.check_zsh_startup_and_keys(shell)

    @unittest.skipUnless(MAC, "requires macOS Zsh")
    def test_homebrew_architecture_preference_fixture(self):
        self.prepare_zsh()
        arm = self.work / "arm"
        intel = self.work / "intel"
        calls = self.work / "calls"
        machine = self.bin / "shell-architecture"
        executable(machine, 'printf "%s\\n" "$TEST_MACHINE"\n')
        helper = self.home / ".zsh/homebrew.zsh"
        helper.write_text(helper.read_text().replace("/usr/bin/uname", shlex.quote(str(machine)))
                          .replace("/opt/homebrew", str(arm)).replace("/usr/local", str(intel)))
        for prefix in (arm, intel):
            (prefix / "bin").mkdir(parents=True)
            executable(prefix / "bin/brew", f"printf '%s\\n' {prefix} >> \"$TEST_CALLS\"\n"
                       f"[ \"$TEST_BROKEN\" != {prefix} ] || exit 1\n"
                       f"printf '%s\\n' 'export HOMEBREW_PREFIX={prefix}' 'export PATH={prefix}/bin:$PATH'\n")
        for arch, chosen, broken, expected in (("arm64", arm, "", [arm]), ("x86_64", intel, "", [intel]),
                                              ("x86_64", arm, intel, [intel, arm])):
            for flag in ("-dic", "-dilc"):
                calls.write_text("")
                result = self.command("/bin/zsh", flag, 'print -rl -- "$HOMEBREW_PREFIX" "$PATH"',
                                      TEST_MACHINE=arch, TEST_CALLS=str(calls), TEST_BROKEN=str(broken))
                selected, path = result.stdout.splitlines()[-2:]
                self.assertEqual(selected, str(chosen))
                self.assertEqual(path.split(":")[0], f"{chosen}/bin")
                self.assertTrue(path.endswith(self.env["PATH"]), path)
                self.assertEqual(calls.read_text().splitlines(), [str(prefix) for prefix in expected])

    def test_linux_and_synology_branches_fixture(self):
        source = (ROOT / "install-zsh-config.sh").read_text()
        passwd = self.work / "passwd"
        marker = self.work / "synoinfo"
        executable(self.bin / "uname", "printf 'Linux\\n'\n")
        executable(self.bin / "id", "printf 'tester\\n'\n")
        executable(self.bin / "sudo", "exit 99\n")
        fixture = self.work / "install-zsh-config.sh"
        fixture.write_text(source.replace("/etc/passwd", str(passwd)).replace("/etc/synoinfo.conf", str(marker)))
        (self.work / "zsh").symlink_to(ROOT / "zsh", target_is_directory=True)
        passwd.write_text("tester:x:1000:1000:Tester:/home/tester:/bin/zsh\n")
        self.command("/bin/bash", fixture)
        for term in ("xterm-256color", "screen-256color"):
            alias = self.home / f".zsh/.zkbd/{term}-unknown-linux-gnu"
            self.assertEqual(alias.readlink(), alias.with_name(f"{term}-ubuntu-linux-gnu"))
        self.assertFalse((self.home / ".zsh/homebrew.zsh").exists())
        self.assertFalse((self.home / ".profile").exists())
        marker.touch()
        passwd.write_text("tester:x:1000:1000:Tester:/home/tester:/bin/sh\n")
        self.command("/bin/bash", fixture)
        self.assertEqual((self.home / ".profile").read_bytes(), (ROOT / "zsh/.profile.synology").read_bytes())

    def test_tmux_status_with_and_without_utility(self):
        tmux = shutil.which("tmux")
        if not tmux:
            self.skipTest("tmux unavailable")
        config = ROOT / "ubuntu/.tmux.conf"
        socket = self.work / "socket"
        cmd = [tmux, "-S", socket, "-f", "/dev/null"]
        result = self.command(*cmd, "new-session", "-d", "/bin/sh", status=None)
        if result.returncode and "Operation not permitted" in result.stderr and not os.environ.get("DOTFILES_REQUIRE_TMUX"):
            self.skipTest("tmux sockets unavailable in this process")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.addCleanup(self.command, *cmd, "kill-server", status=None)
        utility = self.bin / "tmux-mem-cpu-load"
        for available in (False, True, False):
            if available:
                executable(utility, "printf 'test CPU load\\n'\n")
            else:
                utility.unlink(missing_ok=True)
            self.command(*cmd, "source-file", config)
            status = self.command(*cmd, "show-options", "-gv", "status-right").stdout
            self.assertIn("%l:%M%P", status)
            self.assertEqual("tmux-mem-cpu-load" in status, available)
            if available:
                self.assertIn("--interval 2 --averages-count 0 2>/dev/null", status)


if __name__ == "__main__":
    unittest.main(verbosity=2)
