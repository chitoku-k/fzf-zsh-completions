#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_docker() {
    setopt local_options no_aliases
    local command_pos=$(_fzf_complete_get_command_pos "$@")
    local arguments=("${(Q)${(z)"$(_fzf_complete_trim_env "$command_pos" "$@")"}[@]}")
    local subcommand=${arguments[2]}

    if (( $command_pos > 1 )); then
        local -x "${(e)${(z)"$(_fzf_complete_get_env "$command_pos" "$@")"}[@]}"
    fi

    if (( $+functions[_fzf_complete_docker_${subcommand}] )) && _fzf_complete_docker_${subcommand} "$@"; then
        return
    fi

    if [[ $subcommand = (create|history|run) ]]; then
        _fzf_complete_docker-images '' "$@"
        return
    fi

    if [[ $subcommand = push ]]; then
        _fzf_complete_docker-images-repository '' "$@"
        return
    fi

    if [[ $subcommand = (rmi|save|tag) ]]; then
        _fzf_complete_docker-images '--multi' "$@"
        return
    fi

    if [[ $subcommand = (attach|exec|top) ]]; then
        _fzf_complete_docker-containers '' '' "$@"
        return
    fi

    if [[ $subcommand = (kill|pause|stop|unpause) ]]; then
        _fzf_complete_docker-containers '' '--multi' "$@"
        return
    fi

    if [[ $subcommand = (commit|diff|export|logs|port|rename) ]]; then
        _fzf_complete_docker-containers '--all' '' "$@"
        return
    fi

    if [[ $subcommand = cp ]]; then
        if [[ $prefix = */* ]]; then
            _fzf_path_completion "$prefix" "$@"
        else
            _fzf_complete_docker-containers '--all' '' "$@"
        fi
        return
    fi

    if [[ $subcommand = inspect ]]; then
        local inspect_type=$(_fzf_complete_parse_option_arguments '' '--type' '--type' 'argument' "${arguments[@]}" || :)

        case $inspect_type in
            image)
                _fzf_complete_docker-images '--multi' "$@"
                ;;

            network)
                _fzf_complete_docker-networks '--multi' "$@"
                ;;

            volume)
                _fzf_complete_docker-volumes '--multi' "$@"
                ;;

            container)
                _fzf_complete_docker-containers '--all' '--multi' "$@"
                ;;

            task)
                ;;

            '')
                _fzf_complete_docker-containers '--all' '--multi' "$@"
                ;;
        esac

        return
    fi

    if [[ $subcommand = (restart|rm|start|stats|update|wait) ]]; then
        _fzf_complete_docker-containers '--all' '--multi' "$@"
        return
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_docker-images() {
    local fzf_options=$1
    shift 1

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@" < <(
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

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@" < <(
        docker images --filter 'dangling=false' --format 'table {{.Repository}};{{.ID}};{{.Tag}};{{if .CreatedSince}}{{.CreatedSince}}{{else}}N/A{{end}};{{.Size}}' 2> /dev/null \
            | FS=';' _fzf_complete_tabularize $fg[yellow] $reset_color{,,}
    )
}

_fzf_complete_docker-images-repository_post() {
    local input=$(awk '{ print $1 }')

    if [[ -z $input ]]; then
        return
    fi

    echo -n $input
}

_fzf_complete_docker-containers() {
    local docker_options=$1
    local fzf_options=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@" < <(
        docker container list ${(Q)${(Z+n+)docker_options}} \
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

_fzf_complete_docker-networks() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@" < <(
        docker network list --format 'table {{.ID}};{{.Name}};{{.Driver}};{{.Scope}}' 2> /dev/null \
            | FS=';' _fzf_complete_tabularize $fg[yellow] $reset_color{,}
    )
}

_fzf_complete_docker-networks_post() {
    awk '{ print $1 }'
}

_fzf_complete_docker-volumes() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@" < <(
        docker volume list --format 'table {{.Name}};{{.Driver}};{{.Scope}}' 2> /dev/null \
            | FS=';' _fzf_complete_tabularize $fg[yellow] $reset_color
    )
}

_fzf_complete_docker-volumes_post() {
    awk '{ print $1 }'
}
