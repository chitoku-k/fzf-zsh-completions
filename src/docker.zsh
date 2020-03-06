#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_docker() {
    local subcommand=${${(Q)${(z)@}}[2]}

    if [[ $subcommand =~ (create|history|run) ]]; then
        _fzf_complete_docker-images '' $@
        return
    fi

    if [[ $subcommand =~ (rmi|save) ]]; then
        _fzf_complete_docker-images '--multi' $@
        return
    fi
}

_fzf_complete_docker-images() {
    local fzf_options=$1
    shift 1

    _fzf_complete "--ansi --tiebreak=index --header-lines=1 $fzf_options" $@ < <(
        docker images --format 'table {{.Repository}};{{.Tag}};{{.ID}};{{if .CreatedSince }}{{.CreatedSince}}{{else}}N/A{{end}};{{.Size}}' 2> /dev/null \
            | FS=';' _fzf_complete_docker_tabularize $fg[yellow] $reset_color{,,,}
    )
}

_fzf_complete_docker-images_post() {
    awk '{ if ($1 == "<none>") { print $3; next; } print $1 }'
}

_fzf_complete_docker_tabularize() {
    awk \
        -v FS=${FS:- } \
        -v colors_string=${(pj: :)@} \
        -v reset=$reset_color '
        BEGIN {
            color_number = 0
            if (colors_string != "") {
                split(colors_string, colors, " ")
                color_number = length(colors)
            }
        }
        {
            str = $0
            for (i = 1; i <= color_number; ++i) {
                field_max[i] = length($i) > field_max[i] ? length($i) : field_max[i]
                fields[NR, i] = $i
                match(str, FS)
                str = substr(str, RSTART + RLENGTH)
            }
            fields[NR, i] = str
        }
        END {
            for (record_number = 1; record_number <= NR; ++record_number) {
                for (field_number = 1; field_number <= color_number; ++field_number) {
                    if (fields[record_number, field_number] == "") {
                        break
                    }
                    printf "%s%-" field_max[field_number] "s%s  ", colors[field_number], fields[record_number, field_number], reset
                }
                print fields[record_number, field_number]
            }
        }
    '
}
