#!/usr/bin/env zsh

_fzf_complete_yarn() {
    if [[ $@ = 'yarn workspace ' ]]; then
        _fzf_complete_yarn-workspace '' $@
        return
    fi

    if [[ $@ = 'yarn ' ]] || [[ $@ = 'yarn run ' ]]; then
        _fzf_complete_npm-run '' $@
        return
    fi

    _fzf_path_completion "$prefix" $@
}

_fzf_complete_yarn-workspace() {
    local fzf_options=$1
    shift

    local parent_package=$(dirname -- $(npm root))/package.json
    if [[ ! -f $parent_package ]]; then
        return
    fi

    IFS=$'\0'
    local workspace_packages_patterns=(`jq '.workspaces|map(. + "/package.json")|join("\u0000")' -r < "$parent_package"`)

    local package_names=()
    for pattern in $workspace_packages_patterns; do
        for p in ${~pattern}; do
            package_names+=(`jq -r '.name' < $p`)
        done
    done

    _fzf_complete --ansi --read0 --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@ < <(echo ${(j:\0:)package_names})
}

