# Update summary

This update converts the repo into a safer, repeatable dotfiles layout.

## Major fixes

- Rewrote malformed one-line scripts into valid Bash files.
- Added idempotent install logic.
- Added previous-install state tracking.
- Added hash comparison for alias updates.
- Added `--update-aliases` and `--force` behavior.
- Added backups before overwrites.
- Added `dnf`/Nobara/Fedora support.
- Added distro-specific package lists.
- Added `netinfo2` with cross-distro command fallbacks.
- Replaced `netstat`-only aliases with `ss`/`netstat`/`lsof` fallbacks.
- Replaced dangerous recursive chmod aliases with confirmation functions.
- Added optional zsh setup flags instead of silently changing shell.
- Added `uninstall.sh`.
- Added ShellCheck workflow.
- Added `.gitignore`, `.editorconfig`, `.shellcheckrc`, and MIT license.

## Alias update behavior

Use:

```bash
./install.sh --update-aliases --no-packages
```

If local alias edits are detected, use:

```bash
./install.sh --update-aliases --no-packages
```


## Gitea multi-distro checks

Added `.gitea/workflows/distro-checks.yml` to test this repo in Fedora, Debian, Ubuntu, Arch, Alpine, and OpenSUSE containers. The workflow checks Bash syntax, runs ShellCheck, performs installer dry-runs, installs aliases into a temporary home directory, and verifies that `netinfo2` loads successfully.

Also added `scripts/ci-local.sh` for local syntax/lint/install smoke tests.
