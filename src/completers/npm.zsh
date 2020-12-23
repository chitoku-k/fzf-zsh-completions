#!/usr/bin/env zsh

_fzf_complete_npm() {
    if [[ $@ = 'npm run'* ]]; then
        _fzf_complete_npm-run '' $@
        return
    fi

    _fzf_path_completion "$prefix" $@
}

_fzf_complete_npm-run() {
    local fzf_options=$1
    shift

    local package=${npm_directory-$(dirname -- $(npm root))}/package.json
    if [[ ! -f $package ]]; then
        return
    fi

    _fzf_complete --ansi --read0 --print0 --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@ < <(node -e '
        process.stdout.write(
            Object.keys(
                JSON.parse(
                    require("fs").readFileSync(process.stdin.fd, "utf-8")
                ).scripts
            ).join("\0")
        )' < $package 2> /dev/null)
}

_fzf_complete_npm-run_post() {
    local script
    local input=$(cat)

    for script in ${(0)input}; do
        echo ${${(q+)script}//\\n/\\\\n}
    done
}
