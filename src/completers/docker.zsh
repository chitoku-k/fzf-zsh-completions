#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_docker() {
    local subcommand=${${(Q)${(z)@}}[2]}

    if [[ $subcommand =~ ^(create|history|run)$ ]]; then
        _fzf_complete_docker-images '' $@
        return
    fi

    if [[ $subcommand = push ]]; then
        _fzf_complete_docker-images-repository '' $@
        return
    fi

    if [[ $subcommand =~ ^(rmi|save|tag)$ ]]; then
        _fzf_complete_docker-images '--multi' $@
        return
    fi

    if [[ $subcommand =~ ^(attach|exec|top)$ ]]; then
        _fzf_complete_docker-containers '' '' $@
        return
    fi

    if [[ $subcommand =~ ^(kill|pause|stop|unpause)$ ]]; then
        _fzf_complete_docker-containers '' '--multi' $@
        return
    fi

    if [[ $subcommand =~ ^(commit|diff|export|logs|port|rename)$ ]]; then
        _fzf_complete_docker-containers '--all' '' $@
        return
    fi

    if [[ $subcommand = cp ]]; then
        if [[ $prefix = */* ]]; then
            _fzf_path_completion "$prefix" $@
        else
            _fzf_complete_docker-containers '--all' '' $@
        fi
        return
    fi

    if [[ $subcommand =~ ^(restart|rm|start|stats|update|wait)$ ]]; then
        _fzf_complete_docker-containers '--all' '--multi' $@
        return
    fi

    _fzf_path_completion "$prefix" $@
}

_fzf_complete_docker-images() {
    local fzf_options=$1
    shift 1

    _fzf_complete "--ansi --tiebreak=index --header-lines=1 $fzf_options" $@ < <(
        docker images --format 'table {{.ID}};{{.Repository}};{{.Tag}};{{if .CreatedSince}}{{.CreatedSince}}{{else}}N/A{{end}};{{.Size}}' 2> /dev/null \
            | FS=';' _fzf_complete_tabularize $fg[yellow] $reset_color{,,}
    )
}

_fzf_complete_docker-images_post() {
    awk '{ print $1 }'
}

_fzf_complete_docker-images-repository() {
    local fzf_options=$1
    shift 1

    _fzf_complete "--ansi --tiebreak=index --header-lines=1 $fzf_options" $@ < <(
        docker images --format 'table {{.Repository}};{{.ID}};{{.Tag}};{{if .CreatedSince}}{{.CreatedSince}}{{else}}N/A{{end}};{{.Size}}' 2> /dev/null \
            | FS=';' _fzf_complete_tabularize $fg[yellow] $reset_color{,,}
    )
}

_fzf_complete_docker-images-repository_post() {
    awk '{ print $1 }'
}

_fzf_complete_docker-containers() {
    local docker_options=$1
    local fzf_options=$2
    shift 2

    _fzf_complete "--ansi --tiebreak=index --header-lines=1 $fzf_options" $@ < <(
        docker container list ${(Z+n+)docker_options} \
            --format 'table {{.ID}};{{.Image}};{{.Command}};{{.RunningFor}};{{.Status}};{{.Ports}};{{.Names}}' 2> /dev/null \
                | FS=';' _fzf_complete_tabularize $fg[yellow] $reset_color{,,,,}
    )
}

_fzf_complete_docker-containers_post() {
    local input=$(awk '{ print $1 }')

    if [[ -z $input ]]; then
        return
    fi

    if [[ $subcommand = cp ]]; then
        echo -n $input:
    else
        echo $input
    fi
}
