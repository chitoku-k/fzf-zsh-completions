#!/usr/bin/env zsh

_fzf_complete_systemctl() {
    _fzf_complete '--ansi --tiebreak=index' "$@" < \
        <(systemctl list-units --full --no-legend --no-pager "$prefix*" | sort | awk \
            -v green="$(tput setaf 2)" \
            -v red="$(tput setaf 1)" \
            -v reset="$(tput sgr0)" '
            {
                unitnames[NR] = $1
                statuses[NR] = $3

                if (length($1) > unitname_max) {
                    unitname_max = length($1)
                }

                $1 = $2 = $3 = $4 = ""
                sub(/^ */, "")
                descriptions[NR] = $0
            }
            END {
                for (i = 1; i <= length(unitnames); ++i) {
                    switch (statuses[i]) {
                        case "active":
                            active_color = green
                            break

                        case "failed":
                            active_color = red
                            break
                    }

                    printf("%s●%s %-" unitname_max "s  %s\n", active_color, reset, unitnames[i], descriptions[i])
                }
            }')
}

_fzf_complete_systemctl_post() {
    awk '{ print $2 }'
}
