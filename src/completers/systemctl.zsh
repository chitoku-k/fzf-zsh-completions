#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_preview_systemctl_status=$(cat <<'PREVIEW_OPTIONS'
    --preview-window=right:70%:wrap
    --preview='echo {} | awk '\''{ print $2 }'\'' | SYSTEMD_COLORS=true xargs systemctl status $SYSTEMCTL_OPTIONS --'
PREVIEW_OPTIONS
)

_fzf_complete_systemctl() {
    _fzf_complete_systemctl-units '' $@
}

_fzf_complete_systemctl-units() {
    local fzf_options=$1
    shift

    local arguments=("${(Q)${(z)"$(_fzf_complete_trim_env $@)"}[@]}")
    local systemctl_options=(--full --no-legend --no-pager)
    systemctl_options+=($(_fzf_complete_parse_option '' '--user --system' '' "${${(q)arguments[@]}}")) || :

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)${_fzf_complete_preview_systemctl_status/\$SYSTEMCTL_OPTIONS/$systemctl_options}}} ${(Q)${(Z+n+)FZF_DEFAULT_OPTS}} -- $@ < \
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
