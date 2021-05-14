#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_tabularize() {
    if [[ $# = 0 ]]; then
        cat
        return
    fi

    awk \
        -v FS=${FS:- } \
        -v colors_args=${(pj: :)@} \
        -v reset=$reset_color '
        BEGIN {
            split(colors_args, colors, " ")
        }
        {
            str = $0
            for (i = 1; i <= length(colors); ++i) {
                field_max[i] = length($i) > field_max[i] ? length($i) : field_max[i]
                fields[NR, i] = $i
                pos = index(str, FS)
                str = substr(str, pos + 1)
            }
            if (pos != 0) {
                fields[NR, i] = str
            }
        }
        END {
            for (i = 1; i <= NR; ++i) {
                for (j = 1; j <= length(colors); ++j) {
                    printf "%s%s%-" field_max[j] "s%s", (j > 1 ? "  " : ""), colors[j], fields[i, j], reset
                }
                if ((i, j) in fields) {
                    printf "  %s", fields[i, j]
                }
                printf "\n"
            }
        }
    '
}

_fzf_complete_colorize() {
    if [[ $# = 0 ]]; then
        cat
        return
    fi

    awk \
        -v colors_args=${(pj: :)@} \
        -v reset=$reset_color '
        BEGIN {
            split(colors_args, colors, " ")
            header = 1
        }
        header {
            delete fields
            fields[1] = 1
            header = 0

            for (i = 2; i <= length($0); ++i) {
                if (substr($0, i - 1, 1) == " " && substr($0, i, 1) != " ") {
                    fields[length(fields) + 1] = i
                }
            }
        }
        {
            total = 0
            for (i = 1; i<= length(colors); ++i) {
                width = fields[i + 1] - fields[i] < 0 ? length($0) : fields[i + 1] - fields[i]
                total += width
                printf "%s%s%s", colors[i], substr($0, fields[i], width), reset
            }

            printf "%s\n", substr($0, total + 1)
        }
        /^$/ {
            header = 1
        }
    '
}
