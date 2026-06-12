# User Guide

## Clone install

```bash
git clone https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles.git ~/github/DotFiles
cd ~/github/DotFiles
./install.sh --dry-run
./install.sh
```

## One-line install

Review the script first:

```bash
curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh | less
```

Run it:

```bash
curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh | bash -s --
```

Run one-line install without installing packages:

```bash
curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh | bash -s -- --no-packages
```

Run one-line dry-run:

```bash
curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh | bash -s -- --dry-run --no-packages
```

## Updating aliases

From a clone:

```bash
cd ~/github/DotFiles
git pull --ff-only
./install.sh --update-aliases --no-packages
```

Force overwrite managed files after backup:

```bash
./install.sh --force --no-packages
```

## Installed locations

| Path | Purpose |
|---|---|
| `~/.bash_aliases` | main aliases and interactive shortcuts |
| `~/.pentesting_aliases` | pentesting helper functions/aliases |
| `~/.config/thetruezerotwo-dotfiles/shell/functions.sh` | shared functions |
| `~/.config/thetruezerotwo-dotfiles/shell/path.sh` | PATH helpers |
| `~/.local/state/thetruezerotwo-dotfiles/install.state` | installer state and hashes |
| `~/.local/state/thetruezerotwo-dotfiles/backups/` | backups before overwrites |

## Uninstall

```bash
./uninstall.sh --dry-run
./uninstall.sh
```
