#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_gh() {
    setopt local_options no_aliases
    local command_pos=$(_fzf_complete_get_command_pos "$@")
    local arguments=("${(Q)${(z)"$(_fzf_complete_trim_env "$command_pos" "$@")"}[@]}")
    local gh_command=${arguments[2]}
    local gh_subcommand=${arguments[3]}
    local last_argument=${arguments[-1]}

    if (( $command_pos > 1 )); then
        local -x "${(e)${(z)"$(_fzf_complete_get_env "$command_pos" "$@")"}[@]}"
    fi

    if (( $+functions[_fzf_complete_gh_${gh_command}] )) && _fzf_complete_gh_${gh_command} "$@"; then
        return
    fi

    if [[ $gh_command = pr ]]; then
        local prefix_option completing_option
        local gh_options_argument_required=(-R --repo)
        local gh_options_argument_optional=()

        completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)gh_options_argument_required}" "${(F)gh_options_argument_optional}" || :)

        case $completing_option in
            -R|--repo)
                return
                ;;

            *)
                if [[ $gh_subcommand = (close|merge|ready) ]]; then
                    _fzf_complete_gh-pr '' 'open' "$@"
                fi

                if [[ $gh_subcommand = reopen ]]; then
                    _fzf_complete_gh-pr '' 'closed' "$@"
                fi

                if [[ $gh_subcommand = (checkout|comment|diff|edit|review|view) ]]; then
                    _fzf_complete_gh-pr '' 'all' "$@"
                fi

                return
                ;;
        esac

        return
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_gh-pr() {
    local fzf_options=$1
    local pr_state=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@" < <({
        echo "#\tTITLE\tHEAD\tSTATE"
        gh pr list --state $pr_state
    } | FS="\t" _fzf_complete_tabularize ${fg[yellow]} $reset_color ${fg[blue]} ${fg[green]})
}

_fzf_complete_gh-pr_post() {
    awk '{ print $1 }'
}
