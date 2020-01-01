#!/usr/bin/env zsh

_fzf_complete_git() {
    if [[ "$@" = 'git branch'* ]] || [[ "$@" = 'git checkout'* ]]; then
        _fzf_complete --ansi "$@" < <(git branch -a --format='%(refname:short) %(contents:subject)' 2> /dev/null | _fzf_complete_git_tabularize)
        return
    fi

    if [[ "$@" = 'git commit'* ]]; then
        if [[ "$prefix" = '--fixup=' ]]; then
            _fzf_complete '--ansi --tiebreak=index' "$@" < <(git log --color=always --format='%C(yellow)%h%C(reset)  %s' 2> /dev/null | awk -v prefix="$prefix" '{ print prefix $0 }')
        else
            _fzf_complete_git-commit "$@"
        fi
        return
    fi

    if  [[ "$@" = 'git rebase'* ]] || [[ "$@" = 'git reset'* ]]; then
        _fzf_complete '--ansi --tiebreak=index' "$@" < <(git log --color=always --format='%C(yellow)%h%C(reset)  %s' 2> /dev/null)
        return
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_git-commit() {
    _fzf_complete '--ansi --tiebreak=index' "$@" < <(git log --color=always --format='%C(yellow)%h%C(reset)  %s' 2> /dev/null)
}

_fzf_complete_git_post() {
    awk '{ print $1 }'
}

_fzf_complete_git-commit_post() {
    awk '{
        $1 = ""
        sub(/^ /, "", $0)
        print "'\''" $0 "'\''"
    }'
}

_fzf_complete_git_tabularize() {
    awk \
        -v yellow="$(tput setaf 3)" \
        -v reset="$(tput sgr0)" '
        {
            refnames[NR] = $1

            if (length($1) > refname_max) {
                refname_max = length($1)
            }

            $1 = ""
            messages[NR] = $0
        }
        END {
            for (i = 1; i <= length(refnames); ++i) {
                printf "%s%-" refname_max "s%s %s\n", yellow, refnames[i], reset, messages[i]
            }
        }
    '
}
