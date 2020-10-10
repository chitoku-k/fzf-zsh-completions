#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_kubectl() {
    local arguments=$@
    local last_argument=${${(Q)${(z)@}}[-1]}
    local prefix_option subcommands namespace resource metadata name

    if [[ $last_argument =~ '(-[^-]*n|--namespace)$' ]]; then
        resource=namespaces
        _fzf_complete_kubectl-resource-names '' $@
        return
    fi

    if [[ $prefix =~ '^(-[^-]*n|--namespace=)' ]]; then
        if [[ $prefix = --* ]]; then
            resource=namespaces
            prefix_option=${prefix/=*/=}
            prefix=${prefix#$prefix_option}
        else
            resource=namespaces
            prefix_option=${prefix%%n*}n
            prefix=${prefix#$prefix_option}
        fi

        _fzf_complete_kubectl-resource-names '' $@
        return
    fi

    if [[ $last_argument =~ '(-[^-]*f|--filename)$' ]]; then
        __fzf_generic_path_completion "$prefix" $@ _fzf_compgen_path '' '' ' '
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

    subcommands=($(_fzf_complete_parse_argument 2 1 "$arguments" "${(F)kubectl_options_argument_required}" || :))
    namespace=$(_fzf_complete_kubectl-parse-namespace $@)

    if [[ ${subcommands[1]} =~ '^(rollout|set)$' ]]; then
        subcommands+=($(_fzf_complete_parse_argument 2 2 "$arguments" "${(F)kubectl_options_argument_required}" || :))
        resource=$(_fzf_complete_parse_argument 2 3 "$arguments" "${(F)kubectl_options_argument_required}" || :)
        name=$(_fzf_complete_parse_argument 2 4 "$arguments" "${(F)kubectl_options_argument_required}" || :)
    else
        resource=$(_fzf_complete_parse_argument 2 2 "$arguments" "${(F)kubectl_options_argument_required}" || :)
        name=$(_fzf_complete_parse_argument 2 3 "$arguments" "${(F)kubectl_options_argument_required}" || :)
    fi

    if [[ $resource = */* ]]; then
        name=${resource#*/}
        resource=${resource%/*}
    elif [[ -z $resource ]] && [[ $prefix =~ / ]]; then
        resource=${prefix%/*}
        prefix_option=${prefix%/*}/
        prefix=${prefix#$prefix_option}
    fi

    if [[ ${subcommands[1]} =~ '^(annotate|label)$' ]]; then
        if [[ -z $resource ]]; then
            _fzf_complete_kubectl-resources '' $@
            return
        fi

        if [[ -z $name ]]; then
            _fzf_complete_kubectl-resource-names '' $@
            return
        fi

        typeset -A metadata_kinds
        metadata_kinds=(
            annotate annotations
            label    labels
        )

        metadata=${metadata_kinds[${subcommands[1]}]}
        _fzf_complete_kubectl-metadata '' $@
        return
    fi

    if [[ ${subcommands[1]} =~ '^(exec|logs)$' ]]; then
        if [[ -z $name ]] && [[ -z $prefix_option ]]; then
            name=$resource
            resource=pods
        fi

        if [[ $last_argument =~ '(-[^-]*c|--container)$' ]]; then
            _fzf_complete_kubectl-containers '' $@
            return
        fi

        if [[ $prefix =~ '^(-[^-]*c|--container=)' ]]; then
            if [[ $prefix = --* ]]; then
                prefix_option=${prefix/=*/=}
                prefix=${prefix#$prefix_option}
            else
                prefix_option=${prefix%%c*}c
                prefix=${prefix#$prefix_option}
            fi

            _fzf_complete_kubectl-containers '' $@
            return
        fi

        _fzf_complete_kubectl-resource-names '' $@
        return
    fi

    if [[ ${subcommands[1]} = 'explain' ]]; then
        _fzf_complete_kubectl-resources '' $@
        return
    fi

    if [[ ${subcommands[1]} = 'port-forward' ]]; then
        if [[ -z $name ]] && [[ -z $prefix_option ]]; then
            name=$resource
            resource=pods
        fi

        if [[ -z $name ]]; then
            _fzf_complete_kubectl-resource-names '' $@
            return
        fi

        prefix_option=${prefix/:*/:}
        prefix=${prefix#$prefix_option}
        _fzf_complete_kubectl-ports '--multi' $@
        return
    fi

    if [[ ${subcommands[1]} =~ '^(describe|expose|get|patch)$' ]]; then
        if [[ -z $resource ]]; then
            _fzf_complete_kubectl-resources '' $@
            return
        fi

        _fzf_complete_kubectl-resource-names '--multi' $@
        return
    fi

    if [[ ${subcommands[1]} = 'rollout' ]]; then
        if [[ ${#subcommands[@]} != 2 ]]; then
            local rollout_subcommands=(history pause restart resume status undo)
            _fzf_complete_constants '' "${(F)rollout_subcommands}" $@
            return
        fi

        if [[ -z $resource ]]; then
            _fzf_complete_kubectl-resources '' $@
            return
        fi

        _fzf_complete_kubectl-resource-names '--multi' $@
        return
    fi

    if [[ ${subcommands[1]} = 'set' ]]; then
        if [[ ${#subcommands[@]} != 2 ]]; then
            local set_subcommands=(env image resources selector serviceaccount subject)
            _fzf_complete_constants '' "${(F)set_subcommands}" $@
            return
        fi

        if [[ -z $resource ]]; then
            _fzf_complete_kubectl-resources '' $@
            return
        fi

        if [[ -z $name ]]; then
            _fzf_complete_kubectl-resource-names '' $@
            return
        fi

        if [[ ${subcommands[2]} = 'image' ]]; then
            _fzf_complete_kubectl-containers '' $@
            return
        fi
        return
    fi

    if [[ ${subcommands[1]} =~ '^(cordon|drain|uncordon)$' ]]; then
        resource=nodes
        _fzf_complete_kubectl-resource-names '' $@
        return
    fi

    if [[ ${subcommands[1]} = 'taint' ]]; then
        if [[ -z $resource ]]; then
            _fzf_complete_kubectl-resources '' $@
            return
        fi

        if [[ -z $name ]]; then
            resource=nodes
            _fzf_complete_kubectl-resource-names '' $@
            return
        fi

        _fzf_complete_kubectl-taints '' $@
        return
    fi

    _fzf_path_completion "$prefix" $@
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
        kubectl get "$resource" "$name" ${(Q)${(z)arguments}} -o jsonpath='NAME IMAGE{"\n"}{range ..containers[*]}{.name} {.image}{"\n"}{end}' 2> /dev/null |
        _fzf_complete_tabularize $fg[yellow]
    )
}

_fzf_complete_kubectl-containers_post() {
    if [[ ${subcommands[@]} != 'set image' ]]; then
        awk '{ print $1 }'
    else
        awk '{ printf "%s=%s", $1, $2 }'
    fi
}

_fzf_complete_kubectl-ports() {
    local fzf_options=$1
    shift

    local arguments=()
    if [[ -n $namespace ]]; then
        arguments+=(--namespace=$namespace)
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        kubectl get "$resource" "$name" ${(Q)${(z)arguments}} -o jsonpath='PORT PROTOCOL NAME{"\n"}{range ..ports[*]}{.targetPort} {.containerPort} {.protocol} {.name}{"\n"}{end}' 2> /dev/null |
        awk '{ print $1, $2, $3 }' |
        _fzf_complete_tabularize $fg[yellow] $reset_color
    )
}

_fzf_complete_kubectl-ports_post() {
    awk '{ print $1 }'
}

_fzf_complete_kubectl-metadata() {
    local fzf_options=$1
    shift

    local arguments=()
    if [[ -n $namespace ]]; then
        arguments+=(--namespace=$namespace)
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        _fzf_complete_tabularize $fg[yellow] $reset_color < <(cat \
            <(echo KEY VALUE) \
            <(kubectl get "$resource" "$name" ${(Q)${(z)arguments}} -o jsonpath="{.metadata.$metadata}" 2> /dev/null | jq -r 'to_entries[] | "\(.key) \(.value)"') \
        )
    )
}

_fzf_complete_kubectl-metadata_post() {
    awk '{ printf "%s=%s", $1, $2 }'
}

_fzf_complete_kubectl-taints() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        _fzf_complete_tabularize $fg[yellow] $reset_color < <(cat \
            <(echo KEY VALUE EFFECT) \
            <(kubectl get "$resource" "$name" -o jsonpath='{range .spec.taints[*]}{.key} {.value} {.effect}{"\n"}{end}' 2> /dev/null)
        )
    )
}

_fzf_complete_kubectl-taints_post() {
    awk '{ printf "%s=%s:%s", $1, $2, $3 }'
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
