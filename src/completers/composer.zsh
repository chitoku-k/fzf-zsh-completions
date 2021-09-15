#!/usr/bin/env zsh

_fzf_complete_composer() {
    setopt local_options no_aliases
    local arguments=("${(Q)${(z)"$(_fzf_complete_trim_env "$@")"}[@]}")
    local subcommand=${arguments[2]}

    local original_arguments=("${(Q)${(z)@}[@]}")
    local command_pos=${original_arguments[(i)$arguments[1]]}
    if (( $command_pos > 1 )); then
        local -x ${${(Q)${(z)@}}[1, $command_pos - 1]}
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

    _fzf_complete --ansi --read0 --print0 --tiebreak=index -- "$@" < <(php -r '
        echo implode(
            "\0",
            array_keys(
                (array) json_decode(
                    stream_get_contents(STDIN)
                )->scripts
            )
        );' < $composer 2> /dev/null)
}

_fzf_complete_composer_run-script_post() {
    local script
    local input=$(cat)

    for script in ${(0)input}; do
        echo ${${(q+)script}//\\n/\\\\n}
    done
}
