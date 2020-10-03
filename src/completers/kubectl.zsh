#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_kubectl() {
    local arguments=$@
    local last_argument=${${(Q)${(z)@}}[-1]}
    local prefix_option resource name

    if [[ $last_argument =~ '(-[^-]*n|--namespace)$' ]]; then
        resource=namespaces
        _fzf_complete_kubectl-resource-names '' $@
        return
    fi

    if [[ $prefix =~ '^(-[^-]*n|--namespace=)' ]]; then
        if [[ $prefix = --* ]]; then
            resource=namespaces \
            prefix_option=${prefix/=*/=} \
            prefix=${prefix#$prefix_option} \
                _fzf_complete_kubectl-resource-names '' $@
        else
            resource=namespaces \
            prefix_option=${prefix%%n*}n \
            prefix=${prefix#$prefix_option} \
                _fzf_complete_kubectl-resource-names '' $@
        fi
        return
    fi

    if [[ $last_argument =~ '(-[^-]*f|--filename)$' ]]; then
        _fzf_path_completion "$prefix" $@
        return
    fi

    if [[ $prefix =~ '^(-[^-]*f|--filename=)' ]]; then
        if [[ $prefix = --* ]]; then
            prefix_option=${prefix/=*/=}
        else
            prefix_option=${prefix%%f*}f
        fi

        __fzf_generic_path_completion "${prefix#$prefix_option}" $@$prefix_option _fzf_compgen_path '' '' ' '
        return
    fi

    local kubectl_options_argument_required=(
        --application-metrics-count-limit
        --as
        --as-group
        --azure-container-registry-config
        --boot-id-file
        --cache-dir
        --certificate-authority
        --client-certificate
        --client-key
        --cloud-provider-gce-l7lb-src-cidrs
        --cloud-provider-gce-lb-src-cidrs
        --cluster
        --container-hints
        --containerd
        --containerd-namespace
        --context
        --default-not-ready-toleration-seconds
        --default-unreachable-toleration-seconds
        --docker
        --docker-env-metadata-whitelist
        --docker-root
        --docker-tls-ca--docker-tls-cert
        --docker-tls-key
        --event-storage-age-limit
        --event-storage-event-limit
        --global-housekeeping-interval
        --housekeeping-interval
        --kubeconfig
        --log-backtrace-at
        --log-dir
        --log-file
        --log-file-max-size
        --log-flush-frequency
        --machine-id-file
        --namespace
        -n
        --password
        --profile
        --profile-output
        --request-timeout
        -s
        --server
        --stderrthreshold
        --storage-driver-buffer-duration
        --storage-driver-db
        --storage-driver-host
        --storage-driver-password
        --storage-driver-table
        --storage-driver-user
        --tls-server-name
        --token
        --update-machine-info-interval
        --user
        --username
        -v
        --v
        --version
        --vmodule
    )

    local subcommands=($(_fzf_complete_parse_argument 2 1 "$arguments" "${(F)kubectl_options_argument_required}"))
    local namespace=$(_fzf_complete_kubectl-parse-namespace $@)

    if [[ ${subcommands[1]} =~ '^(rollout|set)$' ]]; then
        subcommands+=($(_fzf_complete_parse_argument 2 2 "$arguments" "${(F)kubectl_options_argument_required}"))
        resource=$(_fzf_complete_parse_argument 2 3 "$arguments" "${(F)kubectl_options_argument_required}")
    else
        resource=$(_fzf_complete_parse_argument 2 2 "$arguments" "${(F)kubectl_options_argument_required}")
    fi

    if [[ $resource = */* ]]; then
        name=${resource#*/}
        resource=${resource%/*}
    elif [[ -z $resource ]] && [[ $prefix =~ / ]]; then
        resource=${prefix%/*}
        prefix_option=${prefix%/*}/
        prefix=${prefix#$prefix_option}
    else
        name=$(_fzf_complete_parse_argument 2 3 "$arguments" "${(F)kubectl_options_argument_required}")
    fi

    if [[ ${subcommands[1]} =~ '^(exec|logs|port-forward)$' ]]; then
        if [[ -z $name ]]; then
            name=$resource
            resource=pods
        fi

        if [[ $last_argument =~ '(-[^-]*c|--container)$' ]]; then
            _fzf_complete_kubectl-containers '' $@
            return
        fi

        if [[ $prefix =~ '^(-[^-]*c|--container=)' ]]; then
            if [[ $prefix = --* ]]; then
                prefix_option=${prefix/=*/=} \
                prefix=${prefix#$prefix_option} \
                    _fzf_complete_kubectl-containers '' $@
            else
                prefix_option=${prefix%%c*}c \
                prefix=${prefix#$prefix_option} \
                    _fzf_complete_kubectl-containers '' $@
            fi
            return
        fi

        _fzf_complete_kubectl-resource-names '' $@
        return
    fi

    if [[ ${subcommands[1]} =~ '^(annotate|describe|expose|get|label|patch)$' ]]; then
        if [[ -z $resource ]]; then
            _fzf_complete_kubectl-resources '' $@
            return
        fi

        _fzf_complete_kubectl-resource-names '--multi' $@
    fi

    if [[ ${subcommands[1]} = 'rollout' ]]; then
        if [[ ${#subcommands[@]} != 2 ]]; then
            return
        fi

        if [[ -z $resource ]]; then
            _fzf_complete_kubectl-resources '' $@
            return
        fi

        _fzf_complete_kubectl-resource-names '--multi' $@
    fi

    if [[ ${subcommands[1]} =~ '^(cordon|drain|uncordon)$' ]]; then
        resource=nodes
        _fzf_complete_kubectl-resource-names '' $@
    fi
}

_fzf_complete_kubectl-parse-namespace() {
    local namespace idx

    if [[ -n ${(Q)${(z)@}[(r)-[^-]#n?##]} ]]; then
        idx=${(Q)${(z)@}[(i)-[^-]#n?##]}
        namespace=${(Q)${(z)@}[idx]/-[^-n]#n/}
    fi

    if [[ -n ${(Q)${(z)@}[(r)-[^-]#n]} ]]; then
        idx=${(Q)${(z)@}[(i)-[^-]#n]}
        namespace=${(Q)${(z)@}[idx+1]}
    fi

    if [[ -n ${(Q)${(z)@}[(r)--namespace=*]} ]]; then
        idx=${(Q)${(z)@}[(i)--namespace=*]}
        namespace=${(Q)${(z)@}[idx]/--namespace=/}
    fi

    if [[ -n ${(Q)${(z)@}[(r)--namespace]} ]]; then
        idx=${(Q)${(z)@}[(i)--namespace]}
        namespace=${(Q)${(z)@}[idx+1]}
    fi

    echo - $namespace
}

_fzf_complete_kubectl-resources() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@ < <(
        kubectl api-resources --cached --verbs=get |
        _fzf_complete_colorize $fg[yellow]
    )
}

_fzf_complete_kubectl-resources_post() {
    awk '{ print $1 }'
}

_fzf_complete_kubectl-containers() {
    local fzf_options=$1
    shift

    local arguments=()
    if [[ -n $namespace ]]; then
        arguments+=(--namespace=$namespace)
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        kubectl get pod $name ${(Q)${(z)arguments}} -o jsonpath='{"NAME\tIMAGE\n"}{range .spec.containers[*]}{.name}{"\t"}{.image}{"\n"}{end}' 2> /dev/null |
        _fzf_complete_tabularize $fg[yellow] $reset_color
    )
}

_fzf_complete_kubectl-containers_post() {
    awk '{ print $1 }'
}

_fzf_complete_kubectl-resource-names() {
    local fzf_options=$1
    shift

    local arguments=()
    if [[ -z $namespace ]]; then
        arguments+=(--all-namespaces)
    else
        arguments+=(--namespace=$namespace)
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        local result=$(kubectl get "$resource" -o wide ${(Q)${(z)arguments}} 2> /dev/null)
        if [[ $result = NAMESPACE\ * ]]; then
            _fzf_complete_colorize $fg[green] $fg[yellow] | awk '{ print SUBSEP $0 }'
        else
            _fzf_complete_colorize $fg[yellow]
        fi <<< "$result"
    )
}

_fzf_complete_kubectl-resource-names_post() {
    awk \
        -v prefix_option=$prefix_option '
        NR > 1 && prefix_option ~ /\/$/ {
            printf "%s", prefix_option
        }
        /^\x1c/ {
            sub(SUBSEP, "", $1)
            namespace = $1
            print $2
            next
        }
        {
            print $1
        }
        END {
            if (namespace != "") {
                print "--namespace=" namespace
            }
        }
    '
}
