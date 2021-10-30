#!/usr/bin/env zsh

_fzf_complete_asdf() {
  if [[ "$@" =~ '^asdf install (.*) ' ]]; then
    _fzf_complete_asdf-install '' "$match[1]" "$@"
    return
  fi

  if [[ "$@" =~ '^asdf global (.*) ' ]]; then
    _fzf_complete_asdf-global '' "$match[1]" "$@"
    return
  fi

  if [[ "$@" =~ '^asdf local (.*) ' ]]; then
    _fzf_complete_asdf-local '' "$match[1]" "$@"
    return
  fi

  _fzf_path_completion "$prefix"  "$@"
}

_fzf_complete_asdf-install() {
  shift
  _fzf_complete "--ansi --tiebreak=index $fzf_options" "asdf install "$1" " < <(asdf list-all "$1" | sort)
}

_fzf_complete_asdf-global() {
  shift
  _fzf_complete "--ansi --tiebreak=index $fzf_options" "asdf global "$1" " < <(asdf list "$1" | sort)
}

_fzf_complete_asdf-local() {
  shift
  _fzf_complete "--ansi --tiebreak=index $fzf_options" "asdf local "$1" " < <(asdf list "$1" | sort)
}

_fzf_complete_asdf-install_post() {
    awk '{ print $0 }'
}
