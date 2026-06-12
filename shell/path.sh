# shellcheck shell=bash
# Extra PATH entries.

_dotfiles_add_path() {
  [ -d "$1" ] || return 0
  case ":${PATH}:" in
    *":$1:"*) ;;
    *) PATH="$1:${PATH}" ;;
  esac
}

_dotfiles_add_path "$HOME/.local/bin"
_dotfiles_add_path "$HOME/bin"
_dotfiles_add_path "/usr/local/sbin"
_dotfiles_add_path "/usr/local/bin"

export PATH
unset -f _dotfiles_add_path
