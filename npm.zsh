#!/usr/bin/env zsh

_fzf_complete_npm() {
    if [[ "$@" = 'npm run'* ]]; then
        _fzf_complete_npm-run '' "$@"
        return
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_npm-run() {
    local fzf_options="$1"
    shift
    _fzf_complete "--ansi --tiebreak=index $fzf_options" "$@" < <(npm run 2> /dev/null | awk '
        /^  [^ ]/ {
            gsub(/^ */, "")
            command = $0
            getline
            gsub(/^ */, "")
            print command "  " $0
        }' | _fzf_complete_npm_tabularlize)
}

_fzf_complete_npm-run_post() {
    awk '{ print $1 }'
}

_fzf_complete_npm_tabularlize() {
    awk \
        -v yellow="$(tput setaf 3)" \
        -v reset="$(tput sgr0)" '
        {
            scripts[NR] = $1

            if (length($1) > script_max) {
                script_max = length($1)
            }

            $1 = ""
            messages[NR] = $0
        }
        END {
            for (i = 1; i <= length(scripts); ++i) {
                printf "%s%-" script_max "s%s %s\n", yellow, scripts[i], reset, messages[i]
            }
        }
    '
}
