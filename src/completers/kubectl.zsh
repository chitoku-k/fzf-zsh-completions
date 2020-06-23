#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_kubectl() {
    local arguments=$@
    local last_argument=${${(Q)${(z)@}}[-1]}

    if [[ $last_argument =~ '(-[^-]*n|--namespace)$' ]]; then
        _fzf_complete_kubectl-namespaces '' $@
        return
    fi

    if [[ $prefix =~ '(-[^-]*n|--namespace=)' ]]; then
        if [[ $prefix = --* ]]; then
            prefix_option=${prefix/=*/=} _fzf_complete_kubectl-namespaces '' $@
        else
            prefix_option=${prefix%%n*}n _fzf_complete_kubectl-namespaces '' $@
        fi
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

    local subcommand resource
    subcommand=$(_fzf_complete_parse_argument 2 1 "$arguments" "${(F)kubectl_options_argument_required}")
    resource=$(_fzf_complete_parse_argument 2 2 "$arguments" "${(F)kubectl_options_argument_required}")

    if [[ $subcommand =~ 'exec|logs' ]]; then
        if [[ $last_argument =~ '(-[^-]*c|--container)$' ]]; then
            _fzf_complete_kubectl-containers '' $@
            return
        fi

        if [[ $prefix =~ '-[^-]*c|--container=' ]]; then
            if [[ $prefix = --* ]]; then
                prefix_option=${prefix/=*/=} _fzf_complete_kubectl-containers '' $@
            else
                prefix_option=${prefix%%n*}n _fzf_complete_kubectl-containers '' $@
            fi
            return
        fi

        _fzf_complete_kubectl-pods '' $@
        return
    fi

    if [[ $subcommand =~ 'describe|get' ]] && [[ $resource =~ 'po|pod|pods' ]]; then
        _fzf_complete_kubectl-pods '' $@
        return
    fi
}

_fzf_complete_kubectl-parse-namespace() {
    local namespace idx

    if [[ -n ${(Q)${(z)@}[(r)-[^-]#n?##]} ]]; then
        idx=${(Q)${(z)@}[(i)-[^-]#n?##]}
        namespace=${(Q)${(z)@}[idx]/-[^-]#n/}
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

_fzf_complete_kubectl-namespaces() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@ < <(
        kubectl get namespaces |
        awk -v prefix_option=$prefix_option '{ print (NR == 1 ? "" : prefix_option) $1, $2, $3 }' |
        _fzf_complete_tabularize $fg[yellow] $reset_color
    )
}

_fzf_complete_kubectl-namespaces_post() {
    awk '{ print $1 }'
}

_fzf_complete_kubectl-pods() {
    local fzf_options=$1
    shift

    local arguments=()
    local namespace=$(_fzf_complete_kubectl-parse-namespace $@)

    if [[ -z $namespace ]]; then
        arguments+=(--all-namespaces)
    else
        arguments+=(--namespace=$namespace)
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@ < <(
        kubectl get pods -o wide ${(Q)${(z)arguments}} |
        awk -v n=$namespace '
            n != "" { print $1, $2, $3, $4, $5, $6, $7 }
            n == "" { print $1, $2, $3, $4, $5, $6, $7, $8 }' |
        if [[ -n $namespace ]]; then
            _fzf_complete_tabularize $fg[yellow] $reset_color{,,,,,}
        else
            _fzf_complete_tabularize $fg[green] $fg[yellow] $reset_color{,,,,,}
        fi
    )
}

_fzf_complete_kubectl-pods_post() {
    if [[ -n $namespace ]]; then
        awk '{ print $1 }'
    else
        awk '{ print "--namespace=" $1, $2 }'
    fi
}

_fzf_complete_kubectl-containers() {
    local fzf_options=$1
    shift

    local namespace=$(_fzf_complete_kubectl-parse-namespace $@)
    local pod=$(_fzf_complete_parse_argument 2 2 "$@" "${(F)kubectl_options_argument_required}")

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@ < <(
        kubectl get pod $pod -n ${namespace:-default} -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}'
    )
}
