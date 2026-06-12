# CI and Testing

The repo uses Gitea Actions, not GitHub Actions.

Workflow path:

```text
.gitea/workflows/distro-checks.yml
```

Local check script:

```bash
./scripts/ci-local.sh
```

## What CI checks

The Gitea workflow runs against multiple containers:

- Alpine
- Arch
- Debian
- Fedora
- Ubuntu
- OpenSUSE

It verifies basic shell syntax, ShellCheck, install dry-run, install without packages, and helper loading.

## Why checkout dependencies are installed first

`actions/checkout@v4` needs `node`. Minimal distro containers often do not include Node, so each matrix entry installs checkout dependencies before the checkout step.

## Public IP in CI

CI should not depend on an external public-IP service. Use:

```bash
NETINFO2_SKIP_PUBLIC_IP=1 netinfo2 localhost
```
