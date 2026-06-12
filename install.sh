#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$REPO_DIR"
REMOTE_BASE="${DOTFILES_REMOTE_BASE:-https://raw.githubusercontent.com/TheTrueZeroTwo/DotFiles/main}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/thetruezerotwo-dotfiles"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/thetruezerotwo-dotfiles"
BACKUP_DIR="$STATE_DIR/backups"
STATE_FILE="$STATE_DIR/install.state"
STATE_TMP=""

DRY_RUN=0
FORCE=0
INSTALL_PACKAGES=1
UPDATE_ALIASES=0
SETUP_ZSH=0
INSTALL_GIT_TOOLS=0
CHANGE_SHELL=0
YES=0

usage() {
  cat <<USAGE
Usage: ./install.sh [options]

Options:
  --dry-run             Show what would happen without changing files
  --yes                 Assume yes for non-dangerous prompts
  --no-packages         Skip package installation
  --packages            Install packages, default behavior
  --update-aliases      Refresh ~/.bash_aliases and ~/.pentesting_aliases from repo
  --force               Overwrite local changes after backing them up
  --setup-zsh           Install/configure Oh My Zsh plugins and Powerlevel10k
  --change-shell        Change default shell to zsh after setup
  --install-git-tools   Install optional tools listed in packages/git.txt
  --help                Show this help

Examples:
  ./install.sh --dry-run
  ./install.sh --no-packages
  ./install.sh --update-aliases --no-packages
  ./install.sh --update-aliases --force --no-packages
USAGE
}

log() { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*" >&2; }
fail() { printf '[x] %s\n' "$*" >&2; exit 1; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

run_as_root() {
  if [ "$DRY_RUN" -eq 1 ]; then
    run "$@"
  elif [ "$(id -u)" -eq 0 ]; then
    run "$@"
  elif command -v sudo >/dev/null 2>&1; then
    run sudo "$@"
  else
    fail "This operation requires root or sudo: $*"
  fi
}

confirm() {
  local prompt="$1"
  if [ "$YES" -eq 1 ]; then
    return 0
  fi
  if [ ! -t 0 ]; then
    return 1
  fi
  local answer
  printf '%s [y/N]: ' "$prompt"
  read -r answer
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

hash_file() {
  local file="$1"
  if [ ! -e "$file" ]; then
    printf 'missing'
    return 0
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    cksum "$file" | awk '{print $1}'
  fi
}

state_get() {
  local key="$1"
  [ -r "$STATE_FILE" ] || return 0
  awk -F= -v k="$key" '$1 == k { value = substr($0, index($0, "=") + 1) } END { if (value != "") print value }' "$STATE_FILE"
}

state_put() {
  local key="$1"
  local value="$2"
  printf '%s=%s\n' "$key" "$value" >> "$STATE_TMP"
}

backup_file() {
  local file="$1"
  [ -e "$file" ] || return 0
  local stamp base backup
  stamp="$(date +%Y%m%d-%H%M%S)"
  base="$(basename "$file")"
  backup="$BACKUP_DIR/${base}.${stamp}.bak"
  run mkdir -p "$BACKUP_DIR"
  run cp -a "$file" "$backup"
  log "Backup saved: $backup"
}

copy_managed_file() {
  local src="$1"
  local dest="$2"
  local key="$3"
  local src_hash dest_hash prev_dest_hash prev_src_hash prev_local_modified skipped
  skipped=0

  [ -r "$src" ] || fail "Missing source file: $src"

  src_hash="$(hash_file "$src")"
  dest_hash="$(hash_file "$dest")"
  prev_dest_hash="$(state_get "${key}_dest_hash" || true)"
  prev_src_hash="$(state_get "${key}_src_hash" || true)"
  prev_local_modified="$(state_get "${key}_local_modified" || true)"

  if [ -e "$STATE_FILE" ]; then
    log "Previous install state detected for $key"
  fi

  if [ "$dest_hash" = "$src_hash" ]; then
    log "$dest is already current"
  elif [ ! -e "$dest" ]; then
    log "Installing $dest"
    run mkdir -p "$(dirname "$dest")"
    run cp "$src" "$dest"
  elif [ "$FORCE" -eq 1 ] || [ "$UPDATE_ALIASES" -eq 1 ]; then
    log "Updating $dest from repo copy"
    backup_file "$dest"
    run cp "$src" "$dest"
  elif [ "${prev_local_modified:-0}" != "1" ] && [ -n "$prev_dest_hash" ] && [ "$dest_hash" = "$prev_dest_hash" ] && [ "$src_hash" != "$prev_src_hash" ]; then
    log "Repo version changed and local file was not edited; updating $dest"
    backup_file "$dest"
    run cp "$src" "$dest"
  else
    warn "$dest differs from the repo version and may contain local edits; leaving it unchanged"
    warn "Run: ./install.sh --update-aliases --no-packages to overwrite after backup"
    skipped=1
  fi

  dest_hash="$(hash_file "$dest")"
  state_put "${key}_src_hash" "$src_hash"
  state_put "${key}_dest_hash" "$dest_hash"
  state_put "${key}_dest" "$dest"
  state_put "${key}_local_modified" "$skipped"
}

ensure_source_block() {
  local rc_file="$1"
  local marker_start="# >>> TheTrueZeroTwo DotFiles >>>"
  local marker_end="# <<< TheTrueZeroTwo DotFiles <<<"

  if [ ! -e "$rc_file" ] && [ "$DRY_RUN" -eq 0 ]; then
    touch "$rc_file"
  fi

  if [ -e "$rc_file" ] && grep -qF "$marker_start" "$rc_file"; then
    log "Source block already exists in $rc_file"
    return 0
  fi

  backup_file "$rc_file"
  log "Adding source block to $rc_file"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] append managed source block to %s\n' "$rc_file"
  else
    cat >> "$rc_file" <<BLOCK

$marker_start
[ -f "\$HOME/.bash_aliases" ] && . "\$HOME/.bash_aliases"
[ -f "\$HOME/.pentesting_aliases" ] && . "\$HOME/.pentesting_aliases"
$marker_end
BLOCK
  fi
}

detect_pm() {
  if command -v dnf >/dev/null 2>&1; then
    echo dnf
  elif command -v apt-get >/dev/null 2>&1; then
    echo apt
  elif command -v pacman >/dev/null 2>&1; then
    echo pacman
  elif command -v yum >/dev/null 2>&1; then
    echo yum
  elif command -v zypper >/dev/null 2>&1; then
    echo zypper
  elif command -v apk >/dev/null 2>&1; then
    echo apk
  elif command -v brew >/dev/null 2>&1; then
    echo brew
  else
    echo unsupported
  fi
}

pm_update() {
  local pm="$1"
  case "$pm" in
    dnf) run_as_root dnf makecache --refresh ;;
    apt) run_as_root apt-get update ;;
    pacman) run_as_root pacman -Sy ;;
    yum) run_as_root yum makecache ;;
    zypper) run_as_root zypper --non-interactive refresh ;;
    apk) run_as_root apk update ;;
    brew) run brew update ;;
    unsupported) warn "No supported package manager detected" ;;
  esac
}

pm_install() {
  local pm="$1"
  shift
  [ "$#" -gt 0 ] || return 0
  case "$pm" in
    dnf) run_as_root dnf install -y "$@" ;;
    apt) run_as_root apt-get install -y "$@" ;;
    pacman) run_as_root pacman -S --needed --noconfirm "$@" ;;
    yum) run_as_root yum install -y "$@" ;;
    zypper) run_as_root zypper --non-interactive install --no-recommends "$@" ;;
    apk) run_as_root apk add --no-cache "$@" ;;
    brew) run brew install "$@" ;;
    *) return 1 ;;
  esac
}

package_file_for_pm() {
  case "$1" in
    dnf|yum) echo "$SOURCE_DIR/packages/fedora.txt" ;;
    zypper) echo "$SOURCE_DIR/packages/opensuse.txt" ;;
    apk) echo "$SOURCE_DIR/packages/alpine.txt" ;;
    apt) echo "$SOURCE_DIR/packages/debian.txt" ;;
    pacman) echo "$SOURCE_DIR/packages/arch.txt" ;;
    brew) echo "$SOURCE_DIR/packages/macos.txt" ;;
    apk) echo "$SOURCE_DIR/packages/alpine.txt" ;;
    zypper) echo "$SOURCE_DIR/packages/opensuse.txt" ;;
    *) echo "" ;;
  esac
}

read_packages() {
  local file="$1"
  [ -r "$file" ] || return 0
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$file"
}

fetch_source_file() {
  local rel="$1"
  local dest="$SOURCE_DIR/$rel"
  if [ -r "$dest" ]; then
    return 0
  fi
  run mkdir -p "$(dirname "$dest")"
  log "Fetching $rel from remote repo"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] curl -fsSL %q -o %q\n' "$REMOTE_BASE/$rel" "$dest"
  else
    curl -fsSL "$REMOTE_BASE/$rel" -o "$dest"
  fi
}

prepare_sources() {
  if [ -r "$REPO_DIR/shell/bash_aliases" ] && [ -r "$REPO_DIR/shell/functions.sh" ]; then
    SOURCE_DIR="$REPO_DIR"
    return 0
  fi

  SOURCE_DIR="$STATE_DIR/source-cache"
  warn "Repo files were not found next to install.sh; using remote source cache: $SOURCE_DIR"

  local rel
  for rel in \
    shell/bash_aliases \
    shell/pentesting_aliases \
    shell/functions.sh \
    shell/path.sh \
    packages/common.txt \
    packages/fedora.txt \
    packages/opensuse.txt \
    packages/alpine.txt \
    packages/debian.txt \
    packages/arch.txt \
    packages/macos.txt \
    packages/alpine.txt \
    packages/opensuse.txt \
    packages/git.txt \
    git_packages_to_install.txt; do
    fetch_source_file "$rel"
  done
}

install_packages() {
  local pm distro_file tmp_packages
  pm="$(detect_pm)"
  log "Detected package manager: $pm"

  [ "$pm" != unsupported ] || return 0

  tmp_packages="$(mktemp)"
  read_packages "$SOURCE_DIR/packages/common.txt" >> "$tmp_packages"
  distro_file="$(package_file_for_pm "$pm")"
  [ -n "$distro_file" ] && read_packages "$distro_file" >> "$tmp_packages"

  if [ ! -s "$tmp_packages" ]; then
    warn "No packages listed for $pm"
    rm -f "$tmp_packages"
    return 0
  fi

  pm_update "$pm"

  local failed_packages=()
  local pkg
  while IFS= read -r pkg; do
    [ -n "$pkg" ] || continue
    if ! pm_install "$pm" "$pkg"; then
      failed_packages+=("$pkg")
    fi
  done < "$tmp_packages"
  rm -f "$tmp_packages"

  if [ "${#failed_packages[@]}" -gt 0 ]; then
    warn "Failed packages: ${failed_packages[*]}"
  fi
}

install_git_tools() {
  # shellcheck source=/dev/null
  [ -r "$SOURCE_DIR/git_packages_to_install.txt" ] && . "$SOURCE_DIR/git_packages_to_install.txt"

  local file="$SOURCE_DIR/packages/git.txt"
  [ -r "$file" ] || return 0

  local tool func failed=()
  while IFS= read -r tool; do
    tool="${tool%%#*}"
    tool="$(printf '%s' "$tool" | xargs 2>/dev/null || printf '%s' "$tool")"
    [ -n "$tool" ] || continue
    func="install_git_tool_${tool}"
    if declare -f "$func" >/dev/null 2>&1; then
      log "Installing optional git/release tool: $tool"
      if ! "$func"; then
        failed+=("$tool")
      fi
    else
      warn "No installer function for optional tool: $tool"
      failed+=("$tool")
    fi
  done < "$file"

  [ "${#failed[@]}" -eq 0 ] || warn "Failed optional tools: ${failed[*]}"
}

setup_zsh() {
  command -v zsh >/dev/null 2>&1 || warn "zsh command not found after package install"

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if confirm "Install Oh My Zsh for this user?"; then
      run sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
      warn "Skipping Oh My Zsh"
      return 0
    fi
  else
    log "Oh My Zsh already installed"
  fi

  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  run mkdir -p "$custom_dir/plugins" "$custom_dir/themes"

  if [ ! -d "$custom_dir/plugins/zsh-syntax-highlighting" ]; then
    run git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
  fi

  if [ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]; then
    run git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions"
  fi

  if [ ! -d "$custom_dir/themes/powerlevel10k" ]; then
    run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k"
  fi

  if [ -f "$HOME/.zshrc" ]; then
    backup_file "$HOME/.zshrc"
    if [ "$DRY_RUN" -eq 0 ]; then
      sed -i.bak 's#^ZSH_THEME=.*#ZSH_THEME="powerlevel10k/powerlevel10k"#' "$HOME/.zshrc" || true
      if grep -q '^plugins=' "$HOME/.zshrc"; then
        sed -i.bak 's#^plugins=.*#plugins=(git zsh-autosuggestions zsh-syntax-highlighting)#' "$HOME/.zshrc" || true
      fi
    else
      log "Would configure Powerlevel10k and zsh plugins"
    fi
  fi

  if [ "$CHANGE_SHELL" -eq 1 ]; then
    local zsh_path
    zsh_path="$(command -v zsh || true)"
    [ -n "$zsh_path" ] || fail "zsh not found"
    run chsh -s "$zsh_path"
  fi
}

install_aliases() {
  run mkdir -p "$STATE_DIR"
  STATE_TMP="$(mktemp)"
  state_put installed_at "$(date -Iseconds)"
  state_put source_dir "$SOURCE_DIR"

  run mkdir -p "$CONFIG_DIR/shell"
  copy_managed_file "$SOURCE_DIR/shell/path.sh" "$CONFIG_DIR/shell/path.sh" path_sh
  copy_managed_file "$SOURCE_DIR/shell/functions.sh" "$CONFIG_DIR/shell/functions.sh" functions_sh
  copy_managed_file "$SOURCE_DIR/shell/bash_aliases" "$HOME/.bash_aliases" bash_aliases
  copy_managed_file "$SOURCE_DIR/shell/pentesting_aliases" "$HOME/.pentesting_aliases" pentesting_aliases

  ensure_source_block "$HOME/.bashrc"
  ensure_source_block "$HOME/.zshrc"

  if [ "$DRY_RUN" -eq 1 ]; then
    log "Would write state file: $STATE_FILE"
    rm -f "$STATE_TMP"
  else
    mv "$STATE_TMP" "$STATE_FILE"
  fi
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --yes|-y) YES=1 ;;
      --no-packages) INSTALL_PACKAGES=0 ;;
      --packages) INSTALL_PACKAGES=1 ;;
      --update-aliases) UPDATE_ALIASES=1 ;;
      --force) FORCE=1 ;;
      --setup-zsh) SETUP_ZSH=1 ;;
      --change-shell) CHANGE_SHELL=1 ;;
      --install-git-tools) INSTALL_GIT_TOOLS=1 ;;
      --help|-h) usage; exit 0 ;;
      *) fail "Unknown option: $1" ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  log "Using repo: $REPO_DIR"
  run mkdir -p "$STATE_DIR" "$BACKUP_DIR"
  prepare_sources
  log "Using source files: $SOURCE_DIR"

  install_aliases

  if [ "$INSTALL_PACKAGES" -eq 1 ]; then
    install_packages
  else
    log "Skipping package installation"
  fi

  if [ "$INSTALL_GIT_TOOLS" -eq 1 ]; then
    install_git_tools
  fi

  if [ "$SETUP_ZSH" -eq 1 ]; then
    setup_zsh
  fi

  log "Done. Restart your terminal or run: source ~/.bashrc"
}

main "$@"
