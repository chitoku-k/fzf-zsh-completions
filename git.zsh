#!/usr/bin/env zsh

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

setopt interactivecomments
_fzf_complete_preview_git_diff='
    --preview-window=right:70%:wrap
    --preview="git diff --no-ext-diff --color=always -- {+2..} | awk \"NR == 2 || NR >= 5\""
'

_fzf_complete_git() {
    if [[ "$@" =~ '^git (checkout|log|rebase|reset)' ]]; then
        _fzf_complete_git-commits '' "$@"
        return
    fi

    if [[ "$@" =~ '^git (branch|cherry-pick|merge)' ]]; then
        _fzf_complete_git-commits '--multi' "$@"
        return
    fi

    if [[ "$@" = 'git commit'* ]]; then
        if [[ "$prefix" = '--fixup=' ]]; then
            _fzf_complete_git-commits '' "$@"
        else
            _fzf_complete_git-commit-messages '' "$@"
        fi
        return
    fi

    if [[ "$@" = 'git add'* ]]; then
        FZF_DEFAULT_OPTS="$_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" \
            _fzf_complete_git-unstaged-files '--multi' "$@"
        return
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_git_post() {
    awk '{ print $1 }'
}

_fzf_complete_git-commits() {
    local options="$1"
    shift
    _fzf_complete "--ansi --tiebreak=index $options" "$@" < <({
        git branch -a --format='%(refname:short) %(contents:subject)' 2> /dev/null
        git log --color=always --format='%h %s' 2> /dev/null | awk -v prefix="$prefix" '{ print prefix $0 }'
    } | grep -v -e '^(HEAD detached' | _fzf_complete_git_tabularize)
}

_fzf_complete_git-commits_post() {
    awk '{ print $1 }'
}

_fzf_complete_git-commit-messages() {
    local options="$1"
    shift
    _fzf_complete "--ansi --tiebreak=index $options" "$@" < <(git log --color=always --format='%C(yellow)%h%C(reset)  %s' 2> /dev/null)
}

_fzf_complete_git-commit-messages_post() {
    awk '{
        $1 = ""
        sub(/^ /, "", $0)
        print "'\''" $0 "'\''"
    }'
}

_fzf_complete_git-unstaged-files() {
    local options="$1"
    shift
    _fzf_complete "--ansi $options" "$@" < <(git status --porcelain=v1 2> /dev/null | awk \
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

_fzf_complete_git-unstaged-files_post() {
    awk '{ print substr($0, 4) }'
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
