# Pull Request Guide

## Before opening a pull request

Run:

```bash
./scripts/ci-local.sh
./install.sh --dry-run --no-packages
```

Check for accidental files:

```bash
find . -name .github -o -name .git -o -name '*.pem' -o -name '*.key' -o -name '.env*'
```

## Pull request checklist

- [ ] No `.github` directory added.
- [ ] `.gitea/workflows/distro-checks.yml` still works.
- [ ] Shell files pass `bash -n`.
- [ ] ShellCheck issues fixed or intentionally documented.
- [ ] Installer remains idempotent.
- [ ] New aliases/functions are documented in `wiki/Aliases-and-Functions.md`.
- [ ] New package helpers are documented in `wiki/Package-Helpers.md`.
- [ ] README layout is updated if files/directories changed.
- [ ] No secrets or private machine configs are committed.

## Good pull request titles

```text
Fix netinfo2 DNS fallback on Alpine
Add zypper support to pac helpers
Document package wrapper inputs
Improve one-line install for Gitea raw URLs
```
