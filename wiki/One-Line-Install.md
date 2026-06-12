# One-Line Install

The one-line installer is designed to work even when only `install.sh` is streamed through `curl`. If the repo files are not beside the script, the installer downloads its source files from the Gitea raw URL.

## Default one-line install

```bash
curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh | bash -s --
```

## Safer one-line install without packages

```bash
curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh | bash -s -- --no-packages
```

## Dry run

```bash
curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh | bash -s -- --dry-run --no-packages
```

## Override branch or repo

```bash
DOTFILES_BRANCH=dev \
  curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/dev/install.sh | bash -s -- --no-packages
```

```bash
DOTFILES_REPO_URL=https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles \
DOTFILES_BRANCH=main \
  bash ./install.sh --no-packages
```

## Installer options

| Option | Meaning |
|---|---|
| `--dry-run` | show actions before changing files |
| `--yes` | assume yes for non-dangerous prompts |
| `--no-packages` | install dotfiles only |
| `--packages` | install packages, default |
| `--update-aliases` | refresh alias files from repo |
| `--force` | overwrite managed files after backup |
| `--setup-zsh` | install/configure Oh My Zsh plugins and Powerlevel10k |
| `--change-shell` | change default shell to zsh after setup |
| `--install-git-tools` | install optional tools listed in `packages/git.txt` |
| `--help` | show installer help |
