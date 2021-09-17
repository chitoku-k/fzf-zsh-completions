#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_preview_systemctl_status=$(cat <<'PREVIEW_OPTIONS'
    --preview-window=right:70%:wrap
    --preview='echo {} | awk '\''{ print $2 }'\'' | SYSTEMD_COLORS=true xargs systemctl status $SYSTEMCTL_OPTIONS --'
PREVIEW_OPTIONS
)

_fzf_complete_systemctl() {
    setopt local_options no_aliases
    local command_pos=$(_fzf_complete_get_command_pos "$@")
    local arguments=("${(Q)${(z)"$(_fzf_complete_trim_env "$command_pos" "$@")"}[@]}")

    if (( $command_pos > 1 )); then
        local -x "${(e)${(z)"$(_fzf_complete_get_env "$command_pos" "$@")"}[@]}"
    fi

    local systemctl_options_argument_required=(
        --boot-loader-entry
        --boot-loader-menu
        --check-inhibitors
        -H
        --host
        --job-mode
        --kill-who
        --legend
        --lines
        -M
        --machine
        --message
        -n
        -o
        --output
        -p
        -P
        --preset-mode
        --property
        --reboot-argument
        --root
        -s
        --signal
        --state
        -t
        --timestamp
        --type
        --what
    )
    local subcommand=$(_fzf_complete_parse_argument 2 1 "${(F)systemctl_options_argument_required}" "${arguments[@]}")

    if (( $+functions[_fzf_complete_systemctl_${subcommand}] )) && _fzf_complete_systemctl_${subcommand} "$@"; then
        return
    fi

    _fzf_complete_systemctl-units '--multi' "$@"
}

_fzf_complete_systemctl-units() {
    local fzf_options=$1
    shift

    local systemctl_options=(--full --no-legend --no-pager)
    systemctl_options+=($(_fzf_complete_parse_option '' '--user --system' '' "${arguments[@]}")) || :

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} ${(Q)${(Z+n+)${_fzf_complete_preview_systemctl_status/\$SYSTEMCTL_OPTIONS/$systemctl_options}}} ${(Q)${(Z+n+)FZF_DEFAULT_OPTS}} -- "$@" < \
        <({
            systemctl list-units ${(Q)${(Z+n+)systemctl_options}} "$prefix*"
            systemctl list-unit-files ${(Q)${(Z+n+)systemctl_options}} "$prefix*"
        } |
            LC_ALL=C sort -b -f -k 1,1 -k 3,3r |
            awk \
                -v green=${fg[green]} \
                -v red=${fg[red]} \
                -v reset=$reset_color '
                $1 !~ /@\.(service|socket|target)$/ && !($1 in units) {
                    unitname = $1
                    status = $3
                    units[unitname] = 1

                    if (status == "active") {
                        indicator = green "●" reset
                    } else if (status == "failed") {
                        indicator = red "●" reset
                    } else {
                        indicator = "○"
                    }

                    print indicator, unitname
                }')
}

_fzf_complete_systemctl-units_post() {
    awk '{ print $2 }'
}
