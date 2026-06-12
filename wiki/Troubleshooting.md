# Troubleshooting

## One-line install cannot fetch files

Check the raw URL:

```bash
curl -I https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/main/install.sh
```

Use a different branch:

```bash
DOTFILES_BRANCH=dev curl -fsSL https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles/raw/branch/dev/install.sh | bash -s -- --no-packages
```

## Local edits were not overwritten

The installer intentionally avoids overwriting local changes. To update aliases from the repo:

```bash
./install.sh --update-aliases --no-packages
```

To force all managed files after backup:

```bash
./install.sh --force --no-packages
```

Backups are stored in:

```text
~/.local/state/thetruezerotwo-dotfiles/backups/
```

## Commands are not available after install

Restart the terminal or run:

```bash
source ~/.bashrc
```

For zsh:

```bash
source ~/.zshrc
```

## `netinfo2` hangs or public IP lookup fails

Skip the public IP lookup:

```bash
NETINFO2_SKIP_PUBLIC_IP=1 netinfo2 localhost
```

## Package helper is unsupported

Run:

```bash
pacpm
```

If the detected package manager does not support a feature, the helper prints an unsupported message.
