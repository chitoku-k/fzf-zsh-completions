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
    local arguments_num=${#${(z)arguments}}

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
    local cleanup_modes=(strip whitespace verbatim scissors default)
    local untracked_file_modes=(no normal all)
    local recurse_submodules=(yes on-demand no)
    local strategies=(octopus ours subtree recursive resolve)
    local strategy_options=(
        diff-algorithm
        find-rename
        histogram
        ignore-all-space
        ignore-space-at-eol
        ignore-space-change
        no-renames
        no-renormalize
        ours
        patience
        rename-threshold
        renormalize
        subtree
        theirs
    )
    local rebases=(false interactive merges preserve true)
    local negotiation_tips=(commit glob)

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
        if [[ ${${(Q)${(z)arguments}}[(r)--]} = -- ]]; then
            _fzf_complete_git-unstaged-files '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
            return
        fi

        local git_options_commit_completion=(c C fixup reedit-message reuse-message squash)
        if _fzf_complete_git_has_options "$last_argument" "$prefix" $git_options_commit_completion; then
            prefix_option=$(_fzf_complete_git_option_prefix) _fzf_complete_git-commits '' $@
            return
        fi

        local git_options_commit_message_completion=(m message)
        if _fzf_complete_git_has_options "$last_argument" "$prefix" $git_options_commit_message_completion; then
            prefix_option=$(_fzf_complete_git_option_prefix) _fzf_complete_git-commit-messages '' $@
            return
        fi

        local git_options_nothing_completion=(author date)
        if _fzf_complete_git_has_options "$last_argument" "$prefix" $git_options_nothing_completion; then
            return
        fi

        local git_options_file_completion=(F t file pathspec-from-file template)
        if _fzf_complete_git_has_options "$last_argument" "$prefix" $git_options_file_completion; then
            _fzf_path_completion "${prefix/--*=}" $@$(_fzf_complete_git_option_prefix)
            return
        fi

        local git_options_cleanup_mode_completion=(cleanup)
        if _fzf_complete_git_has_options "$last_argument" "$prefix" $git_options_cleanup_mode_completion; then
            _fzf_complete_git_specific_values '' "${(F)cleanup_modes}" $@
            return
        fi

        local git_options_untracked_files_mode_completion=(u untracked-files)
        if _fzf_complete_git_has_options "$last_argument" "$prefix" $git_options_untracked_files_mode_completion; then
            _fzf_complete_git_specific_values '' "${(F)untracked_file_modes}" $@
            return
        fi

        _fzf_complete_git-unstaged-files '--untracked-files=no' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
        return
    fi

    if [[ $subcommand = 'add' ]]; then
        _fzf_complete_git-unstaged-files '--untracked-files=all' "--multi $_fzf_complete_preview_git_diff $FZF_DEFAULT_OPTS" $@
        return
    fi

    if [[ $subcommand = 'pull' ]]; then
        local git_options_recurse_submodules_completion=(recurse-submodules)
        if _fzf_complete_git_has_options $last_argument "$prefix" $git_options_recurse_submodules_completion; then
            _fzf_complete_git_specific_values '' "${(F)recurse_submodules}" $@
            return
        fi

        local git_options_cleanup_mode_completion=(cleanup)
        if _fzf_complete_git_has_options $last_argument "$prefix" $git_options_cleanup_mode_completion; then
            _fzf_complete_git_specific_values '' "${(F)cleanup_mode}" $@
            return
        fi

        local git_options_strategy_completion=(s strategy)
        if _fzf_complete_git_has_options $last_argument "$prefix" $git_options_strategy_completion; then
            _fzf_complete_git_specific_values '' "${(F)strategies}" $@
            return
        fi

        # TODO: Some options also take a value😭
        local git_options_strategy_option_completion=(X strategy-option)
        if _fzf_complete_git_has_options $last_argument "$prefix" $git_options_strategy_option_completion; then
            _fzf_complete_git_specific_values '' "${(F)strategy_options}" $@
            return
        fi

        local git_options_rebase_completion=(rebase)
        if _fzf_complete_git_has_options $last_argument "$prefix" $git_options_rebase_completion; then
            _fzf_complete_git_specific_values '' "${(F)rebases}" $@
            return
        fi

        local git_options_revision_completion=(shallow-exclude)
        if _fzf_complete_git_has_options $last_argument "$prefix" $git_options_revision_completion; then
            prefix_option=$(_fzf_complete_git_option_prefix) _fzf_complete_git-commits '' $@
            return
        fi

        local git_options_negotiation_tip_completion=(negotiation-tip)
        if _fzf_complete_git_has_options $last_argument "$prefix" $git_options_negotiation_tip_completion; then
            _fzf_complete_git_specific_values '' "${(F)negotiation_tips}" $@
            return
        fi

        # local git_options_gpg_sign_completion=(S gpg-sign)
        # if _fzf_complete_git_has_options $last_argument "$prefix" $git_options_nothing_completion; then
        #     prefix_option=$(_fzf_complete_git_option_prefix) _fzf_complete_git-gpg-key '' $@
        #     return
        # fi

        local git_options_nothing_completion=(o date depth depthn log server-option shallow-since upload-pack)
        if _fzf_complete_git_has_options $last_argument "$prefix" $git_options_nothing_completion; then
            return
        fi

        local git_all_options_with_value=${${$(typeset -m 'git_options_*_completion')#*\(}%)}
        local n=${${(z)arguments}[(ib:3:)[^-]*]}
        local floating_arguments_number=0
        local repository
        while (( n <= ${#${(z)arguments}} )); do
            com=${${arguments[(w)$(( n - 1 ))]}##-##}
            if [[ ${git_all_options_with_value[(wr)$com]} != $com ]]; then
                (( floating_arguments_number++ ))
                if [[ $floating_arguments_number == 1 ]]; then
                    repository=${arguments[(w)$n]}
                fi
            fi
            n=${${(z)arguments}[(ib:(( n + 1 )):)[^-]*]}
        done

        if [[ $floating_arguments_number = 0 ]]; then
            _fzf_complete_git-remotes '' $@
            return
        fi

        if [[ $floating_arguments_number = 1 ]]; then
            repository=$repository _fzf_complete_git-refs '' $@
            return
        fi

        return
    fi

    _fzf_path_completion "$prefix" $@
}

_fzf_complete_git_option_prefix() {
    if [[ -z ${prefix:/--[^-]##*=*} ]]; then
        echo ${prefix/=*/=}
    fi
}
_fzf_complete_git_has_options() {
    local option
    local last_argument=$1
    local prefix=$2
    shift 2

    for option in ${(z)@}; do
        if [[ ${#option} = 1 ]]; then
            if [[ $last_argument =~ "^-[^-]*$option" ]]; then
                return 0
            fi
        else
            if [[ $last_argument = "--$option" ]]; then
                return 0
            fi

            if [[ $prefix =~ "^--$option=" ]]; then
                return 0
            fi
        fi
    done

    return 1
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
    local fzf_options="$1"
    shift

    _fzf_complete "--ansi $fzf_options" $@ < <(git remote --verbose | awk '
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

    local ref=${${$(git config remote.origin.fetch 2> /dev/null)#*:}%\*}

    _fzf_complete "--ansi --tiebreak=index $fzf_options" $@ < <(
        git for-each-ref $ref --format='%(refname:short) %(contents:subject)' 2> /dev/null |
        awk -v prefix=$prefix_option '{ print prefix $0 }' | _fzf_complete_git_tabularize
    )
}

_fzf_complete_git-refs_post() {
    input=$(cat)

    if [[ -z $input ]]; then
        return
    fi

    echo ${${input#*/}%% *}
}

_fzf_complete_git_specific_values() {
    local fzf_options=$1
    local values=$2
    shift 2

    _fzf_complete "$fzf_options" $@ < <(awk -v prefix=$(_fzf_complete_git_option_prefix) '{ print prefix $0 }' <<< ${values})
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
