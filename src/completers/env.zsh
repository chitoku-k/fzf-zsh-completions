#!/usr/bin/env zsh

_fzf_complete_env() {
    local arguments=(${(Q)${(z)@}})
    arguments=($(_fzf_complete_trim_env "${arguments[2,-1]}"))
    local cmd=${${${arguments}}[1]}

    if (( $+functions[_fzf_complete_$cmd] )); then
        LBUFFER=${LBUFFER/env /}
        _fzf_complete_$cmd ${@/env /}
        LBUFFER="env $LBUFFER"
        return
    fi

    _fzf_path_completion "$prefix" $@
}
