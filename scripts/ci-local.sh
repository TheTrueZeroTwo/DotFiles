#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

bash -n install.sh
bash -n uninstall.sh
bash -n shell/path.sh shell/functions.sh shell/bash_aliases shell/pentesting_aliases .bash_aliases .pentesting_aliases

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck install.sh uninstall.sh shell/path.sh shell/functions.sh shell/bash_aliases shell/pentesting_aliases .bash_aliases .pentesting_aliases
else
  echo "shellcheck not installed; skipping lint" >&2
fi

home_tmp="$(mktemp -d)"
trap 'rm -rf "$home_tmp"' EXIT
export HOME="$home_tmp"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
./install.sh --dry-run --yes
./install.sh --no-packages --yes
# shellcheck disable=SC1090
source "$HOME/.bash_aliases"
type netinfo2 >/dev/null
NETINFO2_SKIP_PUBLIC_IP=1 netinfo2 localhost >/tmp/netinfo2.out
