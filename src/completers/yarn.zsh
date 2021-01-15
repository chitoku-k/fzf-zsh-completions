#!/usr/bin/env zsh

_fzf_complete_yarn() {
    local arguments=$@
    local subcommand=${${(Q)${(z)arguments}}[2]}

    if [[ $subcommand = 'workspace' ]]; then
        local workspace
        if ! workspace=$(_fzf_complete_parse_argument 3 1 "$arguments" '') && [[ -z $workspace ]]; then
            _fzf_complete_yarn-workspace '' $@
            return
        fi

        local npm_directory=$({
            yarn workspaces --json info | jq --arg workspace "$workspace" -r '.data | fromjson | .[$workspace].location'
        } 2> /dev/null)
        _fzf_complete_npm-run '' $@
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

    local workspace_packages_patterns=$(jq -r '.workspaces | map(. + "/package.json") | join("\u0000")' "$parent_package" 2> /dev/null)

   _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@ < <(jq -r '.name' ${~${(0)workspace_packages_patterns}} 2> /dev/null)
}
