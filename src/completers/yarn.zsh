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

    local package=$(dirname -- $(npm root))/package.json
    if [[ ! -f $package ]]; then
        return
    fi

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@ < <(
        jq '.workspaces| map(. + "/package.json")|@sh' -r < "$package" | xargs -I0 sh -c 'echo 0' | xargs -I0 sh -c 'cat 0 | jq -r .name' | sort
    )
}
