#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_kubectl() {
    setopt local_options no_aliases
    local command_pos=$(_fzf_complete_get_command_pos "$@")
    local arguments=("${(Q)${(z)"$(_fzf_complete_trim_env "$command_pos" "$@")"}[@]}")
    local options_and_subcommand=()
    local kubectl_arguments=()
    local last_argument=${arguments[-1]}
    local prefix_option completing_option subcommands namespace resource resource_suffix resource_apiversion_option name

    if (( $command_pos > 1 )); then
        local -x "${(e)${(z)"$(_fzf_complete_get_env "$command_pos" "$@")"}[@]}"
    fi

    local kubectl_inherited_options_argument_required=(
        --as
        --as-group
        --certificate-authority
        --client-certificate
        --client-key
        --cluster
        --context
        --field-selector
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

    local kubectl_options_argument_required=(
        $kubectl_inherited_options_argument_required
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
    local kubectl_options_argument_optional=(
        --add-dir-header
        --alsologtostderr
        --disable-root-cgroup-stats
        --docker-only
        --docker-tls
        --enable-load-reader
        --insecure-skip-tls-verify
        --log-cadvisor-usage
        --logtostderr
        --match-server-version
        --one-output
        --skip-headers
        --skip-log-headers
        --storage-driver-secure
        --version
        --warnings-as-errors
    )

    options_and_subcommand=("${(Q)${(z)"$(_fzf_complete_kubectl_parse_global_options_and_subcommand "${(F)kubectl_options_argument_optional}" "${arguments[@]}")"}[@]}")
    subcommands=("${options_and_subcommand[-1]}")
    arguments=(
        "${arguments[1,1][@]}"
        "${subcommands[1,1][@]}"
        "${options_and_subcommand[1,-2][@]}"
        "${arguments[${#options_and_subcommand}+2,-1][@]}"
    )

    if (( $+functions[_fzf_complete_kubectl_${subcommands[1]}] )) && _fzf_complete_kubectl_${subcommands[1]} "$@"; then
        return
    fi

    if [[ ${subcommands[1]} = (apply|auth|certificate|config|create|rollout|set) ]]; then
        subcommands+=($(_fzf_complete_parse_argument 2 2 "${(F)kubectl_options_argument_required}" "${arguments[@]}" || :))
    fi

    if [[ ${subcommands[1]} = annotate ]]; then
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

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' "$@"
                return
            fi

            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' "$@"
                return
            fi

            _fzf_complete_kubectl-annotations '--multi' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = apply ]]; then
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

        _fzf_complete_kubectl_parse_resource_and_name 3
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]] && [[ ${#subcommands[@]} = 2 ]]; then
            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' "$@"
                return
            fi

            if [[ -z $name ]]; then
                if [[ ${subcommands[2]} = edit-last-applied ]]; then
                    _fzf_complete_kubectl-resource-names '' "$@"
                elif [[ ${subcommands[2]} = view-last-applied ]]; then
                    _fzf_complete_kubectl-resource-names '--multi' "$@"
                fi
            fi
            return
        fi
    fi

    if [[ ${subcommands[1]} = auth ]] && [[ ${subcommands[2]} = can-i ]]; then
        kubectl_options_argument_required+=(--subresource)

        local auth_verbs=(
            create
            delete
            deletecollection
            get
            list
            patch
            update
            watch
        )

        local verb
        verb=$(_fzf_complete_parse_argument 2 3 "${(F)kubectl_options_argument_required}" "${arguments[@]}" || :)

        _fzf_complete_kubectl_parse_resource_and_name 4
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ -z $verb ]]; then
                _fzf_complete_constants '' "${(F)auth_verbs}" "$@"
                return
            fi

            if [[ -z $resource ]]; then
                resource_suffix=/
                _fzf_complete_kubectl-resources '' "$@"
                return
            fi

            _fzf_complete_kubectl-resource-names '' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = (autoscale|edit|expose|patch) ]]; then
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

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' "$@"
                return
            fi

            _fzf_complete_kubectl-resource-names '' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = certificate ]] && [[ ${subcommands[2]} = (approve|deny) ]]; then
        kubectl_options_argument_required+=(
            -f
            --filename
            -k
            --kustomize
            -o
            --output
            --template
        )

        _fzf_complete_kubectl_parse_resource_and_name 3
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        resource=certificatesigningrequests.certificates.k8s.io
        _fzf_complete_kubectl-resource-names '--multi' "$@"
        return
    fi

    if [[ ${subcommands[1]} = config ]]; then
        if [[ ${subcommands[2]} = (delete-cluster|delete-context|delete-user|rename-context|set-cluster|set-context|use-context) ]] ; then
            _fzf_complete_kubectl_parse_resource_and_name 2
            _fzf_complete_kubectl_parse_completing_option
            _fzf_complete_kubectl_parse_kubectl_arguments

            if [[ -z $completing_option ]]; then
                _fzf_complete_kubectl-configs '' "get-${subcommands[2]#*-}s" "$@"
                return
            fi
        fi

        if [[ ${subcommands[2]} = get-contexts ]]; then
            kubectl_options_argument_required+=(
                -o
                --output
            )

            _fzf_complete_kubectl_parse_resource_and_name 2
            _fzf_complete_kubectl_parse_completing_option
            _fzf_complete_kubectl_parse_kubectl_arguments

            if [[ -z $completing_option ]]; then
                _fzf_complete_kubectl-configs '' 'get-contexts' "$@"
                return
            fi
        fi

        if [[ ${subcommands[2]} = set-credentials ]]; then
            kubectl_options_argument_required+=(
                --auth-provider
                --auth-provider-arg
                --exec-api-version
                --exec-arg
                --exec-command
                --exec-env
            )

            if [[ -z $completing_option ]]; then
                _fzf_complete_kubectl-configs '' 'get-users' "$@"
                return
            fi
        fi
    fi

    if [[ ${subcommands[1]} = (cordon|drain|uncordon) ]]; then
        kubectl_options_argument_required+=(
            --dry-run
            --grace-period
            -l
            --pod-selector
            --selector
            --skip-wait-for-delete-timeout
            --timeout
        )

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $resource ]]; then
            resource=nodes
        fi

        if [[ -z $completing_option ]]; then
            _fzf_complete_kubectl-resource-names '' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = create ]]; then
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

        _fzf_complete_kubectl_parse_resource_and_name 3
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ ${subcommands[2]} = job ]]; then
            if [[ $completing_option = --from ]]; then
                prefix=${prefix##*/}
                prefix_option=${prefix_option##*/}cronjob/
                resource=cronjob
                _fzf_complete_kubectl-resource-names '' "$@"
                return
            fi
        fi

        if [[ -z $completing_option ]]; then
            _fzf_complete_constants '' "${(F)set_subcommands}" "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = debug ]]; then
        kubectl_options_argument_required+=(
            -c
            --container
            --copy-to
            --env
            --image
            --image-pull-policy
            --set-image
            --target
        )

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                resource_suffix=/
                _fzf_complete_kubectl-resources '' "$@"
                return
            fi

            _fzf_complete_kubectl-resource-names '' "$@"
            return
        fi

        if [[ -n $resource ]] && [[ -z $name ]]; then
            name=$resource
            resource=pods
        fi

        if [[ $completing_option = --target ]]; then
            _fzf_complete_kubectl-containers '' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = (delete|describe|get|scale|wait) ]]; then
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

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $resource ]] && [[ ${subcommands[1]} = scale ]]; then
            resource=deployments,replicaset,replicationcontrollers,statefulset
        fi

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                if [[ ${subcommands[1]} = (delete|get) ]]; then
                    _fzf_complete_kubectl-resources '--multi' "$@"
                else
                    _fzf_complete_kubectl-resources '' "$@"
                fi
                return
            fi

            _fzf_complete_kubectl-resource-names '--multi' "$@"
            return
        fi

        if [[ ${subcommands[1]} = get ]] && [[ $completing_option = (-L|--label-columns) ]]; then
            if [[ $prefix = *,[^,]# ]]; then
                local label_columns=${prefix%,*},
                prefix_option=$prefix_option$label_columns
                prefix=${prefix#$label_columns}
            fi

            _fzf_complete_kubectl-label-columns '--multi' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = exec ]]; then
        kubectl_options_argument_required+=(
            -c
            --container
            -f
            --filename
            --pod-running-timeout
        )

        _fzf_complete_kubectl_parse_resource_and_name 2

        if [[ -z $name ]] && [[ -z $prefix_option ]]; then
            name=$resource
            resource=pods
        fi

        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            _fzf_complete_kubectl-resource-names '' "$@"
            return
        fi

        if [[ $completing_option = (-c|--container) ]]; then
            _fzf_complete_kubectl-containers '' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = explain ]]; then
        kubectl_options_argument_required+=(--api-version)
        kubectl_inherited_options_argument_required+=(--api-version)

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ $prefix = *.* ]]; then
                resource=${prefix%.*}
                prefix_option=$resource.
                prefix=${prefix#$prefix_option}
                _fzf_complete_kubectl-resource-fields '' "$@"
                return
            fi

            resource_apiversion_option=--api-version=
            resource_suffix=.
            _fzf_complete_kubectl-resources '' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = label ]]; then
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

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' "$@"
                return
            fi

            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' "$@"
                return
            fi

            _fzf_complete_kubectl-labels '--multi' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = logs ]]; then
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

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                resource_suffix=/
                _fzf_complete_kubectl-resources '' "$@"
                return
            fi

            _fzf_complete_kubectl-resource-names '' "$@"
            return
        fi

        if [[ -n $resource ]] && [[ -z $name ]]; then
            name=$resource
            resource=pods
        fi

        if [[ $completing_option = (-c|--container) ]]; then
            _fzf_complete_kubectl-containers '' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = port-forward ]]; then
        kubectl_options_argument_required+=(
            --address
            --pod-running-timeout
        )

        _fzf_complete_kubectl_parse_resource_and_name 2

        if [[ -z $name ]] && [[ -z $prefix_option ]]; then
            name=$resource
            resource=pods
        fi

        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' "$@"
                return
            fi

            prefix_option=${prefix/:*/:}
            prefix=${prefix#$prefix_option}
            _fzf_complete_kubectl-ports '--multi' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = rollout ]]; then
        _fzf_complete_kubectl_parse_resource_and_name 3
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ ${#subcommands[@]} != 2 ]]; then
                local rollout_subcommands=(history pause restart resume status undo)
                _fzf_complete_constants '' "${(F)rollout_subcommands}" "$@"
                return
            fi

            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' "$@"
                return
            fi

            _fzf_complete_kubectl-resource-names '--multi' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = set ]]; then
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

        _fzf_complete_kubectl_parse_resource_and_name 3
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ ${#subcommands[@]} != 2 ]]; then
                local set_subcommands=(env image resources selector serviceaccount subject)
                _fzf_complete_constants '' "${(F)set_subcommands}" "$@"
                return
            fi

            if [[ -z $resource ]]; then
                _fzf_complete_kubectl-resources '' "$@"
                return
            fi

            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' "$@"
                return
            fi

            if [[ ${subcommands[2]} = image ]]; then
                _fzf_complete_kubectl-containers '--multi' "$@"
                return
            fi
            return
        fi
    fi

    if [[ ${subcommands[1]} = taint ]]; then
        kubectl_options_argument_required+=(
            --dry-run
            --field-manager
            -l
            -o
            --output
            --selector
            --template
        )

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                local taint_resources=(nodes)
                _fzf_complete_constants '' "${(F)taint_resources}" "$@"
                return
            fi

            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' "$@"
                return
            fi

            _fzf_complete_kubectl-taints '--multi' "$@"
            return
        fi
    fi

    if [[ ${subcommands[1]} = top ]]; then
        kubectl_options_argument_required+=(
            -l
            --selector
            --sort-by
        )

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $completing_option ]]; then
            if [[ -z $resource ]]; then
                local top_resources=(nodes pods)
                _fzf_complete_constants '' "${(F)top_resources}" "$@"
                return
            fi

            if [[ -z $name ]]; then
                _fzf_complete_kubectl-resource-names '' "$@"
                return
            fi
            return
        fi
    fi

    if [[ ${subcommands[1]} = (diff|run|) ]]; then
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

        _fzf_complete_kubectl_parse_resource_and_name 2
        _fzf_complete_kubectl_parse_completing_option
        _fzf_complete_kubectl_parse_kubectl_arguments

        if [[ -z $resource ]] && [[ ${subcommands[1]} = run ]]; then
            resource=pods
        fi
    fi

    if [[ $completing_option = (--cluster|--context|--user) ]]; then
        _fzf_complete_kubectl-configs '' "get-${completing_option#--}s" "$@"
        return
    fi

    if [[ $completing_option = (-n|--namespace) ]]; then
        kubectl_arguments[${kubectl_arguments[(i)-l]},${kubectl_arguments[(i)-l]}+1]=()
        kubectl_arguments[${kubectl_arguments[(i)--selector]},${kubectl_arguments[(i)--selector]}+1]=()
        kubectl_arguments=("${(@)kubectl_arguments:#-l*}")
        kubectl_arguments=("${(@)kubectl_arguments:#--selector*}")
        kubectl_arguments=("${(@)kubectl_arguments:#-n}")
        kubectl_arguments=("${(@)kubectl_arguments:#--namespace=}")

        resource=namespaces
        _fzf_complete_kubectl-resource-names '' "$@"
        return
    fi

    if [[ $completing_option = (-l|--labels|--selector|--field-selector) ]]; then
        local selector_type='selectors'
        if [[ $completing_option = --field-selector ]]; then
            selector_type='field-selectors'
        fi

        if [[ $prefix = *,[^,!=]# ]]; then
            local selector=${prefix%,*},
            prefix_option=$prefix_option$selector
            prefix=${prefix#$selector}
        fi

        if [[ $prefix = *![^,!=]# ]]; then
            local selector=${prefix%!*}!
            prefix_option=$prefix_option$selector
            prefix=${prefix#$selector}
        fi

        if [[ $prefix = *=[^,!=]# ]]; then
            local selector=${prefix%=*}=
            prefix_option=$prefix_option$selector
            prefix=${prefix#$selector}
            _fzf_complete_kubectl-$selector_type '' "$@"
            return
        fi

        _fzf_complete_kubectl-$selector_type '--multi' "$@"
        return
    fi

    if [[ $completing_option = (-f|--filename) ]]; then
        if [[ $last_argument = (-[^-]#f|--filename) ]]; then
            __fzf_generic_path_completion "$prefix" "$@" _fzf_compgen_path '' '' ' '
            return
        fi

        __fzf_generic_path_completion "${prefix#$prefix_option}" "$@$prefix_option" _fzf_compgen_path '' '' ' '
        return
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_kubectl-configs() {
    local fzf_options=$1
    local config_subcommand=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        local result=$(kubectl config "$config_subcommand" "${kubectl_arguments[@]}" 2> /dev/null)
        if [[ $result = CURRENT\ * ]]; then
            _fzf_complete_colorize $fg[green] $fg[yellow]
        else
            _fzf_complete_colorize $fg[yellow]
        fi <<< "$result"
    )
}

_fzf_complete_kubectl-configs_post() {
    awk '
        NF == 1 || $1 != "*" {
            print $1
        }
        $1 == "*" {
            print $2
        }
    '
}

_fzf_complete_kubectl-resources() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        kubectl api-resources --cached --verbs=get "${kubectl_arguments[@]}" 2> /dev/null |
        _fzf_complete_colorize $fg[yellow]
    )
}

_fzf_complete_kubectl-resources_post() {
    awk \
        -v resource_apiversion_option=$resource_apiversion_option \
        -v resource_suffix=$resource_suffix '
        NF == 4 {
            apiversion = $2
        }
        NF == 5 {
            apiversion = $3
        }
        NR > 1 && resource_suffix == "" {
            printf ","
        }
        {
            if (resource_apiversion_option) {
                name = $NF
                printf "%s%s %s%s", resource_apiversion_option, apiversion, name, resource_suffix
            } else {
                name = $1
                gsub(/^[^\/]+$|\/.*$/, "", apiversion)
                printf "%s%s%s%s", name, (apiversion ? "." : ""), apiversion, resource_suffix
            }
        }
        END {
            if (NR > 0 && resource_suffix == "") {
                printf "\n"
            }
        }
    '
}

_fzf_complete_kubectl-resource-fields() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <({
        echo TYPE FIELD
        kubectl explain --recursive "$resource" "${kubectl_arguments[@]}" 2> /dev/null | awk '
            NF != 2 || !/<.+>$/ {
                next
            }
            match($0, /^ +/) {
                level = RLENGTH
                gsub(/[ \t]+|>/, "")
                gsub(/</, " ")

                if (min_width == 0 || min_width > level) {
                    min_width = level
                }
                indentation = level / min_width
            }
            {
                fields[indentation] = $0

                internal_type = $0
                gsub(/.* /, "", internal_type)
                printf "%s ", internal_type

                for (i = 1; i <= indentation; i++) {
                    value = fields[i]
                    gsub(/ .*/, "", value)
                    printf "%s%s", (i > 1 ? "." : ""), value
                }
                printf "\n"
            }
        '
    } | _fzf_complete_tabularize $fg[green] $fg[yellow])
}

_fzf_complete_kubectl-resource-fields_post() {
    awk '{ printf "%s.", $2 }'
}

_fzf_complete_kubectl-resource-names() {
    local fzf_options=$1
    shift

    if [[ ${+namespace} = 0 ]]; then
        kubectl_arguments+=(--all-namespaces)
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        local result=$(kubectl get "$resource" -o wide "${kubectl_arguments[@]}" 2> /dev/null)
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

_fzf_complete_kubectl-containers() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <({
        echo NAME IMAGE
        kubectl get "$resource" "$name" "${kubectl_arguments[@]}" -o jsonpath='{range ..initContainers[*]}{.name} {.image}{"\n"}{end}' 2> /dev/null
        kubectl get "$resource" "$name" "${kubectl_arguments[@]}" -o jsonpath='{range ..containers[*]}{.name} {.image}{"\n"}{end}' 2> /dev/null
    } | _fzf_complete_tabularize $fg[yellow])
}

_fzf_complete_kubectl-containers_post() {
    setopt local_options no_ksh_arrays

    if [[ ${subcommands[1]} = set ]] && [[ ${subcommands[2]} = image ]]; then
        awk '{ printf "%s=%s\n", $1, $2 }'
        return
    fi

    awk '{ print $1 }'
}

_fzf_complete_kubectl-ports() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        kubectl get "$resource" "$name" "${kubectl_arguments[@]}" -o jsonpath='PORT PROTOCOL NAME{"\n"}{range ..ports[*]}{.targetPort} {.containerPort} {.protocol} {.name}{"\n"}{end}' 2> /dev/null |
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

    _fzf_complete --ansi --read0 --print0 --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <({
        kubectl get "$resource" "$name" "${kubectl_arguments[@]}" -o jsonpath='{.metadata.annotations}' | jq -jr 'to_entries | map("\(.key)=\(.value)") | join("\u0000")'
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

_fzf_complete_kubectl-labels() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        _fzf_complete_tabularize $fg[yellow] < <({
            echo KEY VALUE
            kubectl get "$resource" "$name" "${kubectl_arguments[@]}" -o jsonpath='{.metadata.labels}' |
                jq -r 'to_entries[] | "\(.key) \(.value)"'
        } 2> /dev/null)
    )
}

_fzf_complete_kubectl-labels_post() {
    awk '{ printf "%s%s=%s", (NR > 1 ? "\n" : ""), $1, $2 }'
}

_fzf_complete_kubectl-selectors() {
    local fzf_options=$1
    shift

    if [[ ${+namespace} = 0 ]]; then
        kubectl_arguments+=(--all-namespaces)
    fi

    if [[ $selector = *, ]]; then
        selector=${selector%,}
        kubectl_arguments+=(--selector=$selector)
    elif [[ $selector = *! ]]; then
        kubectl_arguments+=(--selector=${selector%,*})
    elif [[ $selector = *= ]]; then
        kubectl_arguments+=(--selector=${${${selector%=}%=}%%!})
        selector=${${${selector##*,}%%=*}%%!}
    fi

    if [[ ${subcommands[1]} = taint ]]; then
        resource=nodes
    elif [[ ${subcommands[1]} = top ]] && [[ -z $resource ]]; then
        return
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        _fzf_complete_tabularize $fg[yellow] < <({
            if [[ $prefix_option = *! ]]; then
                echo KEY VALUES
            else
                echo KEY VALUE
            fi

            kubectl get "${resource:-all}" "${kubectl_arguments[@]}" -o jsonpath='{.items[*].metadata.labels}' |
                if [[ $prefix_option = *! ]]; then
                    jq --slurp -r 'map(to_entries[]) | group_by(.key) | map("\(first | .key) \(map(.value) | unique | join(", "))")[]'
                elif [[ $prefix_option = *= ]] && [[ -n $selector ]]; then
                    jq --slurp -r --arg selector "$selector" 'map(to_entries[] | select(.key == $selector) | "\(.key) \(.value)") | flatten | sort | unique[]'
                else
                    jq --slurp -r 'map(to_entries[] | "\(.key) \(.value)") | flatten | sort | unique[]'
                fi
        } 2> /dev/null)
    )
}

_fzf_complete_kubectl-selectors_post() {
    if [[ $prefix_option = *! ]]; then
        awk '{ printf "%s%s", (NR > 1 ? ",\\!" : ""), $1 }'
    elif [[ $prefix_option = *= ]] && [[ -n $selector ]]; then
        awk '{ printf "%s%s", (NR > 1 ? ",\\!" : ""), $2 }'
    else
        awk '{ printf "%s%s=%s", (NR > 1 ? "," : ""), $1, $2 }'
    fi
}

_fzf_complete_kubectl-field-selectors() {
    local fzf_options=$1
    shift

    if [[ ${+namespace} = 0 ]]; then
        kubectl_arguments+=(--all-namespaces)
    fi

    if [[ $selector = *, ]]; then
        selector=${selector%,}
        kubectl_arguments+=(--field-selector=$selector)
    elif [[ $selector = *= ]]; then
        kubectl_arguments+=(--field-selector=${${selector%,*}%%*=})
        selector=${${${selector##*,}%%=*}%%!}
    fi

    local labels
    case ${resource:l} in
        sts|statefulset|statefulsets| \
        sts.apps|statefulset.apps|statefulsets.apps| \
        cj|cronjob|cronjobs|job|jobs|jobtemplate|jobtemplates| \
        cj.batch|cronjob.batch|cronjobs.batch|job.batch|jobs.batch|jobtemplate.batch|jobtemplates.batch)
            labels=(
                metadata.name
                metadata.namespace
                status.successful
            )
            ;;

        csr|certificatesigningrequest|certificatesigningrequests| \
        csr.certificates.k8s.io|certificatesigningrequest.certificates.k8s.io|certificatesigningrequests.certificates.k8s.io)
            labels=(
                metadata.name
                spec.signerName
            )
            ;;

        po|pod|pods)
            labels=(
                metadata.name
                metadata.namespace
                spec.host
                spec.nodeName
                spec.restartPolicy
                spec.schedulerName
                spec.serviceAccountName
                status.nominatedNodeName
                status.phase
                status.podIP
                status.podIPs
            )
            ;;

        no|node|nodes)
            labels=(
                metadata.name
                spec.unschedulable
            )
            ;;

        rc|replicationcontroller|replicationcontrollers)
            labels=(
                metadata.name
                metadata.namespace
                status.replicas
            )
            ;;

        ev|event|events)
            labels=(
                metadata.name
                metadata.namespace
                involvedObject.apiVersion
                involvedObject.fieldPath
                involvedObject.kind
                involvedObject.name
                involvedObject.namespace
                involvedObject.resourceVersion
                involvedObject.uid
                reason
                reportingComponent
                source
                type
            )
            ;;

        ns|namespace|namespaces)
            labels=(
                metadata.name
                status.phase
            )
            ;;

        secret|secrets)
            labels=(
                metadata.name
                metadata.namespace
                type
            )
            ;;

        event.events.k8s.io|events.events.k8s.io)
            labels=(
                metadata.name
                metadata.namespace
                reason
                regarding.apiVersion
                regarding.fieldPath
                regarding.kind
                regarding.name
                regarding.namespace
                regarding.resourceVersion
                regarding.uid
                reportingController
                type
            )
            ;;
    esac

    if [[ $prefix_option = *= ]] && [[ -n $selector ]]; then
        labels=($selector)
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        _fzf_complete_tabularize $fg[yellow] < <({
            echo KEY VALUE
            kubectl get "${resource:-all}" "${kubectl_arguments[@]}" -o jsonpath='{.items[*]}' |
                jq --slurp -r --arg labels "$labels" '
                    [[($labels | split(" ")), .] | combinations] |
                        map(
                            . as [$selector, $obj] |
                            "\($selector) \(
                                $obj |
                                getpath($selector | split(".")) // "" |

                                # It looks like "status.podIPs" is currently not supported but tries to handle anyway
                                # See: https://github.com/kubernetes/kubernetes/pull/94756
                                if type == "array" then
                                    map(.[]) | join("\\\\,")
                                else
                                    .
                                end
                            )"
                        ) |
                        sort |
                        unique[]
                '
        } 2> /dev/null)
    )
}

_fzf_complete_kubectl-field-selectors_post() {
    if [[ $prefix_option = *= ]] && [[ -n $selector ]]; then
        awk '{ printf "%s%s", (NR > 1 ? ",\\!" : ""), $2 }'
    else
        awk '{ printf "%s%s=%s", (NR > 1 ? "," : ""), $1, $2 }'
    fi
}

_fzf_complete_kubectl-label-columns() {
    local fzf_options=$1
    shift

    if [[ ${+namespace} = 0 ]]; then
        kubectl_arguments+=(--all-namespaces)
    fi

    if [[ $label_columns = *, ]]; then
        label_columns=${label_columns%,}
        kubectl_arguments+=(--label-columns=$label_columns)
    fi

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        _fzf_complete_tabularize $fg[yellow] < <({
            echo KEY VALUES
            kubectl get "$resource" "${kubectl_arguments[@]}" -o jsonpath='{.items[*].metadata.labels}' |
                jq --slurp -r 'map(to_entries[]) | group_by(.key) | map("\(first | .key) \(map(.value) | unique | join(", "))")[]'
        } 2> /dev/null)
    )
}

_fzf_complete_kubectl-label-columns_post() {
    awk '{ printf "%s%s", (NR > 1 ? "," : ""), $1 }'
}

_fzf_complete_kubectl-taints() {
    local fzf_options=$1
    shift

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        _fzf_complete_tabularize $fg[yellow] $reset_color < <(
            echo KEY VALUE EFFECT
            kubectl get "$resource" "$name" "${kubectl_arguments[@]}" -o jsonpath='{range .spec.taints[*]}{.key} {.value} {.effect}{"\n"}{end}' 2> /dev/null
        )
    )
}

_fzf_complete_kubectl-taints_post() {
    awk '{ printf "%s%s=%s:%s", (NR > 1 ? "\n" : ""), $1, $2, $3 }'
}

_fzf_complete_kubectl_parse_resource_and_name() {
    local resource_index=$1
    local name_index=$((resource_index + 1))
    shift

    resource=$(_fzf_complete_parse_argument 2 "$resource_index" "${(F)kubectl_options_argument_required}" "${arguments[@]}" || :)
    name=$(_fzf_complete_parse_argument 2 "$name_index" "${(F)kubectl_options_argument_required}" "${arguments[@]}" || :)

    if ! namespace=$(_fzf_complete_parse_option_arguments '-n' '--namespace' "${(F)kubectl_options_argument_required}" 'option argument' "${(Q)${(z)RBUFFER}[@]}") && \
        ! namespace=$(_fzf_complete_parse_option_arguments '-n' '--namespace' "${(F)kubectl_options_argument_required}" 'option argument' "${arguments[@]}"); then
        unset namespace
    fi

    if [[ $resource = */* ]]; then
        name=${resource#*/}
        resource=${resource%/*}
    elif [[ -z $resource ]] && [[ $prefix != -* ]]; then
        if [[ $prefix = *,* ]]; then
            prefix_option=${prefix%,*},
            prefix=${prefix#$prefix_option}
        elif [[ $prefix = */* ]]; then
            resource=${prefix%/*}
            prefix_option=${prefix%/*}/
            prefix=${prefix#$prefix_option}
        fi
    fi
}

_fzf_complete_kubectl_parse_completing_option() {
    if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)kubectl_options_argument_required}" "${(F)kubectl_options_argument_optional}"); then
        if [[ $completing_option = --* ]]; then
            prefix_option=$completing_option=
        else
            prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
        fi
        prefix=${prefix#$prefix_option}
    fi
}

_fzf_complete_kubectl_parse_kubectl_arguments() {
    local inherit_values
    local all_options=($kubectl_inherited_options_argument_required $kubectl_inherited_options)
    local shorts=(${all_options:#--*})
    local longs=(${all_options:#-[a-zA-Z0-9]})

    if inherit_values=$(_fzf_complete_parse_option_arguments "$shorts" "$longs" "${(F)kubectl_options_argument_required}" 'option argument' "${arguments[@]}"); then
        kubectl_arguments+=("${(Q)${(z)inherit_values}[@]}")
    fi

    if inherit_values=$(_fzf_complete_parse_option_arguments "$shorts" "$longs" "${(F)kubectl_options_argument_required}" 'option argument' "${(Q)${(z)RBUFFER}[@]}"); then
        kubectl_arguments+=("${(Q)${(z)inherit_values}[@]}")
    fi
}

_fzf_complete_kubectl_parse_global_options_and_subcommand() {
    local options_argument_optional=(${(z)1})
    shift

    local i parsing_argument parsing_subcommand
    local command_arguments=()
    local start_index=2
    local arguments=("$@")

    for i in {$start_index..${#arguments}}; do
        if [[ -n $parsing_argument ]]; then
            parsing_argument=
            command_arguments+=("${arguments[$i]}")
            continue
        fi

        if [[ ${arguments[$i]} = -[A-Za-z0-9] ]] || [[ ${arguments[$i]} = --[A-Za-z0-9-](#c1,) ]]; then
            if [[ ${options_argument_optional[(r)$arguments[$i]]} = ${arguments[$i]} ]]; then
                parsing_argument=
            else
                parsing_argument=1
            fi
            command_arguments+=("${arguments[$i]}")
            continue
        fi

        if [[ ${arguments[$i]} = -(#c1,2)* ]]; then
            parsing_argument=
            command_arguments+=("${arguments[$i]}")
            continue
        fi

        parsing_subcommand=1
        command_arguments+=("${arguments[$i]}")
        break
    done

    if [[ -n $parsing_subcommand ]]; then
        echo ${(q)command_arguments}
    fi
}
