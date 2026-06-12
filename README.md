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
git clone https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles.git ~/github/DotFiles
cd ~/github/DotFiles
./install.sh --dry-run
./install.sh
```

## One-line install

Review the script first. Dotfiles change shell behavior.

```bash
curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh | bash -s --
```

One-line install without packages:

```bash
curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh | bash -s -- --no-packages
```

One-line dry run:

```bash
curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh | bash -s -- --dry-run --no-packages
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
git pull --ff-only
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
│   ├── alpine.txt
│   ├── arch.txt
│   ├── debian.txt
│   ├── fedora.txt
│   ├── git.txt
│   ├── macos.txt
│   └── opensuse.txt
├── .gitea/workflows/distro-checks.yml
├── scripts/ci-local.sh
├── wiki/
│   ├── Home.md
│   ├── User-Guide.md
│   ├── One-Line-Install.md
│   ├── Aliases-and-Functions.md
│   ├── Package-Helpers.md
│   ├── Network-Helpers.md
│   ├── Contributor-Guide.md
│   ├── Pull-Request-Guide.md
│   ├── CI-and-Testing.md
│   └── Troubleshooting.md
└── docs/
```

## Helpful aliases/functions

- `pac` - cross-distro package-helper menu
- `paci`, `pacu`, `pacr`, `pacs`, `pacinfo` - install, upgrade, remove, search, and show package info across apt/dnf/yum/pacman/zypper/apk/brew
- `pacinstalled`, `paca`, `paclo`, `pacdnc`, `pacfiles`, `pacwhoownsit`, `paclcf`, `pacexpl`, `pacimpl` - package inventory, cache, ownership, config-file, and explicit/dependency helpers where supported
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

This repo includes Gitea Actions only. The workflow lives at `.gitea/workflows/distro-checks.yml` and checks the scripts on Fedora, Debian, Ubuntu, Arch, Alpine, and OpenSUSE containers. No `.github` directory is included.

Run the same basic checks locally with:

```bash
./scripts/ci-local.sh
```

## Wiki pages

Repository wiki-source pages are included in `wiki/`. Copy them into the Gitea wiki repo, or keep them in-tree as documentation. They cover install, user usage, aliases/functions, package helpers, network helpers, CI, contributing, pull requests, and troubleshooting.
