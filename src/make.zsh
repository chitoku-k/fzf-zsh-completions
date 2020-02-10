#!/usr/bin/env zsh

_fzf_complete_make() {
    local fzf_options=$1
    _fzf_complete "--ansi --tiebreak=index $fzf_options" $@ < <(grep -E '^[a-zA-Z_-]+:.*?$$' Makefile | uniq | awk -F ':' '{ print $1 }' 2> /dev/null)
}
