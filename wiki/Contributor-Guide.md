# Contributor Guide

## Repo source

```bash
git clone https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles.git
cd DotFiles
```

## Development flow

```bash
git switch -c fix/my-change
./scripts/ci-local.sh
./install.sh --dry-run --no-packages
git add -A
git commit -m "Describe change"
git push -u origin fix/my-change
```

## Rules

- Do not add `.github`; this repo uses `.gitea` workflows.
- Do not commit secrets, `.ssh`, `.gnupg`, `.env`, private keys, or machine-specific tokens.
- Keep shell files ShellCheck-friendly.
- Prefer functions over complex aliases when arguments are needed.
- Use `run_as_root` or sudo/root detection for installer package operations.
- Keep `README.md` and wiki pages updated when commands are added.

## Local tests

```bash
./scripts/ci-local.sh
bash -n install.sh
bash -n uninstall.sh
bash -n shell/functions.sh
bash -n shell/bash_aliases
bash -n shell/pentesting_aliases
```
