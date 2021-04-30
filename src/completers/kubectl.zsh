#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_kubectl() {
    local arguments=$@
    local kubectl_arguments=()
    local last_argument=${${(Q)${(z)@}}[-1]}
    local prefix_option completing_option subcommands namespace resource name

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
        --docker-tls-ca
        --docker-tls-cert
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
        -n
        --namespace
        --password
        --profile
        --profile-output
        --referenced-reset-interval
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
        --vmodule
    )
    local kubectl_options_argument_optional=()

    local inherit_option inherit_values
    local kubectl_inherited_options_argument_required=(
        --as
        --as-group
        --certificate-authority
        --client-certificate
        --client-key
        --cluster
        --context
        -l
        --label-columns
        -L
        -n
        --namespace
        --password
        -s
        --selector
        --server
        --tls-server-name
        --token
        --user
        --username
    )
    local kubectl_inherited_options=(
        --insecure-skip-tls-verify
        --match-server-version
    )

    for inherit_option in ${kubectl_inherited_options_argument_required[@]} ${kubectl_inherited_options[@]}; do
        if [[ $inherit_option = --* ]]; then
            if inherit_values=$(_fzf_complete_parse_option_arguments '' "$inherit_option" $@$RBUFFER); then
                kubectl_arguments+=($inherit_values)
            fi
        else
            if inherit_values=$(_fzf_complete_parse_option_arguments "$inherit_option" '' $@$RBUFFER); then
                kubectl_arguments+=($inherit_values)
            fi
        fi
    done

    subcommands=($(_fzf_complete_parse_argument 2 1 "$arguments" "${(F)kubectl_options_argument_required}" || :))
    namespace=$(_fzf_complete_parse_option_arguments '-n' '--namespace' $@$RBUFFER || :)

    if [[ ${subcommands[1]} =~ '^(apply|rollout|set)$' ]]; then
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
    elif [[ ${subcommands[1]} =~ '^(cordon|drain|uncordon)$' ]]; then
        resource=nodes
    elif [[ ${subcommands[1]} = 'run' ]]; then
        resource=pods
    elif [[ ${subcommands[1]} = 'scale' ]]; then
        resource=deployments,replicaset,replicationcontrollers,statefulset
    fi

    if [[ ${subcommands[1]} = 'annotate' ]]; then
        kubectl_options_argument_required+=(
            --dry-run
            -f
            --field-manager
            --field-selector
            --filename
            -k
            --kustomize
            -l
            -o
            --output
            --resource-version
            --selector
            --template
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' $@
                return
            fi

            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' $@
                return
            fi

            _fzf_complete_kubectl-annotations '--multi' $@
            return
        fi
    fi

    if [[ ${subcommands[1]} = 'apply' ]]; then
        kubectl_options_argument_required+=(
            --cascade
            --dry-run
            -f
            --field-manager
            --filename
            --grace-period
            -k
            --kustomize
            -l
            -o
            --output
            --prune-whitelist
            --selector
            --template
            --timeout
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]] && [[ ${#subcommands[@]} = 2 ]]; then
            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' $@
                return
            fi

            if [[ -z $name ]]; then
                if [[ ${subcommands[2]} = 'edit-last-applied' ]]; then
                    _fzf_complete_kubectl-resource-names '' $@
                elif [[ ${subcommands[2]} = 'view-last-applied' ]]; then
                    _fzf_complete_kubectl-resource-names '--multi' $@
                fi
            fi
            return
        fi
    fi

    if [[ ${subcommands[1]} =~ '^(autoscale|edit|expose|patch)$' ]]; then
        kubectl_options_argument_required+=(
            --cluster-ip
            --container-port
            --cpu-percent
            --dry-run
            --external-ip
            -f
            --field-manager
            --filename
            --generator
            -k
            --kustomize
            -l
            --labels
            --load-balancer-ip
            --max
            --min
            --name
            -o
            --overrides
            --output
            --patch
            --port
            --protocol
            --selector
            --session-affinity
            --target-port
            --template
            --type
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' $@
                return
            fi

            _fzf_complete_kubectl-resource-names '' $@
            return
        fi
    fi

    if [[ ${subcommands[1]} =~ '^(cordon|drain|uncordon)$' ]]; then
        kubectl_options_argument_required+=(
            --dry-run
            --grace-period
            -l
            --pod-selector
            --selector
            --skip-wait-for-delete-timeout
            --timeout
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            _fzf_complete_kubectl-resource-names '' $@
            return
        fi
    fi

    if [[ ${subcommands[1]} =~ 'create' ]]; then
        kubectl_options_argument_required+=(
            --aggregation-rule
            --annotation
            --cert
            --class
            --clusterip
            --clusterrole
            --default-backend
            --description
            --docker-email
            --docker-password
            --docker-server
            --docker-username
            --dry-run
            --external-name
            -f
            --field-manager
            --filename
            --from
            --from-env-file
            --from-file
            --from-literal
            --generator
            --group
            --hard
            --image
            -k
            --key
            --kustomize
            -l
            --max-unavailable
            --min-available
            --non-resource-url
            -o
            --output
            --port
            --preemption-policy
            -r
            --raw
            --replicas
            --resource
            --resource-name
            --restart
            --role
            --schedule
            --scopes
            --selector
            --serviceaccount
            --tcp
            --template
            --type
            --verb
            --value
        )

        local set_subcommands=(
            'clusterrole'
            'clusterrolebinding'
            'configmap'
            'cronjob'
            'deployment'
            'ingress'
            'job'
            'namespace'
            'poddisruptionbudget'
            'priorityclass'
            'quota'
            'role'
            'rolebinding'
            'secret'
            'secret docker-registry'
            'secret generic'
            'secret tls'
            'service'
            'service clusterip'
            'service externalname'
            'service loadbalancer'
            'service nodeport'
            'serviceaccount'
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            _fzf_complete_constants '' "${(F)set_subcommands}" $@
            return
        fi
    fi

    if [[ ${subcommands[1]} =~ '^(delete|describe|get|scale|wait)$' ]]; then
        kubectl_options_argument_required+=(
            --cascade
            --chunk-size
            --current-replicas
            --dry-run
            -f
            --field-selector
            --filename
            --for
            --grace-period
            -k
            --kustomize
            -l
            -L
            --label-columns
            -o
            --output
            --raw
            --replicas
            --resource-version
            --selector
            --sort-by
            --template
            --timeout
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' $@
                return
            fi

            _fzf_complete_kubectl-resource-names '--multi' $@
            return
        fi

        if [[ ${subcommands[1]} = 'get' ]] && [[ $completing_option =~ '^(-L|--label-columns)$' ]]; then
            _fzf_complete_kubectl-label-columns '' $@
            return
        fi
    fi

    if [[ ${subcommands[1]} = 'exec' ]]; then
        kubectl_options_argument_required+=(
            -c
            --container
            -f
            --filename
            --pod-running-timeout
        )

        if [[ -z $name ]] && [[ -z $prefix_option ]]; then
            name=$resource
            resource=pods
        fi

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            _fzf_complete_kubectl-resource-names '' $@
            return
        fi

        if [[ $completing_option =~ '^(-c|--container)$' ]]; then
            _fzf_complete_kubectl-containers '' $@
            return
        fi
    fi

    if [[ ${subcommands[1]} = 'explain' ]]; then
        kubectl_options_argument_required+=(--api-version)

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            _fzf_complete_kubectl-resources '' $@
            return
        fi
    fi

    if [[ ${subcommands[1]} = 'label' ]]; then
        kubectl_options_argument_required+=(
            --dry-run
            -f
            --field-manager
            --field-selector
            --filename
            -k
            --kustomize
            -l
            -o
            --output
            --resource-version
            --selector
            --template
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' $@
                return
            fi

            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' $@
                return
            fi

            _fzf_complete_kubectl-labels '--multi' $@
            return
        fi
    fi

    if [[ ${subcommands[1]} = 'logs' ]]; then
        kubectl_options_argument_required+=(
            -c
            --container
            -l
            --limit-bytes
            --max-log-requests
            --pod-running-timeout
            --selector
            --since
            --since-time
            --tail
        )

        if [[ -z $name ]] && [[ -z $prefix_option ]]; then
            name=$resource
            resource=pods
        fi

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            _fzf_complete_kubectl-resource-names '' $@
            return
        fi

        if [[ $completing_option =~ '^(-c|--container)$' ]]; then
            _fzf_complete_kubectl-containers '' $@
            return
        fi
    fi

    if [[ ${subcommands[1]} = 'port-forward' ]]; then
        kubectl_options_argument_required+=(
            --address
            --pod-running-timeout
        )

        if [[ -z $name ]] && [[ -z $prefix_option ]]; then
            name=$resource
            resource=pods
        fi

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' $@
                return
            fi

            prefix_option=${prefix/:*/:}
            prefix=${prefix#$prefix_option}
            _fzf_complete_kubectl-ports '--multi' $@
            return
        fi
    fi

    if [[ ${subcommands[1]} = 'rollout' ]]; then
        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
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
    fi

    if [[ ${subcommands[1]} = 'set' ]]; then
        kubectl_options_argument_required+=(
            -c
            --containers
            --dry-run
            -e
            --env
            --field-manager
            -f
            --filename
            --from
            --group
            -k
            --keys
            --kustomize
            -l
            --limits
            -o
            --output
            --prefix
            --requests
            --resource-version
            --selector
            --serviceaccount
            --template
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
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
                _fzf_complete_kubectl-containers '--multi' $@
                return
            fi
            return
        fi
    fi

    if [[ ${subcommands[1]} = 'taint' ]]; then
        kubectl_options_argument_required+=(
            --dry-run
            --field-manager
            -l
            -o
            --output
            --selector
            --template
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                local taint_resources=(nodes)
                _fzf_complete_constants '' "${(F)taint_resources}" $@
                return
            fi

            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' $@
                return
            fi

            _fzf_complete_kubectl-taints '--multi' $@
            return
        fi
    fi

    if [[ ${subcommands[1]} = 'top' ]]; then
        kubectl_options_argument_required+=(
            -l
            --selector
            --sort-by
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                local top_resources=(nodes pods)
                _fzf_complete_constants '' "${(F)top_resources}" $@
                return
            fi

            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' $@
                return
            fi
            return
        fi
    fi

    if [[ ${subcommands[1]} =~ '^(|diff|run)$' ]]; then
        kubectl_options_argument_required+=(
            --annotations
            --cascade
            --dry-run
            --env
            -f
            --field-manager
            --filename
            --grace-period
            --hostport
            --image
            --image-pull-policy
            -k
            --kustomize
            -l
            --labels
            --limits
            -o
            --output
            --overrides
            --pod-running-timeout
            --port
            --requests
            --restart
            --selector
            --serviceaccount
            --template
            --timeout
        )

        if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
            if [[ $completing_option = --* ]]; then
                prefix_option=$completing_option=
            else
                prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
            fi
            prefix=${prefix#$prefix_option}
        fi
    fi

    if [[ $completing_option =~ '^(-n|--namespace)$' ]]; then
        resource=namespaces
        _fzf_complete_kubectl-resource-names '' $@
        return
    fi

    if [[ $completing_option =~ '^(-l|--labels|--selector)$' ]]; then
        if [[ $prefix = *, ]]; then
            local selector=${prefix%%,},
            prefix_option=$prefix_option$selector
            prefix=${prefix#$selector}
        fi

        if [[ $prefix = *! ]]; then
            local selector=${prefix%%!}!
            prefix_option=$prefix_option$selector
            prefix=${prefix#$selector}
        fi

        _fzf_complete_kubectl-selectors '--multi' $@
        return
    fi

    if [[ $completing_option =~ '^(-f|--filename)$' ]]; then
        if [[ $last_argument =~ '(-[^-]*f|--filename)$' ]]; then
            __fzf_generic_path_completion "$prefix" $@ _fzf_compgen_path '' '' ' '
            return
        fi

        __fzf_generic_path_completion "${prefix#$prefix_option}" $@$prefix_option _fzf_compgen_path '' '' ' '
        return
    fi

    _fzf_path_completion "$prefix" $@
}

_fzf_complete_kubectl-resources() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@ < <(
        kubectl api-resources --cached --verbs=get ${(Q)${(z)kubectl_arguments}} |
        _fzf_complete_colorize $fg[yellow]
    )
}

_fzf_complete_kubectl-resources_post() {
    awk '{ print $1 }'
}

_fzf_complete_kubectl-containers() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <({
        echo NAME IMAGE
        kubectl get "$resource" "$name" ${(Q)${(z)kubectl_arguments}} -o jsonpath='{range ..initContainers[*]}{.name} {.image}{"\n"}{end}' 2> /dev/null
        kubectl get "$resource" "$name" ${(Q)${(z)kubectl_arguments}} -o jsonpath='{range ..containers[*]}{.name} {.image}{"\n"}{end}' 2> /dev/null
    } | _fzf_complete_tabularize $fg[yellow])
}

_fzf_complete_kubectl-containers_post() {
    if [[ ${subcommands[1]} = 'set' ]] && [[ ${subcommands[2]} = 'image' ]]; then
        awk '{ printf "%s=%s", $1, $2 }'
        return
    fi

    awk '{ print $1 }'
}

_fzf_complete_kubectl-ports() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        kubectl get "$resource" "$name" ${(Q)${(z)kubectl_arguments}} -o jsonpath='PORT PROTOCOL NAME{"\n"}{range ..ports[*]}{.targetPort} {.containerPort} {.protocol} {.name}{"\n"}{end}' 2> /dev/null |
        awk '{ print $1, $2, $3 }' |
        _fzf_complete_tabularize $fg[yellow] $reset_color
    )
}

_fzf_complete_kubectl-ports_post() {
    awk '{ print $1 }'
}

_fzf_complete_kubectl-annotations() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --read0 --print0 --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <({
        kubectl get "$resource" "$name" ${(Q)${(z)kubectl_arguments}} -o jsonpath='{.metadata.annotations}' | jq -jr 'to_entries | map("\(.key)=\(.value)") | join("\u0000")'
    } 2> /dev/null)
}

_fzf_complete_kubectl-annotations_post() {
    local item first=1
    local input=$(cat)

    for item in ${(0)input}; do
        if [[ -z $first ]]; then
            echo
        fi

        echo -n ${item%=*}=${${(q+)item#*=}//\\n/\\\\n}
        first=
    done
}

_fzf_complete_kubectl-selectors() {
    local fzf_options=$1
    shift

    if [[ -z $namespace ]]; then
        kubectl_arguments+=(--all-namespaces)
    fi

    if [[ ${subcommands[1]} = 'taint' ]]; then
        resource=nodes
    elif [[ ${subcommands[1]} = 'top' ]] && [[ -z $resource ]]; then
        return
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        _fzf_complete_tabularize $fg[yellow] < <(cat \
            <(echo KEY VALUE) \
            <({
                kubectl get "${resource:-all}" ${(Q)${(z)kubectl_arguments}} -o jsonpath='{.items[*].metadata.labels}' | jq --slurp -r 'map(to_entries[] | "\(.key) \(.value)") | flatten | sort | unique[]'
            } 2> /dev/null) \
        )
    )
}

_fzf_complete_kubectl-selectors_post() {
    if [[ $prefix_option = *! ]]; then
        awk '{ print $1 }'
    else
        awk '{
            exectuted = 1
            printf "%s%s=%s", (NR > 1 ? "," : ""), $1, $2
        }'
    fi
}

_fzf_complete_kubectl-label-columns() {
    local fzf_options=$1
    shift

    if [[ -z $namespace ]]; then
        kubectl_arguments+=(--all-namespaces)
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        _fzf_complete_tabularize $fg[yellow] < <(cat \
            <(echo KEY VALUES) \
            <({
                kubectl get "$resource" ${(Q)${(z)kubectl_arguments}} -o jsonpath='{.items[*].metadata.labels}' | jq --slurp -r 'map(to_entries[]) | group_by(.key) | map("\(first | .key) \(map(.value) | unique | join(", "))")[]'
            } 2> /dev/null) \
        )
    )
}

_fzf_complete_kubectl-label-columns_post() {
    awk '{ print $1 }'
}

_fzf_complete_kubectl-labels() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        _fzf_complete_tabularize $fg[yellow] < <(cat \
            <(echo KEY VALUE) \
            <({
                kubectl get "$resource" "$name" ${(Q)${(z)kubectl_arguments}} -o jsonpath='{.metadata.labels}' | jq -r 'to_entries[] | "\(.key) \(.value)"'
            } 2> /dev/null) \
        )
    )
}

_fzf_complete_kubectl-labels_post() {
    awk '{ printf "%s%s=%s", (NR > 1 ? "\n" : ""), $1, $2 }'
}

_fzf_complete_kubectl-taints() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        _fzf_complete_tabularize $fg[yellow] $reset_color < <(cat \
            <(echo KEY VALUE EFFECT) \
            <(kubectl get "$resource" "$name" ${(Q)${(z)kubectl_arguments}} -o jsonpath='{range .spec.taints[*]}{.key} {.value} {.effect}{"\n"}{end}' 2> /dev/null)
        )
    )
}

_fzf_complete_kubectl-taints_post() {
    awk '{ printf "%s%s=%s:%s", (NR > 1 ? "\n" : ""), $1, $2, $3 }'
}

_fzf_complete_kubectl-resource-names() {
    local fzf_options=$1
    shift

    if [[ -z $namespace ]]; then
        kubectl_arguments+=(--all-namespaces)
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(
        local result=$(kubectl get "$resource" -o wide ${(Q)${(z)kubectl_arguments}} 2> /dev/null)
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
