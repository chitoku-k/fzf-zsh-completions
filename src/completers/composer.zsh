#!/usr/bin/env zsh

_fzf_complete_composer() {
    if [[ $@ = 'composer'* ]]; then
        _fzf_complete_composer-run-script '' $@
        return
    fi

    _fzf_path_completion "$prefix" $@
}

_fzf_complete_composer-run-script() {
    local fzf_options=$1
    shift

    local composer=./composer.json
    if [[ ! -f $composer ]]; then
        return
    fi

    _fzf_complete --ansi --read0 --print0 --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@ < <(php -r '
        echo implode(
            "\0",
            array_keys(
                (array) json_decode(
                    stream_get_contents(STDIN)
                )->scripts
            )
        );' < $composer 2> /dev/null)
}

_fzf_complete_composer-run-script_post() {
    local script
    local input=$(cat)

    for script in ${(0)input}; do
        echo ${${(q+)script}//\\n/\\\\n}
    done
}
