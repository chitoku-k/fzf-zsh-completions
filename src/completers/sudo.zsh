#!/usr/bin/env zsh

_fzf_complete_sudo() {
    setopt local_options no_aliases
    local args=("${(Q)${(z)@}[@]}")
    local subcommand=${args:1:1}

    if (( $+functions[_fzf_complete_$subcommand] )); then
        LBUFFER=${LBUFFER/sudo /}
        _fzf_complete_$subcommand ${@/sudo /}
        LBUFFER="sudo $LBUFFER"
        return
    fi

    _fzf_path_completion "$prefix" "$@"
}
