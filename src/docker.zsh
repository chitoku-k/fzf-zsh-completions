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

    _fzf_path_completion "$prefix" $@
}

_fzf_complete_docker-images() {
    local fzf_options=$1
    shift 1

    _fzf_complete "--ansi --tiebreak=index --header-lines=1 $fzf_options" $@ < <(
        docker images --format 'table {{.ID}};{{.Repository}};{{.Tag}};{{if .CreatedSince}}{{.CreatedSince}}{{else}}N/A{{end}};{{.Size}}' 2> /dev/null \
            | FS=';' _fzf_complete_docker_tabularize $fg[yellow] $reset_color{,,}
    )
}

_fzf_complete_docker-images_post() {
    awk '{ print $1 }'
}

_fzf_complete_docker_tabularize() {
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
                    printf "%s%-" field_max[j] "s%s  ", colors[j], fields[i, j], reset
                }
                print fields[i, j]
            }
        }
    '
}
