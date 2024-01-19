#!/usr/bin/env zsh

group() {
    local name=$1
    shift

    [[ $GITHUB_ACTIONS = true ]] && echo ::group::$name || echo "=== $name ==="

    cat -- "$@"

    [[ $GITHUB_ACTIONS = true ]] && echo ::endgroup:: || echo
}

group zsh <(zsh --version)
group jq <(jq --version)
group awk <(awk --version 2> /dev/null || awk -W version)
group git <(git --version)
