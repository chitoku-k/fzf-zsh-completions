#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_awk_functions='
    function colorize_git_status(input, cdup, color1, color2, reset) {
        index_status = substr(input, 1, 1)
        work_tree_status = substr(input, 2, 1)

        if (index_status ~ /[MADRC]/) {
            index_status_color = color1
        }
        if (index_status work_tree_status ~ /(D[DU]|A[AU])|U.|\?\?|!!/) {
            index_status_color = color2
        }
        if (work_tree_status ~ /[MADRCU\?!]/) {
            work_tree_status_color = color2
        }

        return sprintf("%s%s%s%s%s%s %s", index_status_color, index_status, reset, work_tree_status_color, work_tree_status, reset, cdup substr(input, 4))
    }
'

_fzf_complete_preview_git_diff=$(cat <<'PREVIEW_OPTIONS'
    --preview-window=right:70%:wrap
    --preview='echo {} | awk -v RS="" '\''
        {
            status = substr($0, 1, 2)
            input = substr($0, 4)

            if (status ~ /^(\?\?|!!)/) {
                printf "%s%c%s", "/dev/null", 0, input
            } else {
                printf "%s", input
            }
        }
    '\'' | xargs -0 git diff --no-ext-diff --color=always --'
PREVIEW_OPTIONS
)

_fzf_complete_preview_git_diff_cached=$(cat <<'PREVIEW_OPTIONS'
    --preview-window=right:70%:wrap
    --preview='echo {} | awk -v RS="" '\''
        {
            status = substr($0, 1, 2)
            input = substr($0, 4)

            if (status ~ /^(\?\?|!!)/) {
                printf "%s%c%s", "/dev/null", 0, input
            } else {
                printf "%s", input
            }
        }
    '\'' | xargs -0 git diff --cached --no-ext-diff --color=always --'
PREVIEW_OPTIONS
)

_fzf_complete_git() {
    setopt local_options extended_glob
    local arguments=$@
    local resolved_commands=()

    while true; do
        local resolved=$(_fzf_complete_git_resolve_alias ${(Q)${(z)arguments}})
        if [[ -z $resolved ]]; then
            break
        fi

        local subcommand=${${(Q)${(z)resolved}}[2]}
        if [[ ${resolved_commands[(r)$subcommand]} = $subcommand ]]; then
            break
        fi

        arguments=$resolved
        resolved_commands+=($subcommand)
    done

    local subcommand=${${(Q)${(z)arguments}}[2]}
    local last_argument=${${(Q)${(z)arguments}}[-1]}

    if [[ $subcommand =~ '(diff|log|rebase|reset|switch)' ]]; then
        if [[ ${${(Q)${(z)arguments}}[(r)--]} = -- ]]; then
            if [[ $subcommand =~ 'diff' ]]; then
                _fzf_complete_git-status-files 'unstaged' '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
                return
            fi

            if [[ $subcommand =~ '(log|reset)' ]]; then
                _fzf_complete_git-ls-tree '' '--multi' $@
                return
            fi
        fi

        _fzf_complete_git-commits '' $@
        return
    fi

    if [[ $subcommand =~ '(branch|merge|revert)' ]]; then
        _fzf_complete_git-commits '--multi' $@
        return
    fi

    if [[ $subcommand = 'checkout' ]]; then
        local prefix_option completing_option
        local git_options_argument_required=(-b -B --orphan --conflict --pathspec-from-file)
        local git_options_argument_optional=()

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)git_options_argument_required}" "${(F)git_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        case $completing_option in
            -b|-B)
                return
                ;;

            --conflict)
                return
                ;;

            --pathspec-from-file)
                return
                ;;

            *)
                local treeish
                if treeish=$(_fzf_complete_git_parse_argument 1 "${arguments%% -- *}" "${(F)git_options_argument_required}") || [[ -n $treeish ]]; then
                    _fzf_complete_git-ls-tree '' '--multi' $@
                    return
                fi

                if [[ -z ${${(Q)${(z)arguments}}[(r)--]} ]]; then
                    _fzf_complete_git-commits '' $@
                    return
                fi

                _fzf_complete_git-status-files 'unstaged' '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
                return
                ;;
        esac

        return
    fi

    if [[ $subcommand = 'cherry-pick' ]]; then
        local prefix_option completing_option
        local git_options_argument_required=(--cleanup --strategy --strategy-option --strategy-option=diff-algorithm -X)
        local git_options_argument_optional=(--gpg-sign -S)

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)git_options_argument_required}" "${(F)git_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        case $completing_option in
            --cleanup)
                local cleanup_modes=(strip whitespace verbatim scissors default)
                _fzf_complete_constants '' "${(F)cleanup_modes}" $@
                ;;

            --gpg-sign|-S)
                ;;

            --strategy)
                local strategies=(octopus ours subtree recursive resolve)
                _fzf_complete_constants '' "${(F)strategies}" $@
                ;;

            --strategy-option|--strategy-option=diff-algorithm|-X)
                local strategy_options=(
                    diff-algorithm=histogram
                    diff-algorithm=minimal
                    diff-algorithm=myers
                    diff-algorithm=patience
                    find-renames
                    find-renames=
                    ignore-all-space
                    ignore-cr-at-eol
                    ignore-space-at-eol
                    ignore-space-change
                    no-renames
                    no-renormalize
                    ours
                    patience
                    rename-threshold=
                    renormalize
                    subtree
                    subtree=
                    theirs
                )
                prefix_option=${prefix_option/=*/=} prefix=${prefix#$prefix_option} _fzf_complete_constants '' "${(F)strategy_options}" $@
                ;;

            *)
                _fzf_complete_git-commits-not-in-head '--multi' $@
                ;;
        esac

        return
    fi

    if [[ $subcommand = 'restore' ]]; then
        local prefix_option completing_option
        local git_options_argument_required=(--source -s)
        local git_options_argument_optional=()

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)git_options_argument_required}" "${(F)git_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        case $completing_option in
            -s|--source)
                _fzf_complete_git-commits '' $@
                ;;

            *)
                if [[ -n ${${(Q)${(z)arguments}}[(r)--source(|(=*))]} ]] || [[ -n ${${(Q)${(z)arguments}}[(r)-[^-]#s*]} ]]; then
                    _fzf_complete_git-ls-tree '' '--multi' $@
                    return
                fi

                if [[ -n ${${(Q)${(z)arguments}}[(r)--staged]} ]] || [[ -n ${${(Q)${(z)arguments}}[(r)-[^-]#S[[:alpha:]]#]} ]]; then
                    _fzf_complete_git-status-files 'staged' '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff_cached $FZF_DEFAULT_OPTS" $@
                    return
                fi

                _fzf_complete_git-status-files 'unstaged' '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
                ;;
        esac

        return
    fi

    if [[ $subcommand = 'commit' ]]; then
        if [[ -n ${${(Q)${(z)arguments}}[(r)--]} ]] || [[ $last_argument != -* && $prefix != -* ]]; then
            _fzf_complete_git-status-files 'unstaged' '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
            return
        fi

        local prefix_option completing_option
        local git_options_argument_required=(-c -C --fixup --reedit-message --reuse-message --squash -m --message --author --date -F -t --file --pathspec-from-file --template --cleanup)
        local git_options_argument_optional=(-u --untracked-files)

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)git_options_argument_required}" "${(F)git_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        case $completing_option in
            -c|-C|--fixup|--reedit-message|--reuse-message|--squash)
                _fzf_complete_git-commits '' $@
                ;;

            -m|--message)
                _fzf_complete_git-commit-messages '' $@
                ;;

            --author|--date)
                ;;

            -F|-t|--file|--pathspec-from-file|--template)
                __fzf_generic_path_completion "${prefix#$prefix_option}" $@$prefix_option _fzf_compgen_path '' '' ' '
                ;;

            --cleanup)
                local cleanup_modes=(strip whitespace verbatim scissors default)
                _fzf_complete_constants '' "${(F)cleanup_modes}" $@
                ;;

            -u|--untracked-files)
                local untracked_file_modes=(no normal all)
                _fzf_complete_constants '' "${(F)untracked_file_modes}" $@
                ;;

            *)
                _fzf_complete_git-status-files 'unstaged' '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
                ;;
        esac

        return
    fi

    if [[ $subcommand = 'add' ]]; then
        _fzf_complete_git-status-files 'unstaged' '--untracked-files=all' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
        return
    fi

    if [[ $subcommand = 'fetch' ]]; then
        local prefix_option completing_option
        local git_options_argument_required=(--depth --deepen -j --jobs --negotiation-tip -o --recurse-submodules-default --refmap --server-option --shallow-exclude --shallow-since --submodule-prefix --upload-pack)
        local git_options_argument_optional=(--recurse-submodules -S)

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)git_options_argument_required}" "${(F)git_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        case $completing_option in
            --recurse-submodules)
                local recurse_submodules=(yes on-demand no)
                _fzf_complete_constants '' "${(F)recurse_submodules}" $@
                ;;

            --recurse-submodules-default)
                local recurse_submodules_default=(yes on-demand)
                _fzf_complete_constants '' "${(F)recurse_submodules_default}" $@
                ;;

            --refmap)
                _fzf_complete_git-refs '' $@
                ;;

            --shallow-exclude)
                _fzf_complete_git-commits '' $@
                ;;

            --negotiation-tip)
                _fzf_complete_git-commits '' $@
                ;;

            --depth|--deepen|-j|--jobs|-o|--server-option|--shallow-since|--submodule-prefix|--upload-pack)
                ;;

            *)
                local repository
                if [[ $@ =~ '--multiple' ]] || ! repository=$(_fzf_complete_git_parse_argument 1 "$arguments" "${(F)git_options_argument_required}") && [[ -z $repository ]]; then
                    _fzf_complete_git-repositories '--multi' $@
                    return
                fi

                _fzf_complete_git-refs '--multi' $@
                ;;
        esac

        return
    fi

    if [[ $subcommand = 'pull' ]]; then
        local prefix_option completing_option
        local git_options_argument_required=(--cleanup --date --depth --deepen --negotiation-tip -o -s --server-option --shallow-exclude --shallow-since --strategy --strategy-option --strategy-option=diff-algorithm --upload-pack -X)
        local git_options_argument_optional=(--gpg-sign --log --rebase --recurse-submodules -S)

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)git_options_argument_required}" "${(F)git_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        case $completing_option in
            --recurse-submodules)
                local recurse_submodules=(yes on-demand no)
                _fzf_complete_constants '' "${(F)recurse_submodules}" $@
                ;;

            --cleanup)
                local cleanup_modes=(strip whitespace verbatim scissors default)
                _fzf_complete_constants '' "${(F)cleanup_modes}" $@
                ;;

            -s|--strategy)
                local strategies=(octopus ours subtree recursive resolve)
                _fzf_complete_constants '' "${(F)strategies}" $@
                ;;

            --strategy-option|--strategy-option=diff-algorithm|-X)
                local strategy_options=(
                    diff-algorithm=histogram
                    diff-algorithm=minimal
                    diff-algorithm=myers
                    diff-algorithm=patience
                    find-renames
                    find-renames=
                    ignore-all-space
                    ignore-cr-at-eol
                    ignore-space-at-eol
                    ignore-space-change
                    no-renames
                    no-renormalize
                    ours
                    patience
                    rename-threshold=
                    renormalize
                    subtree
                    subtree=
                    theirs
                )
                prefix_option=${prefix_option/=*/=} prefix=${prefix#$prefix_option} _fzf_complete_constants '' "${(F)strategy_options}" $@
                ;;

            --rebase)
                local rebases=(false interactive merges preserve true)
                _fzf_complete_constants '' "${(F)rebases}" $@
                ;;

            --shallow-exclude)
                _fzf_complete_git-commits '' $@
                ;;

            --negotiation-tip)
                _fzf_complete_git-commits '' $@
                ;;

            --gpg-sign|-S)
                ;;

            --date|--depth|--deepen|--log|--server-option|--shallow-since|--upload-pack|-o)
                ;;

            *)
                local repository
                if ! repository=$(_fzf_complete_git_parse_argument 1 "$arguments" "${(F)git_options_argument_required}") && [[ -z $repository ]]; then
                    _fzf_complete_git-repositories '' $@
                    return
                fi

                _fzf_complete_git-refs '--multi' $@
                ;;
        esac

        return
    fi

    if [[ $subcommand = 'push' ]]; then
        local prefix_option completing_option
        local git_options_argument_required=(--exec -o --push-option --receive-pack --recurse-submodules --repo)
        local git_options_argument_optional=(--force-with-lease --signed)

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)git_options_argument_required}" "${(F)git_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        local prefix_ref=${prefix%%[^:]#}

        case $completing_option in
            --signed)
                local signed=(false if-asked true)
                _fzf_complete_constants '' "${(F)signed}" $@
                ;;

            -o|--push-option)
                ;;

            --exec|--receive-pack)
                ;;

            --force-with-lease)
                prefix=${prefix#*:} _fzf_complete_git-commits '' $@
                ;;

            --repo)
                _fzf_complete_git-repositories '' $@
                ;;

            --recurse-submodules)
                local recurse_submodules=(check no on-demand only)
                _fzf_complete_constants '' "${(F)recurse_submodules}" $@
                ;;

            *)
                local repository
                if ! repository=$(_fzf_complete_git_parse_argument 1 "$arguments" "${(F)git_options_argument_required}") && [[ -z $repository ]]; then
                    _fzf_complete_git-repositories '' $@
                    return
                fi

                if [[ $prefix = *:* ]]; then
                    prefix=${prefix#*:} _fzf_complete_git-refs '' $@
                    return
                fi

                _fzf_complete_git-commits '--multi' $@
                ;;
        esac

        return
    fi

    if [[ $subcommand = 'rm' ]]; then
        _fzf_complete_git-ls-tree '' '--multi' $@
        return
    fi

    if [[ $subcommand = 'show' ]]; then
        local prefix_option completing_option
        local git_options_argument_required=(
            -l
            -G
            -O
            -S
            -U
            --anchored
            --color-moved-ws
            --diff-algorithm
            --diff-filter
            --dst-prefix
            --encoding
            --expand-tabs
            --find-object
            --format
            --inter-hunk-context
            --line-prefix
            --output
            --output-indicator-context
            --output-indicator-new
            --output-indicator-old
            --src-prefix
            --unified
            --word-diff-regex
            --ws-error-highlight
        )
        local git_options_argument_optional=(
            -B
            -C
            -M
            -X
            --abbrev
            --break-rewrites
            --color
            --color-moved
            --dirstat
            --find-copies
            --find-renames
            --ignore-submodules
            --notes
            --pretty
            --relative
            --show-notes
            --stat
            --submodule
            --word-diff
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)git_options_argument_required}" "${(F)git_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        local prefix_ref=${prefix%%[^:]#}

        case $completing_option in
            --abbrev|--anchored|--break-rewrites|--dst-prefix|--encoding|--expand-tabs|--find-copies|--find-object|--find-renames|--format|--inter-hunk-context|--line-prefix|--output|--output-indicator-context|--output-indicator-new|--output-indicator-old|--src-prefix|--stat|--submodule|--unified|--word-diff-regex)
                return
                ;;

            --notes|--show-notes)
                _fzf_complete_git-notes '' $@
                return
                ;;

            --diff-algorithm)
                return
                ;;

            --dirstat|-X)
                return
                ;;

            --color)
                return
                ;;

            --color-moved)
                return
                ;;

            --color-moved-ws)
                return
                ;;

            --word-diff)
                return
                ;;

            --ws-error-highlight)
                return
                ;;

            --diff-filter)
                return
                ;;

            -O)
                return
                ;;

            --relative)
                return
                ;;

            --ignore-submodules)
                return
                ;;

            *)
                local treeish

                if [[ $prefix = *:* ]]; then
                    treeish=${prefix%:*}
                    prefix=${prefix#*:} _fzf_complete_git-ls-tree '' '' $@
                    return
                fi

                if [[ -n ${(Q)${(Z+n+)arguments}[(r)--]} ]]; then
                    local args=($(_fzf_complete_git_parse_argument 0 "${arguments%% -- *}" "${(F)git_options_argument_required}"))
                    treeish=${args:#*:*}
                    _fzf_complete_git-show-files '--multi' $@
                    return
                fi

                _fzf_complete_git-commits '--multi' $@
                return
                ;;
        esac

        return
    fi

    _fzf_path_completion "$prefix" $@
}

_fzf_complete_git-commits() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option$prefix_ref < <({
        git for-each-ref refs/heads refs/remotes --format='%(refname:short) branch %(contents:subject)' 2> /dev/null
        git for-each-ref refs/tags --format='%(refname:short) tag %(contents:subject)' --sort=-version:refname 2> /dev/null
        git log --format='%h commit %s' 2> /dev/null
    } | _fzf_complete_tabularize ${fg[yellow]} ${fg[green]})
}

_fzf_complete_git-commits_post() {
    local input=$(awk '{ print $1 }')

    if [[ -z $input ]]; then
        return
    fi

    if [[ $subcommand = 'push' ]] && [[ -z $prefix_ref ]]; then
        echo -n $input
        return
    fi

    echo $input
}

_fzf_complete_git-commits-not-in-head() {
    local fzf_options=$1
    shift

    local rev_list_all=$(git rev-list --all --oneline 2> /dev/null)
    rev_list_all=(${(q)${(f)rev_list_all}})
    local rev_list_head=$(git rev-list HEAD --oneline 2> /dev/null)
    rev_list_head=(${(q)${(f)rev_list_head}})

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option$prefix_ref < <(
        _fzf_complete_tabularize ${fg[yellow]} <<< ${(Q)${(F)rev_list_all:|rev_list_head}}
    )
}

_fzf_complete_git-commits-not-in-head_post() {
    awk '{ print $1 }'
}

_fzf_complete_git-commit-messages() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        git log --format='%h %s' 2> /dev/null | _fzf_complete_tabularize ${fg[yellow]}
    )
}

_fzf_complete_git-commit-messages_post() {
    local message=$(awk '
        {
            sub(/[^ ]*  /, "")
            print
        }
    ')
    if [[ -z $message ]]; then
        return
    fi

    echo ${(qq)message}
}

_fzf_complete_git-ls-tree() {
    local git_options=$1
    local fzf_options=$2
    shift 2

    _fzf_complete --ansi --read0 --print0 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_ref < <(git ls-tree --name-only -r -z ${(Z+n+)git_options} ${treeish-HEAD} 2> /dev/null)
}

_fzf_complete_git-ls-tree_post() {
    local filename
    local input=$(cat)

    for filename in ${(0)input}; do
        echo ${${(q+)filename}//\\n/\\\\n}
    done
}

_fzf_complete_git-status-files() {
    local state=$1
    local git_options=$2
    local fzf_options=$3
    shift 3

    _fzf_complete --ansi --read0 --print0 ${(Q)${(Z+n+)fzf_options}} -- $@ < <({
        local previous_status
        local filename
        local files=$(git status --porcelain=v1 -z ${(Z+n+)git_options} 2> /dev/null)
        local cdup=$(git rev-parse --show-cdup 2> /dev/null)

        for filename in ${(0)files}; do
            if [[ $previous_status != 'R' ]]; then
                awk \
                    -v RS='' \
                    -v state=$state \
                    -v cdup=$cdup \
                    -v green=${fg[green]} \
                    -v red=${fg[red]} \
                    -v reset=$reset_color '
                        '$_fzf_complete_awk_functions'
                        state == "staged" ? /^[^ ]/ : /^.[^ ]/ {
                            printf "%s%c", colorize_git_status($0, cdup, green, red, reset), 0
                        }
                    ' <<< $filename
            fi

            previous_status=${filename:0:1}
        done
    })
}

_fzf_complete_git-status-files_post() {
    local filename
    local input=$(cat)

    for filename in ${(0)input}; do
        echo ${${(q+)filename:3}//\\n/\\\\n}
    done
}

_fzf_complete_git-repositories() {
    local fzf_options=$1
    shift

    if [[ $subcommand = 'fetch' ]]; then
        local groups=$(git config --get-regexp '^remotes\.' 2> /dev/null)
        groups=${(Q)${(F)${${(q)${(f)groups}}#remotes.}}}
    fi

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <({
        git remote --verbose 2> /dev/null | awk '
            /\(fetch\)$/ {
                gsub(/\t/, " ")
                print
            }
        '
        echo -n $groups
    } | _fzf_complete_tabularize ${fg[yellow]})
}

_fzf_complete_git-repositories_post() {
    awk '{ print $1 }'
}

_fzf_complete_git-refs() {
    local fzf_options=$1
    shift

    local ref=${${$(git config remote.$repository.fetch 2> /dev/null)#*:}%\*}

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option$prefix_ref < <(
        git for-each-ref "$ref" --format='%(refname:short) %(contents:subject)' 2> /dev/null |
            _fzf_complete_tabularize ${fg[yellow]}
    )
}

_fzf_complete_git-refs_post() {
    local ref
    local input=$(cat)

    if [[ -z $input ]]; then
        return
    fi

    for ref in ${(f)input}; do
        echo ${${ref#*/}%% *}
    done
}

_fzf_complete_git-notes() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option$prefix_ref < <(
        git for-each-ref refs/notes --format='%(refname:short) %(contents:subject)' 2> /dev/null |
            _fzf_complete_tabularize ${fg[yellow]}
    )
}

_fzf_complete_git-notes_post() {
    awk '{ print $1 }'
}

_fzf_complete_git-show-files() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --read0 --print0 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        local result=$(git show --pretty=format: --name-only -z ${(ps: :)treeish} 2> /dev/null)
        echo -n ${(pj:\0:)${(u)${(o)${(0)result}}}}
    )
}

_fzf_complete_git-show-files_post() {
    local filename
    local input=$(cat)

    for filename in ${(0)input}; do
        echo ${${(q+)filename}//\\n/\\\\n}
    done
}

_fzf_complete_git_resolve_alias() {
    local git_alias git_alias_resolved
    local git_aliases=$(git config --get-regexp '^alias\.' 2> /dev/null)

    for git_alias in ${(f)git_aliases}; do
        if [[ ${${git_alias#alias.}%% *} = $2 ]]; then
            git_alias_resolved="$1 ${git_alias#* } ${@:3}"
        fi
    done

    echo $git_alias_resolved
}

_fzf_complete_git_parse_argument() {
    local arguments=(${(z)2})

    if (( ${#arguments} <= 2 )); then
        return 1
    fi

    _fzf_complete_parse_argument 3 $@
}
