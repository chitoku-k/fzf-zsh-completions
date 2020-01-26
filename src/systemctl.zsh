#!/usr/bin/env zsh

_fzf_complete_preview_systemctl_status=$(cat <<'PREVIEW_OPTIONS'
    --preview-window=right:70%:wrap
    --preview='echo {} | awk '\''{ print substr($0, length("●") + 2) }'\'' | xargs systemctl status --'
PREVIEW_OPTIONS
)

_fzf_complete_systemctl() {
    _fzf_complete "--ansi --tiebreak=index $_fzf_complete_preview_systemctl_status $FZF_DEFAULT_OPTS" $@ < \
        <(systemctl list-units --full --no-legend --no-pager "$prefix*" | sort | awk \
            -v green=$(tput setaf 2) \
            -v red=$(tput setaf 1) \
            -v reset=$(tput sgr0) '
            {
                unitname = $1
                status = $3

                switch (status) {
                    case "active":
                        active_color = green
                        break

                    case "failed":
                        active_color = red
                        break
                }

                printf("%s●%s %s\n", active_color, reset, unitname)
            }')
}

_fzf_complete_systemctl_post() {
    awk '{ print $2 }'
}
