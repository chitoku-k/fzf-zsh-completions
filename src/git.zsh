#!/usr/bin/env zsh

_fzf_complete_awk_functions='
    function colorize_git_status(input, color1, color2, reset) {
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

        return sprintf("%s%s%s%s%s%s %s", index_status_color, index_status, reset, work_tree_status_color, work_tree_status, reset, substr(input, 4))
    }

    function trim_prefix(str, prefix) {
        match(str, prefix)
        return substr(str, RSTART + RLENGTH)
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

_fzf_complete_git() {
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

    if [[ $subcommand =~ '(checkout|log|rebase|reset)' ]]; then
        if [[ ${${(Q)${(z)arguments}}[(r)--]} = -- ]]; then
            if [[ $subcommand = 'checkout' ]]; then
                _fzf_complete_git-unstaged-files '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
                return
            fi

            if [[ $subcommand =~ '(log|reset)' ]]; then
                _fzf_complete_git-ls-files '' '--multi' $@
                return
            fi
        fi

        _fzf_complete_git-commits '' $@
        return
    fi

    if [[ $subcommand =~ '(branch|cherry-pick|merge|revert)' ]]; then
        _fzf_complete_git-commits '--multi' $@
        return
    fi

    if [[ $subcommand = 'commit' ]]; then
        if [[ -n ${${(Q)${(z)arguments}}[(r)--]} ]] || [[ $last_argument != -* && $prefix != -* ]]; then
            _fzf_complete_git-unstaged-files '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
            return
        fi

        local prefix_option completing_option
        local git_options_argument_required=(-c -C --fixup --reedit-message --reuse-message --squash -m --message --author --date -F -t --file --pathspec-from-file --template --cleanup)
        local git_options_argument_optional=(-u --untracked-files)

        if completing_option=$(_fzf_complete_git_parse_completing_option "$prefix" "$last_argument" ${(F)git_options_argument_required} ${(F)git_options_argument_optional}); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
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
                _fzf_complete_git_git_constants '' "${(F)cleanup_modes}" $@
                ;;

            -u|--untracked-files)
                local untracked_file_modes=(no normal all)
                _fzf_complete_git_git_constants '' "${(F)untracked_file_modes}" $@
                ;;

            *)
                _fzf_complete_git-unstaged-files '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
                ;;
        esac

        return
    fi

    if [[ $subcommand = 'add' ]]; then
        _fzf_complete_git-unstaged-files '--untracked-files=all' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
        return
    fi

    if [[ $subcommand = 'pull' ]]; then
        local prefix_option completing_option

        local git_options_argument_required=(--cleanup --date --depth --deepen --negotiation-tip -o -s --server-option --shallow-exclude --shallow-since --strategy --strategy-option --strategy-option=diff-algorithm --upload-pack -X)
        local git_options_argument_optional=(--gpg-sign --log --rebase --recurse-submodules -S)

        if completing_option=$(_fzf_complete_git_parse_completing_option "$prefix" "$last_argument" ${(F)git_options_argument_required} ${(F)git_options_argument_optional}); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
        fi

        case $completing_option in
            --recurse-submodules)
                local recurse_submodules=(yes on-demand no)
                _fzf_complete_git_git_constants '' "${(F)recurse_submodules}" $@
                ;;

            --cleanup)
                local cleanup_modes=(strip whitespace verbatim scissors default)
                _fzf_complete_git_git_constants '' "${(F)cleanup_modes}" $@
                ;;

            -s|--strategy)
                local strategies=(octopus ours subtree recursive resolve)
                _fzf_complete_git_git_constants '' "${(F)strategies}" $@
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
                prefix_option=${prefix_option/=*/=} _fzf_complete_git_git_constants '' "${(F)strategy_options}" $@
                ;;

            --rebase)
                local rebases=(false interactive merges preserve true)
                _fzf_complete_git_git_constants '' "${(F)rebases}" $@
                ;;

            --shallow-exclude)
                _fzf_complete_git-commits '' $@
                ;;

            --negotiation-tip)
                local negotiation_tips=(commit glob)
                _fzf_complete_git_git_constants '' "${(F)negotiation_tips}" $@
                ;;

            --gpg-sign|-S)
                ;;

            --date|--depth|--deepen|--log|--server-option|--shallow-since|--upload-pack|-o)
                ;;

            *)
                local repository=$(_fzf_complete_git_parse_argument "$arguments" 1 "${(F)git_options_argument_required}")

                if [[ -z $repository ]]; then
                    _fzf_complete_git-remotes '' $@
                    return
                fi

                repository=$repository _fzf_complete_git-refs '--multi' $@
                ;;
        esac

        return
    fi

    _fzf_path_completion "$prefix" $@
}

_fzf_complete_git-commits() {
    local fzf_options=$1
    shift

    _fzf_complete "--ansi --tiebreak=index $fzf_options" $@ < <({
        git for-each-ref refs/heads refs/remotes refs/tags --format='%(refname:short) %(contents:subject)' 2> /dev/null
        git log --format='%h %s' 2> /dev/null
    } | awk -v prefix=$prefix_option '{ print prefix $0 }' | _fzf_complete_git_tabularize)
}

_fzf_complete_git-commits_post() {
    awk '{ print $1 }'
}

_fzf_complete_git-commit-messages() {
    local fzf_options=$1
    shift

    _fzf_complete "--ansi --tiebreak=index $fzf_options" $@ < <(
        git log --format='%h %s' 2> /dev/null |
        awk -v prefix=$prefix_option '
            {
                match($0, / /)
                print $1, prefix substr($0, RSTART + RLENGTH)
            }
        ' | _fzf_complete_git_tabularize
    )
}

_fzf_complete_git-commit-messages_post() {
    local message=$(awk -v prefix=$prefix_option '
        '$_fzf_complete_awk_functions'
        {
            match($0, /  /)
            str = substr($0, RSTART + RLENGTH)
            print trim_prefix(str, prefix)
        }
    ')
    if [[ -z $message ]]; then
        return
    fi

    echo $prefix_option${(qq)message}
}

_fzf_complete_git-ls-files() {
    local git_options=$1
    local fzf_options=$2
    shift 2

    _fzf_complete "--ansi --read0 --print0 $fzf_options" $@ < <(git ls-files -z ${(Z+n+)git_options} 2> /dev/null)
}

_fzf_complete_git-ls-files_post() {
    local filename
    local input=$(cat)

    for filename in ${(0)input}; do
        echo ${${(q+)filename}//\\n/\\\\n}
    done
}

_fzf_complete_git-unstaged-files() {
    local git_options=$1
    local fzf_options=$2
    shift 2

    _fzf_complete "--ansi --read0 --print0 $fzf_options" $@ < <({
        local previous_status
        local filename
        local files=$(git status --porcelain=v1 -z ${(Z+n+)git_options} 2> /dev/null)

        for filename in ${(0)files}; do
            if [[ $previous_status != R ]]; then
                awk \
                    -v RS='' \
                    -v green=$(tput setaf 2) \
                    -v red=$(tput setaf 1) \
                    -v reset=$(tput sgr0) '
                            '$_fzf_complete_awk_functions'
                            /^.[^ ]/ {
                            printf "%s%c", colorize_git_status($0, green, red, reset), 0
                        }
                    ' <<< $filename
            fi

            previous_status=${filename:0:1}
        done
    })
}

_fzf_complete_git-unstaged-files_post() {
    local filename
    local input=$(cat)

    for filename in ${(0)input}; do
        echo ${${(q+)filename:3}//\\n/\\\\n}
    done
}

_fzf_complete_git-remotes() {
    local fzf_options=$1
    shift

    _fzf_complete "--ansi --tiebreak=index $fzf_options" $@ < <(git remote --verbose 2> /dev/null | awk '
        /\(fetch\)$/ {
            gsub("\t", " ")
            print
        }
    ' | _fzf_complete_git_tabularize)
}

_fzf_complete_git-remotes_post() {
    awk '{ print $1 }'
}

_fzf_complete_git-refs() {
    local fzf_options=$1
    shift

    local ref=${${$(git config remote.$repository.fetch 2> /dev/null)#*:}%\*}

    [[ -z $ref ]] && return

    _fzf_complete "--ansi --tiebreak=index $fzf_options" $@ < <(
        git for-each-ref $ref --format='%(refname:short) %(contents:subject)' 2> /dev/null |
        awk -v prefix=$prefix_option '{ print prefix $0 }' | _fzf_complete_git_tabularize
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

_fzf_complete_git_git_constants() {
    local fzf_options=$1
    local values=$2
    shift 2

    _fzf_complete "--ansi --tiebreak=index $fzf_options" $@ < <(awk -v prefix=$prefix_option '{ print prefix $0 }' <<< $values)
}

_fzf_complete_git_git_constants_post() {
    local input=$(cat)

    if [[ -z $input ]]; then
        return
    fi

    if [[ $input = *= ]]; then
        echo -n $input
    else
        echo $input
    fi
}

_fzf_complete_git_resolve_alias() {
    local git_alias git_alias_resolved
    local git_aliases=$(git config --get-regexp '^alias\.')

    for git_alias in ${(f)git_aliases}; do
        if [[ ${${git_alias#alias.}%% *} = $2 ]]; then
            git_alias_resolved="$1 ${git_alias#* } ${@:3}"
        fi
    done

    echo $git_alias_resolved
}

_fzf_complete_git_parse_completing_option() {
    local prefix=$1
    local last_argument=$2
    local options_argument_required=(${(z)3})
    local options_argument_optional=(${(z)4})
    shift 4

    local current=$prefix
    local completing_option
    local completing_option_source

    while [[ -n $current ]]; do
        case $current in
            -[A-Za-z]*)
                if [[ -n ${options_argument_required[(r)${current:0:2}]} ]] || [[ -n ${options_argument_optional[(r)${current:0:2}]} ]]; then
                    completing_option=${current:0:2}
                    completing_option_source=prefix
                    break
                fi
                ;;

            --*)
                if [[ -n ${options_argument_required[(r)${current%=*}]} ]] || [[ -n ${options_argument_optional[(r)${current%=*}]} ]]; then
                    completing_option=${current%=*}
                    completing_option_source=prefix
                    break
                fi
                ;;
        esac

        if [[ $current != -[A-Za-z][A-Za-z]* ]]; then
            break
        fi

        current=${current/-[A-Za-z]/-}
    done

    current=$last_argument

    while [[ -n $current ]]; do
        if [[ -n ${options_argument_required[(r)$current]} ]]; then
            completing_option=$current
            completing_option_source=last_argument
            break
        fi

        if [[ $current != -[A-Za-z][A-Za-z]* ]]; then
            break
        fi

        current=${current/-[A-Za-z]/-}
    done

    echo $completing_option
    case $completing_option_source in
        prefix)
            return 0
            ;;

        last_argument)
            return 1
            ;;

        *)
            return 2
            ;;
    esac
}

_fzf_complete_git_parse_argument() {
    local arguments=(${(z)1})
    local index=$2
    local options_argument_required=(${(z)3})

    local argument_position=${arguments[(ib:3:)[^-]*]}
    local command_arguments=()
    while (( argument_position <= ${#arguments} )); do
        local argument=${${arguments[$(( argument_position - 1 ))]}##-##}
        if [[ -z ${${options_argument_required##-##}[(r)$argument]} ]] || [[ ${${options_argument_required##-##}[(r)$argument]} != $argument ]]; then
            command_arguments+=${arguments[$argument_position]}
        fi
        argument_position=${arguments[(ib:(( argument_position + 1 )):)[^-]*]}
    done

    echo ${command_arguments[$index]}
}

_fzf_complete_git_tabularize() {
    awk \
        -v yellow=$(tput setaf 3) \
        -v reset=$(tput sgr0) '
        {
            refnames[NR] = $1

            if (length($1) > refname_max) {
                refname_max = length($1)
            }

            match($0, / /)
            messages[NR] = substr($0, RSTART + RLENGTH)
        }
        END {
            for (i = 1; i <= length(refnames); ++i) {
                printf "%s%-" refname_max "s %s %s\n", yellow, refnames[i], reset, messages[i]
            }
        }
    '
}
