#!/usr/bin/env zsh

_fzf_complete_yarn() {
    setopt local_options no_aliases
    local command_pos=$(_fzf_complete_get_command_pos "$@")
    local arguments=("${(Q)${(z)"$(_fzf_complete_trim_env "$command_pos" "$@")"}[@]}")
    local subcommand=${arguments[2]}

    if (( $command_pos > 1 )); then
        local -x "${(e)${(z)"$(_fzf_complete_get_env "$command_pos" "$@")"}[@]}"
    fi

    if (( $+functions[_fzf_complete_yarn_${subcommand}] )) && _fzf_complete_yarn_${subcommand} "$@"; then
        return
    fi

    if [[ $subcommand = workspace ]]; then
        local workspace
        if ! workspace=$(_fzf_complete_parse_argument 3 1 '' "${arguments[@]}"); then
            _fzf_complete_yarn-workspace '' "$@"
            return
        fi

        local npm_directory=$({
            yarn workspaces --json info | jq --arg workspace "$workspace" -r '.data | fromjson | .[$workspace].location'
        } 2> /dev/null)
        _fzf_complete_npm_run "$@"
        return
    fi

    if [[ ${#arguments} = 1 ]] || [[ $subcommand = run ]]; then
        _fzf_complete_npm_run "$@"
        return
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_yarn-workspace() {
    local fzf_options=$1
    shift

    local parent_package=$(dirname -- $(npm root))/package.json
    if [[ ! -f $parent_package ]]; then
        return
    fi

    local workspace_packages_patterns=$(jq -r '.workspaces | map(. + "/package.json") | join("\u0000")' "$parent_package" 2> /dev/null)

   _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- "$@" < <(jq -r '.name' ${~${(0)workspace_packages_patterns}} 2> /dev/null)
}
