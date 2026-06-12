#!/usr/bin/env bash
set -Eeuo pipefail

DRY_RUN=0
YES=0
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/thetruezerotwo-dotfiles"
STATE_FILE="$STATE_DIR/install.state"

usage() {
  cat <<USAGE
Usage: ./uninstall.sh [options]

Options:
  --dry-run   Show what would be removed without changing files
  --yes       Do not ask for confirmation
  --help      Show this help
USAGE
}

log() { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*" >&2; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

confirm() {
  if [ "$YES" -eq 1 ]; then
    return 0
  fi
  if [ ! -t 0 ]; then
    return 1
  fi
  local answer
  printf '%s [y/N]: ' "$1"
  read -r answer
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

remove_block() {
  local file="$1"
  [ -f "$file" ] || return 0
  if ! grep -q '# >>> TheTrueZeroTwo DotFiles >>>' "$file"; then
    return 0
  fi
  log "Removing source block from $file"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] remove managed block from %s\n' "$file"
  else
    awk '
      /# >>> TheTrueZeroTwo DotFiles >>>/ { skip=1; next }
      /# <<< TheTrueZeroTwo DotFiles <<</ { skip=0; next }
      skip != 1 { print }
    ' "$file" > "$file.tmp"
    mv "$file.tmp" "$file"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --yes|-y) YES=1 ;;
    --help|-h) usage; exit 0 ;;
    *) warn "Unknown option: $1"; usage; exit 1 ;;
  esac
  shift
done

if ! confirm "Remove TheTrueZeroTwo managed alias files and shell source blocks?"; then
  warn "Canceled"
  exit 1
fi

remove_block "$HOME/.bashrc"
remove_block "$HOME/.zshrc"

for file in "$HOME/.bash_aliases" "$HOME/.pentesting_aliases"; do
  if [ -e "$file" ]; then
    log "Removing $file"
    run rm -f "$file"
  fi
done

if [ -e "$STATE_FILE" ]; then
  log "Removing state file $STATE_FILE"
  run rm -f "$STATE_FILE"
fi

log "Done. Backups, if any, remain in $STATE_DIR/backups"
