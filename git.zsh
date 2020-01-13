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

_fzf_complete_preview_git_diff='
    --preview-window=right:70%:wrap
    --preview="echo {} | awk \"{ printf(\\\"%s\\\", substr(\\\$0, 4)) }\" | xargs -0 git diff --no-ext-diff --color=always -- | awk \"NR == 2 || NR >= 5\""
'

_fzf_complete_git() {
    local last_options=${${(z)LBUFFER}[-2]}

    if [[ "$@" =~ '^git (checkout|log|rebase|reset)' ]]; then
        _fzf_complete_git-commits '' "$@"
        return
    fi

    if [[ "$@" =~ '^git (branch|cherry-pick|merge)' ]]; then
        _fzf_complete_git-commits '--multi' "$@"
        return
    fi

    if [[ "$@" = 'git commit'* ]]; then
        if [[ "$prefix" =~ '^--(reuse-message|reedit-message|fixup|squash)=' ]]; then
            prefix_option="${prefix/=*/=}"
            _fzf_complete_git-commits '' "$@"
            unset prefix_option
            return
        fi

        if [[ "$last_options" =~ '^(-[^-]*[cC]|--(reuse-message|reedit-message|fixup|squash))$' ]]; then
            _fzf_complete_git-commits '' "$@"
            return
        else
        fi

        if [[ "$prefix" =~ '^--message=' ]]; then
            prefix_option="${prefix/=*/=}"
            _fzf_complete_git-commit-messages '' "$@"
            unset prefix_option
            return
        fi

        if [[ "$last_options" =~ '^(-[^-]*m|--message)$' ]]; then
            _fzf_complete_git-commit-messages '' "$@"
            return
        fi

        if [[ "$prefix" =~ '^--author=' ]]; then
            return
        fi

        if [[ "$prefix" =~ '^--date=' ]]; then
            return
        fi

        if [[ "$prefix" =~ '^--(file|template)=$' ]]; then
            _fzf_path_completion '' "$@$prefix"
            return
        fi

        if [[ "$last_options" =~ '^(-[^-]*[Ft]|--(file|template))' ]]; then
            _fzf_path_completion '' "$@"
            return
        fi

        local cleanup_mode="strip whitespace verbatim scissors default"
        if [[ "$prefix" =~ '^--cleanup=' ]]; then
            _fzf_complete '' "$@" < <(echo $cleanup_mode | awk -v RS=' ' -v prefix="${prefix/=*/=}" '{ print prefix $0 }')
            return
        fi

        if [[ "$last_options" = '--cleanup' ]]; then
            _fzf_complete '' "$@" < <(echo $cleanup_mode | tr ' ' '\n')
            return
        fi

        local untracked_file_mode="no normal all"
        if [[ "$prefix" =~ '^--untracked-files=' ]]; then
            _fzf_complete '' "$@" < <(echo $untracked_file_mode | awk -v RS=' ' -v prefix="${prefix/=*/=}" '{ print prefix $0 }')
            return
        fi

        if [[ "$last_options" =~ '^(-[^-]*u|--untracked-files)' ]]; then
            _fzf_complete '' "$@" < <(echo $untracked_file_mode | tr ' ' '\n')
            return
        fi

        local gpg_command=$(git config --global gpg.program || (which gpg > /dev/null && echo gpg))
        if [[ "$prefix" =~ '^--gpg-sign=' ]]; then
            prefix_option="${prefix/=*/=}"
            _fzf_complete_git-gpg-key '' "$@"
            unset prefix_option
            return
        fi

        if [[ "$last_options" =~ '^(-[^-]*S|--gpg-sign)' ]]; then
            _fzf_complete_git-gpg-key '' "$@"
            return
        fi

        _fzf_complete_git-unstaged-files '--multi' "$@"
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
    local fzf_options="$1"
    shift
    _fzf_complete "--ansi --tiebreak=index $fzf_options" "$@" < <({
        git for-each-ref refs/heads refs/remotes refs/tags --format='%(refname:short) %(contents:subject)' 2> /dev/null
        git log --format='%h %s' 2> /dev/null
    } | awk -v prefix="$prefix_option" '{ print prefix $0 }' | _fzf_complete_git_tabularize)
}

_fzf_complete_git-commits_post() {
    awk '{ print $1 }'
}

_fzf_complete_git-commit-messages() {
    local fzf_options="$1"
    shift
    _fzf_complete "--ansi --tiebreak=index $fzf_options" "$@" < <(
        git log --format='%h %s' 2> /dev/null |
        awk -v prefix="$prefix_option" '
            {
                match($0, / /)
                print $1, prefix substr($0, RSTART + RLENGTH)
            }
        ' |
        _fzf_complete_git_tabularize
    )
}

_fzf_complete_git-commit-messages_post() {
    awk -v prefix="$prefix_option" '{
        match($0, /  /)
        str = substr($0, RSTART + RLENGTH)
        match(str, prefix)
        str = substr(str, RSTART + RLENGTH)
        gsub("'\''", "'\''\\'\'''\''", str)
        print prefix "'\''" str "'\''"
    }'
}

_fzf_complete_git-unstaged-files() {
    local fzf_options="$1"
    shift
    _fzf_complete "--ansi $fzf_options" "$@" < <(git status --porcelain=v1 -z 2> /dev/null | xargs -0 -n 1 | awk \
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
    if [[ -z "$@" ]]; then
        return
    fi

    local filename=$(awk '{ print substr($0, 4) }')
    echo "${(q)filename}"
}

_fzf_complete_git-gpg-key() {
    local fzf_options="$1"
    shift
    local global_key=$(git config --global user.signingkey)
    local local_key=$(git config --local user.signingkey)
    _fzf_complete "--ansi $fzf_options" "$@" < <(
        [[ -n "$gpg_command" ]] && LANG=C "$gpg_command" --list-secret-keys --keyid-format LONG 2> /dev/null |
        awk -v global_key="$global_key" -v local_key=$local_key -v prefix="$prefix_option" '
            /^sec/ {
                for (i = 1; ;) {
                    if ($0 == "") {
                        break
                    }
                    if ($1 == "uid") {
                        uid = $3 " " $4
                    }
                    if ($1 == "sec" || $1 == "ssb") {
                        sub(/.*\//, "", $2)
                        keys[i] = $2
                        types[i++] = $4
                    }
                    getline
                }
                for (j = 1; j < i; ++j) {
                    message = ""
                    if (keys[j] == global_key) {
                        message = message " " "[Git Global]"
                    }
                    if (keys[j] == local_key) {
                        message = message " " "[Git Local]"
                    }
                    print prefix keys[j], types[j], uid message
                }
                delete keys
                delete types
            }
        ' | _fzf_complete_git_tabularize
    )
}

_fzf_complete_git-gpg-key_post() {
    awk '{ print $1 }'
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
