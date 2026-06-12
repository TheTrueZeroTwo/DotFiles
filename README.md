# TheTrueZeroTwo DotFiles

Personal Linux dotfiles and quality-of-life shell helpers.

These files are meant to be **added to an existing setup**, not blindly replace every config. The installer is idempotent, creates backups, records install state, and detects local edits before overwriting managed files.

## Supported systems

Tested design targets:

- Fedora / Nobara / RHEL-like systems using `dnf` or `yum`
- Debian / Ubuntu / Kali / Parrot using `apt`
- Arch / EndeavourOS / Manjaro using `pacman`
- Alpine using `apk`
- openSUSE using `zypper`
- macOS with Homebrew, partial support

## Safe install

```bash
git clone https://github.com/TheTrueZeroTwo/DotFiles.git ~/github/DotFiles
cd ~/github/DotFiles
./install.sh --dry-run
./install.sh
```

## One-line install

Review the script first. Dotfiles change shell behavior.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/TheTrueZeroTwo/DotFiles/main/install.sh)
```

## Common commands

Dry-run only:

```bash
./install.sh --dry-run
```

Install dotfiles but skip packages:

```bash
./install.sh --no-packages
```

Update aliases from the repo after pulling changes:

```bash
cd ~/github/DotFiles
git pull
./install.sh --update-aliases --no-packages
```

Force overwrite of any managed files after backup:

```bash
./install.sh --force --no-packages
```

Install optional zsh/Oh My Zsh/Powerlevel10k setup:

```bash
./install.sh --setup-zsh
```

Remove managed shell source blocks and managed alias files:

```bash
./uninstall.sh --dry-run
./uninstall.sh
```

## What gets installed

The installer manages these files:

- `~/.config/thetruezerotwo-dotfiles/shell/path.sh`
- `~/.config/thetruezerotwo-dotfiles/shell/functions.sh`
- `~/.bash_aliases`
- `~/.pentesting_aliases`
- shell source blocks in `~/.bashrc` and `~/.zshrc`
- helper files in `~/.config/thetruezerotwo-dotfiles/`
- install state in `~/.local/state/thetruezerotwo-dotfiles/install.state`
- backups in `~/.local/state/thetruezerotwo-dotfiles/backups/`

The installer checks if it has been run before. If a managed file is different from the repo version, it compares the current file against the last installed hash:

- same as last install + repo changed: update safely
- locally modified after install: skip unless `--update-aliases` or `--force`
- missing file: reinstall
- already current: do nothing

## Layout

```text
.
├── install.sh
├── uninstall.sh
├── shell/
│   ├── bash_aliases
│   ├── pentesting_aliases
│   ├── functions.sh
│   └── path.sh
├── packages/
│   ├── common.txt
│   ├── fedora.txt
│   ├── debian.txt
│   ├── arch.txt
│   ├── macos.txt
│   └── git.txt
└── .github/workflows/shellcheck.yml
```

## Helpful aliases/functions

- `netinfo2` - distro-safe network report using whatever tools are available
- `openports` - listening ports using `ss`, `netstat`, or `lsof`
- `myip` - local IP summary
- `publicip` - external IP using HTTPS
- `mkcd` - make a directory and enter it
- `extract` - extract many archive types
- `ports` - compact listening ports
- `dnfu`, `aptu`, `pacup`, `zypup`, `brewu` - package-manager helpers

## Security notes

- The installer does not store secrets.
- Do not commit `.ssh`, `.gnupg`, `.env`, private keys, tokens, or machine-specific configs.
- Review scripts before running curl-to-bash one-liners.


## CI checks

This repo includes both GitHub Actions and Gitea Actions workflows.
The Gitea workflow lives at `.gitea/workflows/distro-checks.yml` and checks the scripts on Fedora, Debian, Ubuntu, Arch, Alpine, and OpenSUSE containers.

Run the same basic checks locally with:

```bash
./scripts/ci-local.sh
```
