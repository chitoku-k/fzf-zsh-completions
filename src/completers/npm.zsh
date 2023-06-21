#!/usr/bin/env zsh

_fzf_complete_npm() {
    setopt local_options no_aliases
    local command_pos=$(_fzf_complete_get_command_pos "$@")
    local arguments=("${(Qe)${(z)$(_fzf_complete_requote_arguments ${~${(z)@}})}[@][$command_pos, -1]}")
    local subcommand=${arguments[2]}

    if (( $command_pos > 1 )); then
        local -x "${(Qe)${(z)$(_fzf_complete_requote_arguments ${~${(z)@}})}[@][1, $command_pos - 1]}"
    fi

    if (( $+functions[_fzf_complete_npm_${subcommand}] )) && _fzf_complete_npm_${subcommand} "$@"; then
        return
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_npm_run() {
    local package=${npm_directory-$(dirname -- $(npm root))}/package.json
    if [[ ! -f $package ]]; then
        return
    fi

    _fzf_complete --ansi --read0 --print0 --tiebreak=index -- "$@" < <(node -e '
        process.stdout.write(
            Object.keys(
                JSON.parse(
                    require("fs").readFileSync(process.stdin.fd, "utf-8")
                ).scripts
            ).join("\0")
        )' < $package 2> /dev/null)
}

_fzf_complete_npm_run_post() {
    local script
    local input=$(cat)

    for script in ${(0)input}; do
        echo ${${(q+)script}//\\n/\\\\n}
    done
}
