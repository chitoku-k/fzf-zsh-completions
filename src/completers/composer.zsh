#!/usr/bin/env zsh

_fzf_complete_composer() {
    setopt local_options no_aliases
    local command_pos=$(_fzf_complete_get_command_pos "$@")
    local arguments=("${(Qe)${(z)$(_fzf_complete_requote_arguments ${~${(z)@}})}[@][$command_pos, -1]}")
    local subcommand=${arguments[2]}

    if (( $command_pos > 1 )); then
        local -x "${(Qe)${(z)$(_fzf_complete_requote_arguments ${~${(z)@}})}[@][1, $command_pos - 1]}"
    fi

    if (( $+functions[_fzf_complete_composer_${subcommand}] )) && _fzf_complete_composer_${subcommand} "$@"; then
        return
    fi

    if [[ ${#arguments} = 1 ]]; then
        _fzf_complete_composer_run-script "$@"
        return
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_composer_run-script() {
    local composer=./composer.json
    if [[ ! -f $composer ]]; then
        return
    fi

    _fzf_complete --ansi --read0 --print0 --tiebreak=index -- "$@" < <(
        jq -jr '.scripts | keys_unsorted | join("\u0000")' $composer 2> /dev/null
    )
}

_fzf_complete_composer_run-script_post() {
    local script
    local input=$(cat)

    for script in ${(0)input}; do
        echo ${${(q+)script}//\\n/\\\\n}
    done
}
