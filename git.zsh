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

    if [[ "$@" = 'git add'* ]]; then
        _fzf_complete_git-add "$@"
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

_fzf_complete_git-add() {
    _fzf_complete '--ansi' "$@" < <(git status --porcelain=v1 2> /dev/null | awk \
        -v green="$(tput setaf 2)" \
        -v red="$(tput setaf 1)" \
        -v reset="$(tput sgr0)" '
            '"$_fzf_complete_awk_functions"'
            /^.[^ ]/ {
                print colorize_git_status(green, red, reset)
            }
        '
    )
}

_fzf_complete_git-add_post() {
    awk '{ print substr($0, 4) }'
}

_fzf_complete_awk_functions='
    function colorize_git_status(color1, color2, reset) {
        index_status = substr($0, 1, 1)
        work_tree_status = substr($0, 2, 1)
        if (index_status ~ /[MADRC]/) {
            index_status_color = color1
        }
        if (index_status work_tree_status ~ /(D[DU]|A[AU])|U.|\?\?|!!/) {
            index_status_color = color2
        }
        if (work_tree_status ~ /[MADRCU\?!]/) {
            work_tree_status_color = color2
        }

        return sprintf("%s%s%s%s%s%s %s", index_status_color, index_status, reset, work_tree_status_color, work_tree_status, reset, substr($0, 4))
    }
'
