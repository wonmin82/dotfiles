"""Run isolated Vim and check clang-format schemas and output without installing anything."""
import argparse
import difflib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
VIM = ROOT / "vim"
TESTS = VIM / "tests"


def run(argv, env, cwd, source=None, *, vim_log=False):
    result = subprocess.run(argv, env=env, cwd=cwd, input=source, text=True, capture_output=True)
    if result.returncode or (result.stderr and not vim_log):
        raise RuntimeError(f"{argv[0]} exited {result.returncode}\n{result.stdout}{result.stderr}")
    return result.stdout


def check(condition, message):
    if not condition:
        raise RuntimeError(message)


def dump_keys(config):
    return set(re.findall(r"^([A-Za-z][A-Za-z0-9]*):", config, re.MULTILINE)) - {
        "BasedOnStyle", "Language",
    }


def make_environment(work):
    env = os.environ.copy()
    for name in ("HOME", "TMPDIR", "XDG_CACHE_HOME", "XDG_CONFIG_HOME", "XDG_DATA_HOME",
                 "XDG_STATE_HOME", "PYTHONPYCACHEPREFIX"):
        path = work / ("home with spaces" if name == "HOME" else name.lower())
        path.mkdir()
        env[name] = str(path)
    env.update(TMP=env["TMPDIR"], TEMP=env["TMPDIR"], TERM="xterm-256color",
               PYTHONDONTWRITEBYTECODE="1", GIT_OPTIONAL_LOCKS="0")
    return env


def verify(version, binary, vim, env, work, fixture, previous, override):
    current = work / f"clang {version}"
    current.mkdir()
    startup = [vim, "-N", "-n", "-i", "NONE", "--noplugin", "-es"]
    binaries_version = run([binary, "--version"], env, current).strip()
    check(re.search(rf"clang-format version {version}\.", binaries_version), binaries_version)

    # Dump the shipped dictionary through Vim's actual serializer.
    configdir = VIM / "config" / "clang-format"
    profile_path = current / "profile.json"
    profile_env = dict(env, DOTVIM_TEST_PROFILE=str(profile_path), DOTVIM_TEST_VERSION=str(version))
    run(startup + ["-u", "NONE", "-S", configdir / "legacy.vim", "-S", configdir / f"v{version}.vim",
                   "-c", 'call writefile([json_encode(g:clang_format_configs["v" . $DOTVIM_TEST_VERSION . ".0"])], $DOTVIM_TEST_PROFILE)',
                   "-c", "qa!"], profile_env, current)
    json_profile = profile_path.read_text().strip()
    profile = json.loads(json_profile)
    required = {"IndentWidth": 4, "TabWidth": 4, "UseTab": "Always", "ColumnLimit": 80,
                "BreakBeforeBraces": "Allman", "PointerAlignment": "Right",
                "NamespaceIndentation": "All", "SpacesBeforeTrailingComments": 2}
    check(all(profile[key] == value for key, value in required.items()), f"Incorrect style v{version}")
    filename = current / "source with spaces.cpp"
    filename.write_text(fixture)
    assume = f"--assume-filename={filename}"
    style = f"--style={json_profile}"
    schema = run([binary, "--style=Google", assume, "--dump-config"], env, current)
    active = run([binary, style, assume, "--dump-config"], env, current)
    check(dump_keys(schema) == set(profile) == dump_keys(active), f"Schema mismatch v{version}")

    first = run([binary, style, assume], env, current, fixture)
    second = run([binary, style, assume], env, current, first)
    check(first == second, f"Non-idempotent output v{version}")
    for expected in (
        "namespace sample\n{", "class Pair\n\t{", "int *find(int *input,",
        "return input;  // trailing comment", "\n\t\t\tif (", "first_argument_with_a_long_name,\n",
        "}  // namespace sample\n",
    ):
        check(expected in first, f"v{version} missing {expected!r}\n{first}")
    check(not any(line.endswith((" ", "\t")) for line in first.splitlines()), "Trailing whitespace")
    check("\n\n\n" not in first, f"Excess blank lines v{version}")

    if previous is not None and previous != first:
        print("".join(difflib.unified_diff(previous.splitlines(True), first.splitlines(True),
                                           f"v{version - 1}", f"v{version}")), end="")

    for name, config in (("valid project", "_clang-format"), ("invalid project", ".clang-format")):
        project = current / name
        project.mkdir()
        (project / config).write_text(
            "BasedOnStyle: LLVM\nIndentWidth: 2\nAllowShortFunctionsOnASingleLine: None\n" if name == "valid project"
            else "UnknownDotVimTestOption: true\n"
        )
        (project / "test.cpp").write_text("int*p;\nvoid f(){++p;}\n")
    range_source = current / "range.cpp"
    range_source.write_text("int* first;\nint* second;\n\nint* third;\n")
    command_path = current / 'clang-format executable'
    command_path.symlink_to(binary)
    path_bin = current / 'bin'
    path_bin.mkdir()
    (path_bin / f'clang-format-{version}').symlink_to(binary)
    vim_env = dict(env, DOTVIM_TEST_CLANG=str(command_path), DOTVIM_TEST_SOURCE=str(filename),
                   DOTVIM_TEST_PATH=str(path_bin) + os.pathsep + '/usr/bin' + os.pathsep + '/bin',
                   DOTVIM_TEST_RANGE=str(range_source), DOTVIM_TEST_OUTPUT=str(current),
                   DOTVIM_TEST_PROJECT=str(current / "valid project" / "test.cpp"),
                   DOTVIM_TEST_BAD_STYLE=str(current / "invalid project" / "test.cpp"),
                   DOTVIM_TEST_UNSUPPORTED=str(override))
    try:
        run(startup + ["-V1" + str(current / "vim.log"), "-u", VIM / ".vimrc",
                       "--cmd", "let g:dotvim_disable_plugins=1", "-S", TESTS / "format.vim"],
            vim_env, current, vim_log=True)
    except RuntimeError:
        for diagnostics in ("vim-errors", "vim.log"):
            path = current / diagnostics
            if path.exists():
                print(path.read_text(), end="")
        raise
    check((current / "vim.cpp").read_text() == first, f"Vim and direct output differ v{version}")
    print(f"PASS {binaries_version}: {len(profile)} options, idempotence, Vim mappings and project styles")
    return first

def verify_installed_layout(vim, env, work):
    home = Path(env["HOME"])
    runtime = home / ".vim" / "dotvim"
    runtime.mkdir(parents=True)
    for directory in ("config", "autoload"):
        shutil.copytree(VIM / directory, runtime / directory)
    shutil.copyfile(VIM / "coc.vim", runtime / "coc.vim")
    shutil.copyfile(VIM / ".vimrc", home / ".vimrc")
    (home / ".vimrc.local").write_text("unlet! g:c_syntax_for_h\n")
    run([vim, "-N", "-n", "-i", "NONE", "--noplugin", "-es", "-u", home / ".vimrc",
         "--cmd", "let g:dotvim_disable_plugins=1",
         "-c", "if exists(':ClangFormat') != 2 || exists('g:c_syntax_for_h') | cquit | endif",
         "-c", "qa!"], env, work)
    print("PASS installed layout and personal settings with spaces in HOME")


def verify_plugin_startup(vim, env, work):
    mock_bin = work / "mock bin"
    mock_bin.mkdir()
    dein = work / "mock dein.vim"
    dein.write_text("""function! dein#begin(path, vimrcs) abort
endfunction
function! dein#add(repo, options) abort
endfunction
function! dein#get(name) abort
    return {}
endfunction
function! dein#end() abort
endfunction
function! dein#check_install() abort
    return str2nr($DOTVIM_TEST_MISSING)
endfunction
function! dein#install() abort
    call writefile(['install'], $DOTVIM_TEST_EVENTS, 'a')
endfunction
""")
    git = mock_bin / "git"
    git.write_text("""#!/bin/sh
set -eu
[ "$1" = clone ]
printf 'clone\\n' >> "$DOTVIM_TEST_EVENTS"
[ "$DOTVIM_TEST_CLONE_FAILS" = 0 ]
for destination do :; done
/bin/mkdir -p "$destination/autoload"
/bin/cp "$DOTVIM_TEST_DEIN" "$destination/autoload/dein.vim"
""")
    node = mock_bin / "node"
    node.write_text("#!/bin/sh\nprintf 'v22.15.0\\n'\n")
    git.chmod(0o700)
    node.chmod(0o700)

    for name, installed, missing, expected in (
        ("fresh", False, True, ["clone", "install"]),
        ("missing bundles", True, True, ["install"]),
        ("managed dein", True, True, ["install"]),
        ("all present", True, False, []),
        ("opt out", True, True, []),
        ("opt out without dein", False, True, []),
        ("no load plugins", False, True, []),
        ("failed clone", False, True, ["clone"]),
    ):
        home = work / name
        home.mkdir()
        if installed:
            bundle = home / ".vim_data" / "bundle"
            checkout = "repos/github.com/Shougo/dein.vim" if name == "managed dein" else "dein.vim"
            autoload = bundle / checkout / "autoload"
            autoload.mkdir(parents=True)
            shutil.copyfile(dein, autoload / "dein.vim")
        if name.startswith("opt out"):
            (home / ".vimrc.local").write_text("let g:dotvim_auto_install_plugins = 0\n")
        events = home / "events"
        events.touch()
        status = home / "vim-status"
        startup_env = dict(env, HOME=str(home), PATH=str(mock_bin) + ":/usr/bin:/bin",
                           DOTVIM_TEST_DEIN=str(dein), DOTVIM_TEST_EVENTS=str(events),
                           DOTVIM_TEST_CLONE_FAILS=str(int(name == "failed clone")),
                           DOTVIM_TEST_MISSING=str(int(missing)), DOTVIM_TEST_STATUS=str(status))
        options = ["--noplugin"] if name == "no load plugins" else []
        run([vim, "-N", "-n", "-i", "NONE", "-es", "-V1" + str(home / "vim.log"),
             "-u", VIM / ".vimrc", *options,
             "-c", "if exists(':ClangFormat') != 2 | cquit | endif",
             "-c", "call writefile([json_encode(get(g:, 'coc_global_extensions', v:null)), "
                   "string(has('patch-9.0.0438') && has('job') && has('channel'))], $DOTVIM_TEST_STATUS)",
             "-c", "qa!"], startup_env, work, vim_log=True)
        check(events.read_text().splitlines() == expected, f"Unexpected install actions for {name}")
        extensions, coc_supported = status.read_text().splitlines()
        if coc_supported == "1":
            expected_extensions = None
            if installed or name == "fresh":
                expected_extensions = [] if name == "opt out" else ["coc-clangd", "coc-json"]
            check(json.loads(extensions) == expected_extensions,
                  f"Unexpected Coc extension list for {name}")
    print("PASS automatic plugin startup and offline opt-out with Git and dein stubs")


def verify_plugins(vim, env, work, plugin_root):
    launch = [vim, "-N", "-n", "-i", "NONE", "--noplugin", "-es"]
    output = work / "plugin fixture"
    output.mkdir()
    (output / "answer.c").write_text("int answer = 42;\n")
    plugin_env = dict(env, DOTVIM_TEST_OUTPUT=str(output), DOTVIM_TEST_VIMRC=str(VIM / ".vimrc"),
                      DOTVIM_TEST_BUNDLES=str(plugin_root))
    try:
        run(launch + ["-u", "NONE", "-V1" + str(output / "vim.log"),
                      "--cmd", "let g:dotvim_disable_plugins=1", "-S", TESTS / "plugins.vim"],
            plugin_env, output, vim_log=True)
    except RuntimeError:
        for name in ("vim-errors", "vim.log"):
            path = output / name
            if path.exists():
                print(path.read_text(), end="")
        raise
    print("PASS existing bundles: Unite quickfix/MRU, BufExplorer, NERDTree, Fugitive, sessions")

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("clang_root", type=Path, help="Directory with 14/bin/clang-format through 23/bin/clang-format")
    parser.add_argument("--vim", default="vim")
    parser.add_argument("--installed-bundles", type=Path,
                        help="Smoke-test existing bundles under the dein repos/github.com directory")
    args = parser.parse_args()
    vim = shutil.which(args.vim)
    if not vim:
        parser.error(f"Vim executable not found: {args.vim}")
    binaries = args.clang_root.expanduser().resolve()
    fixture = (TESTS / "style.cpp").read_text()
    status = 0
    with tempfile.TemporaryDirectory(dir=ROOT, prefix=".dotvim-test-") as directory:
        work = Path(directory)
        env = make_environment(work)
        verify_installed_layout(vim, env, work)
        verify_plugin_startup(vim, env, work)
        unsupported = work / "unsupported version"
        unsupported.write_text("#!/bin/sh\nprintf 'clang-format version 24.0.0\\n'\n")
        unsupported.chmod(0o700)
        previous = None
        for version in range(14, 24):
            binary = binaries / str(version) / "bin" / "clang-format"
            if not os.access(binary, os.X_OK):
                print(f"BLOCKED clang-format {version}: {binary} is unavailable")
                status = 1
                previous = None
                continue
            previous = verify(version, binary, vim, env, work, fixture, previous, unsupported)
        if args.installed_bundles:
            verify_plugins(vim, env, work, args.installed_bundles.expanduser().resolve())
    return status


if __name__ == "__main__":
    raise SystemExit(main())
