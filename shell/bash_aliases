# shellcheck shell=bash
# TheTrueZeroTwo Bash aliases and interactive helpers.

# Load optional per-user bashrc.d snippets safely.
if [ -d "${HOME}/.bashrc.d" ]; then
  for file in "${HOME}"/.bashrc.d/*.bashrc; do
    [ -r "$file" ] && . "$file"
  done
  unset file
fi

# Source shared helper files when installed from this repo or copied to $HOME.
_dotfiles_repo_dir="${THETRUEZEROTWO_DOTFILES_DIR:-}"
if [ -z "$_dotfiles_repo_dir" ]; then
  for candidate in "${XDG_CONFIG_HOME:-$HOME/.config}/thetruezerotwo-dotfiles" "$HOME/github/DotFiles" "$HOME/DotFiles" "$HOME/.dotfiles"; do
    if [ -r "$candidate/shell/functions.sh" ]; then
      _dotfiles_repo_dir="$candidate"
      break
    fi
  done
fi

if [ -n "$_dotfiles_repo_dir" ]; then
  [ -r "$_dotfiles_repo_dir/shell/path.sh" ] && . "$_dotfiles_repo_dir/shell/path.sh"
  [ -r "$_dotfiles_repo_dir/shell/functions.sh" ] && . "$_dotfiles_repo_dir/shell/functions.sh"
else
  # Fallback if only this file was copied.
  have() { command -v "$1" >/dev/null 2>&1; }
fi
unset _dotfiles_repo_dir candidate

# Allow sudo to use aliases.
alias sudo='sudo '

# Editing/reloading shell config.
alias ebrc='${EDITOR:-nano} ~/.bashrc'
alias ezrc='${EDITOR:-nano} ~/.zshrc'
alias ealias='${EDITOR:-nano} ~/.bash_aliases'
alias reloadbash='source ~/.bashrc'
alias reloadzsh='source ~/.zshrc'

# Common ls helpers. Use eza/exa when available, else ls.
if have eza; then
  alias ls='eza --group-directories-first'
  alias ll='eza -la --group-directories-first --git'
  alias la='eza -la --group-directories-first'
  alias lh='eza -lh --group-directories-first'
elif have exa; then
  alias ls='exa --group-directories-first'
  alias ll='exa -la --group-directories-first --git'
  alias la='exa -la --group-directories-first'
  alias lh='exa -lh --group-directories-first'
else
  alias ll='ls -l'
  alias la='ls -la'
  alias lh='ls -lh'
fi

# Git helpers.
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gb='git branch'
alias gl='git log --oneline --decorate --graph --all'
alias gco='git checkout'
alias gsw='git switch'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch --all --prune'
alias gr='git rebase'
alias gri='git rebase --interactive'

# Safer chmod helpers. Recursive dangerous modes require confirmation.
alias mx='chmod a+x'
alias chmod000r='safe_chmod_recursive 000'
alias chmod644r='safe_chmod_recursive 644'
alias chmod666r='safe_chmod_recursive 666'
alias chmod755r='safe_chmod_recursive 755'
alias chmod777r='safe_chmod_recursive 777'

# Network helpers.
alias openports='ports'
alias port='ports'
alias listening='ports'
alias routes='ip route 2>/dev/null || netstat -rn'
alias myroutes='routes'
alias dnsservers='_dotfiles_dns_servers'
alias externalip='publicip'
alias pubip='publicip'

# Package manager helpers.
# Cross-distro package wrapper functions are defined in shell/functions.sh.
# Run `pac` for the full help menu.
alias aptu='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y'
alias dnfu='sudo dnf upgrade --refresh -y && sudo dnf autoremove -y'
alias yumu='sudo yum update -y'
alias zypup='sudo zypper refresh && sudo zypper update -y'
alias brewu='brew update && brew upgrade && brew cleanup'

# Filesystem helpers.
alias mkdirp='mkdir -p'
alias dus='du -sh * 2>/dev/null | sort -h'
alias dfh='df -hT'
alias freeh='free -h'
alias psg='ps aux | grep -v grep | grep -i --'
alias c='clear'
alias path='printf "%s\n" "${PATH//:/\n}"'

# Generate a random password.
genpasswd() {
  local len="${1:-30}"
  tr -dc 'A-Za-z0-9_@%+=:,./-' < /dev/urandom | head -c "$len"
  printf '\n'
}

# List by file size in current directory.
sbs() {
  du -b --max-depth 1 2>/dev/null \
    | sort -nr \
    | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e'
}

# Quick HTTP server for current directory.
servehere() {
  local port="${1:-8000}"
  if have python3; then
    python3 -m http.server "$port"
  elif have python; then
    python -m SimpleHTTPServer "$port"
  else
    echo "python3 is required" >&2
    return 1
  fi
}
