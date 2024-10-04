#!/usr/bin/env zsh

_fzf_complete_make() {
    setopt local_options no_aliases
    _fzf_complete_make-target '' "$@"
}

_fzf_complete_make-target() {
    local fzf_options=$1
    shift
    # handles target matching
    # 1. single target like `single_target:`
    # 2. multiple targets on a line `bigoutput   littleoutput  median : `
    # 3. proper exclude variable assigment `var := `

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- "$@" < <(grep -E '^(([a-zA-Z_-]+)\s*?)*:([^=]|$).*?$' Makefile 2> /dev/null | uniq | awk -F ':' '{ split($1, arr, " "); for (i in arr) print arr[i] }')
}
