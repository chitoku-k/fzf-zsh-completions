#!/usr/bin/env zsh

_fzf_complete_make() {
    setopt local_options no_aliases
    _fzf_complete_make-target '' "$@"
}

_fzf_complete_make-target() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- "$@" < <(grep -E '^[a-zA-Z_-]+:.*?$$' Makefile 2> /dev/null | uniq | awk -F ':' '{ print $1 }')
}
