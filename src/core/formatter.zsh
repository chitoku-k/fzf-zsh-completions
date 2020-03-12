#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_tabularize() {
    awk \
        -v FS=${FS:- } \
        -v colors_args=${(pj: :)@} \
        -v reset=$reset_color '
        BEGIN {
            split(colors_args, colors, " ")
        }
        {
            str = $0
            pos = -1
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
                    printf "%s%-" field_max[j] "s%s  ", colors[j], fields[i, j], reset
                }
                print fields[i, j]
            }
        }
    '
}
