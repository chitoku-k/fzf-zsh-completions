#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_glab() {
    setopt local_options no_aliases
    local command_pos=$(_fzf_complete_get_command_pos "$@")
    local arguments=("${(Qe)${(z)$(_fzf_complete_requote_arguments ${~${(z)@}})}[@][$command_pos, -1]}")
    local glab_command=${arguments[2]}
    local glab_subcommand=${arguments[3]}
    local last_argument=${arguments[-1]}

    if (( $command_pos > 1 )); then
        local -x "${(Qe)${(z)$(_fzf_complete_requote_arguments ${~${(z)@}})}[@][1, $command_pos - 1]}"
    fi

    if (( $+functions[_fzf_complete_glab_${glab_command}] )) && _fzf_complete_glab_${glab_command} "$@"; then
        return
    fi

    if [[ $glab_command = mr ]]; then
        local prefix_option completing_option
        local glab_options_argument_required=()
        local glab_options_argument_optional=()

        completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)glab_options_argument_required}" "${(F)glab_options_argument_optional}" || :)

        case $completing_option in

            *)
                if [[ $glab_subcommand = (checkout|close|merge|approve|todo|revoke) ]]; then
                    _fzf_complete_glab-mr '' '' "$@"
                fi

                if [[ $glab_subcommand = reopen ]]; then
                    _fzf_complete_glab-mr '' '--closed' "$@"
                fi

                if [[ $glab_subcommand = (diff|update|view) ]]; then
                    _fzf_complete_glab-mr '' '--all' "$@"
                fi

                return
                ;;
        esac

        return

    elif [[ $glab_command = co ]]; then
        _fzf_complete_glab-mr '' '' "$@"
        return
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_glab-mr() {
    local fzf_options=$1
    local mr_state=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@" < <({
        echo "#\tTITLE\tBRANCH\tSTATE"
        glab mr list $mr_state -F json | jq -r '(.[] | [.reference, .title, .source_branch, .state]) | @tsv'
    } | FS="\t" _fzf_complete_tabularize ${fg[yellow]} $reset_color ${fg[blue]} ${fg[green]})
}

_fzf_complete_glab-mr_post() {
    awk '{ print $1 }' | tr -d "!"
}
