#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_cf() {
    setopt local_options no_aliases
    local command_pos=$(_fzf_complete_get_command_pos "$@")
    local arguments=("${(Q)${(z)"$(_fzf_complete_trim_env "$command_pos" "$@")"}[@]}")
    local cf_arguments=()
    local last_argument=${arguments[-1]}
    local prefix_option completing_option resource resource_column=1

    if (( $command_pos > 1 )); then
        local -x "${(e)${(z)"$(_fzf_complete_get_env "$command_pos" "$@")"}[@]}"
    fi

    local cf=${arguments[1]}
    local cf_version=$("$cf" --version 2> /dev/null | awk '{ print int($3) }')

    local cf_options_argument_required=()
    local subcommand=$(_fzf_complete_parse_argument 2 1 "${(F)cf_options_argument_required}" "${arguments[@]}")

    if (( $+functions[_fzf_complete_cf_${subcommand}] )) && _fzf_complete_cf_${subcommand} "$@"; then
        return
    fi

    if [[ $subcommand = (app|cancel-deployment|d|delete|disable-ssh|droplets|e|enable-ssh|env|events|get-health-check|logs|packages|rename|sp|ssh-enabled|st|start|stop|tasks|v3-delete|v3-droplets|v3-env|v3-get-health-check|v3-packages|v3-restart|v3-start|v3-stop) ]]; then
        resource=apps
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (add-network-policy|remove-network-policy) ]]; then
        cf_options_argument_required+=(
            -o
            --port
            --protocol
            -s
        )

        if [[ $cf_version = 6 ]]; then
            cf_options_argument_required+=(
                --destination-app
            )
        fi

        _fzf_complete_cf_parse_completing_option

        local source_app
        if ! source_app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            if [[ $subcommand = add-network-policy ]]; then
                resource=apps
            else
                resource=network-policies
            fi
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -o ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -s ]]; then
            local org_name

            if org_name=$(_fzf_complete_parse_option_arguments '-o' '' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}"); then
                _fzf_complete_cf-spaces-by-org '' "$org_name" "$@"
                return
            fi

            resource=spaces
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $cf_version = 6 ]]; then
            if [[ $completing_option != --destination-app ]]; then
                return
            fi
        else
            local destination_app
            if destination_app=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") || [[ -n $completing_option ]]; then
                return
            fi
        fi

        local org_name=$(_fzf_complete_parse_option_arguments '-o' '' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}")
        local space_name=$(_fzf_complete_parse_option_arguments '-s' '' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}")

        if [[ -n $space_name ]]; then
            _fzf_complete_cf-apps-by-org-space '' "$org_name" "$space_name" "$@"
            return
        fi

        resource=apps
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (bind-service|bs|unbind-service|ub) ]]; then
        if [[ $subcommand = b* ]]; then
            cf_options_argument_required+=(
                --binding-name
                -c
            )

            _fzf_complete_cf_parse_completing_option
        fi

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local service_instance
        if ! service_instance=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=services
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = copy-source ]]; then
        cf_options_argument_required+=(
            -o
            -s
        )

        if [[ $cf_version != 6 ]]; then
            cf_options_argument_required+=(
                --organization
                --space
                --strategy
            )
        fi

        _fzf_complete_cf_parse_completing_option

        local source_app
        if ! source_app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local target_app
        if ! target_app=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            local org_name=$(_fzf_complete_parse_option_arguments '-o' '--organization' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}")
            local space_name=$(_fzf_complete_parse_option_arguments '-s' '--space' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}")

            if [[ -n $space_name ]]; then
                _fzf_complete_cf-apps-by-org-space '' "$org_name" "$space_name" "$@"
                return
            fi

            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (-o|--organization) ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (-s|--space) ]]; then
            local org_name

            if org_name=$(_fzf_complete_parse_option_arguments '-o' '--organization' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}"); then
                _fzf_complete_cf-spaces-by-org '' "$org_name" "$@"
                return
            fi

            resource=spaces
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = create-app-manifest ]]; then
        cf_options_argument_required+=(
            -p
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -p ]]; then
            if [[ $last_argument = -[^-]#p ]]; then
                __fzf_generic_path_completion "$prefix" "$@" _fzf_compgen_path '' '' ' '
                return
            fi

            __fzf_generic_path_completion "${prefix#$prefix_option}" "$@$prefix_option" _fzf_compgen_path '' '' ' '
            return
        fi
    fi

    if [[ $subcommand = (f|files) ]]; then
        cf_options_argument_required+=(
            -i
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -i ]]; then
            _fzf_complete_cf-app-instances '' "$app" "$@"
            return
        fi
    fi

    if [[ $subcommand = (labels|set-label|unset-label) ]]; then
        local -A label_resource_commands=()

        cf_options_argument_required+=(
            -b
            --broker
            -e
            --offering
            -s
            --stack
        )

        _fzf_complete_cf_parse_completing_option

        if [[ $cf_version != 6 ]]; then
            label_resource_commands+=(
                app              apps
                buildpack        buildpacks
                domain           domains
                org              orgs
                route            routes
                service-broker   service-brokers
                service-offering marketplace
                service-plan     marketplace
                space            spaces
                stack            stacks
            )
        fi

        if [[ $cf_version = 8 ]]; then
            label_resource_commands+=(
                service-instance services
            )
        fi

        local service_broker=$(_fzf_complete_parse_option_arguments '-b' '--broker' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}")
        local service_offering=$(_fzf_complete_parse_option_arguments '-e' '--offering' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}")

        if [[ $completing_option = (-b|--broker) ]]; then
            resource=service-brokers
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (-e|--offering) ]]; then
            resource=marketplace
            if [[ $cf_version != 6 ]] && [[ -n $service_broker ]]; then
                cf_arguments+=(-b "$service_broker")
            fi
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (-s|--stack) ]]; then
            resource=stacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local label_resource
        if ! label_resource=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            _fzf_complete_constants '' "${(F)${(ko)label_resource_commands[@]}}" "$@"
            return
        fi

        local label_resource_name
        if ! label_resource_name=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=${label_resource_commands[$label_resource]}
            if [[ -z $resource ]]; then
                return
            fi

            case $label_resource in
                buildpack)
                    resource_column=2
                    ;;

                route)
                    resource_column=route-path
                    ;;

                service-plan)
                    if [[ -n $service_broker ]]; then
                        cf_arguments+=(-b "$service_broker")
                    fi

                    if [[ -n $service_offering ]]; then
                        cf_arguments+=(-e "$service_offering")
                    else
                        return
                    fi
                    ;;
            esac

            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (map-route|unmap-route) ]]; then
        cf_options_argument_required+=(
            --hostname
            -n
            --path
            --port
        )

        if [[ $cf_version = 8 ]] && [[ $subcommand = map-route ]]; then
            cf_options_argument_required+=(
                --destination-protocol
            )
        fi

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local domain
        if ! domain=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=routes
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (p|push) ]]; then
        cf_options_argument_required+=(
            -b
            -c
            --docker-image
            --docker-username
            --droplet
            -f
            --health-check-type
            -i
            -k
            -m
            -o
            -p
            -s
            -t
            -u
            --var
            --vars-file
        )

        if [[ $cf_version = 6 ]]; then
            cf_options_argument_required+=(
                -d
                --hostname
                -n
                --route-path
            )
        else
            cf_options_argument_required+=(
                --app-start-timeout
                --buildpack
                --disk
                --endpoint
                --instances
                --manifest
                --memory
                --path
                --stack
                --start-command
                --strategy
                --task
            )
        fi

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (-b|--buildpack) ]]; then
            resource=buildpacks
            resource_column=2
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -d ]]; then
            resource=domains
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (-s|--stack) ]]; then
            resource=stacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        _fzf_path_completion "$prefix" "$@"
        return
    fi

    if [[ $subcommand = (restage|restart|rg|rs) ]]; then
        if [[ $cf_version != 6 ]]; then
            cf_options_argument_required+=(
                --strategy
            )

            _fzf_complete_cf_parse_completing_option
        fi

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (restart-app-instance|v3-restart-app-instance) ]]; then
        if [[ $cf_version != 6 ]] || [[ $subcommand = v3* ]]; then
            cf_options_argument_required+=(
                --process
            )

            _fzf_complete_cf_parse_completing_option
        fi

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local index
        if ! index=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            _fzf_complete_cf-app-instances '' "$app" "$@"
            return
        fi
    fi

    if [[ $subcommand = (revision|rollback) ]]; then
        cf_options_argument_required+=(
            --version
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ -n $app ]] && [[ $completing_option = --version ]]; then
            resource=revisions
            cf_arguments+=("$app")
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (rt|run-task) ]]; then
        cf_options_argument_required+=(
            -k
            -m
            --name
        )

        if [[ $cf_version != 6 ]]; then
            cf_options_argument_required+=(
                -c
                --command
                --process
            )
        fi

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (se|set-env|ue|unset-env|v3-set-env|v3-unset-env) ]]; then
        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}"); then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        _fzf_complete_cf-envs '' "$app" "$@"
        return
    fi

    if [[ $subcommand = (scale|v3-scale) ]]; then
        if [[ $cf_version != 6 ]] || [[ $subcommand = v3* ]]; then
            cf_options_argument_required+=(
                --process
            )
        fi

        cf_options_argument_required+=(
            -i
            -k
            -m
        )

        if [[ $cf_version = 8 ]]; then
            cf_options_argument_required+=(
                --instances
            )
        fi

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (set-health-check|v3-set-health-check) ]]; then
        if [[ $cf_version != 6 ]] || [[ $subcommand = v3* ]]; then
            cf_options_argument_required+=(
                --invocation-timeout
                --process
            )
        fi

        cf_options_argument_required+=(
            --endpoint
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (ssh|v3-ssh) ]]; then
        if [[ $cf_version != 6 ]] || [[ $subcommand = v3* ]]; then
            cf_options_argument_required+=(
                --process
            )
        fi

        cf_options_argument_required+=(
            --app-instance-index
            -c
            --command
            -i
            -L
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (--app-instance-index|-i) ]]; then
            _fzf_complete_cf-app-instances '' "$app" "$@"
            return
        fi
    fi

    if [[ $subcommand = (create-package|v3-create-package) ]]; then
        cf_options_argument_required+=(
            --docker-image
            -o
            -p
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -p ]]; then
            if [[ $last_argument = -[^-]#p ]]; then
                __fzf_generic_path_completion "$prefix" "$@" _fzf_compgen_path '' '' ' '
                return
            fi

            __fzf_generic_path_completion "${prefix#$prefix_option}" "$@$prefix_option" _fzf_compgen_path '' '' ' '
            return
        fi
    fi

    if [[ $subcommand = download-droplet ]]; then
        cf_options_argument_required+=(
            --droplet
            -p
            --path
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ -n $app ]] && [[ $completing_option = --droplet ]]; then
            resource=droplets
            cf_arguments+=("$app")
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (-p|--path) ]]; then
            if [[ $last_argument = -[^-]#p ]]; then
                __fzf_generic_path_completion "$prefix" "$@" _fzf_compgen_path '' '' ' '
                return
            fi

            __fzf_generic_path_completion "${prefix#$prefix_option}" "$@$prefix_option" _fzf_compgen_path '' '' ' '
            return
        fi
    fi

    if [[ $subcommand = (set-droplet|v3-set-droplet) ]]; then
        if [[ $cf_version = 6 ]]; then
            cf_options_argument_required+=(
                -d
                --droplet-guid
            )

            _fzf_complete_cf_parse_completing_option
        fi

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $cf_version = 6 ]]; then
            if [[ -n $app ]] && [[ $completing_option = (-d|--droplet-guid) ]]; then
                resource=droplets
                cf_arguments+=("$app")
                _fzf_complete_cf-resources '' "$@"
                return
            fi
        else
            local droplet
            if [[ -n $app ]] && ! droplet=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
                resource=droplets
                cf_arguments+=("$app")
                _fzf_complete_cf-resources '' "$@"
                return
            fi
        fi
    fi

    if [[ $subcommand = (stage|stage-package|v3-stage) ]]; then
        cf_options_argument_required+=(
            --package-guid
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ -n $app ]] && [[ $completing_option = --package-guid ]]; then
            resource=packages
            cf_arguments+=("$app")
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = create-buildpack ]]; then
        local buildpack
        if ! buildpack=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            return
        fi

        local filepath
        if ! filepath=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            _fzf_path_completion "$prefix" "$@"
            return
        fi

        local position
        if ! position=$(_fzf_complete_parse_argument 2 4 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=buildpacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (delete-buildpack|rename-buildpack) ]]; then
        cf_options_argument_required+=(
            -s
        )

        if [[ $cf_version != 6 ]]; then
            cf_options_argument_required+=(
                --stack
            )
        fi

        _fzf_complete_cf_parse_completing_option

        local buildpack
        if ! buildpack=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=buildpacks
            resource_column=2
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (-s|--stack) ]]; then
            resource=stacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = update-buildpack ]]; then
        cf_options_argument_required+=(
            --assign-stack
            -i
            -p
            -s
        )

        if [[ $cf_version != 6 ]]; then
            cf_options_argument_required+=(
                --path
                --position
                --rename
                --stack
            )
        fi

        _fzf_complete_cf_parse_completing_option

        local buildpack
        if ! buildpack=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=buildpacks
            resource_column=2
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (--assign-stack|-s|--stack) ]]; then
            resource=stacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (-i|--position) ]]; then
            resource=buildpacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (-p|--path) ]]; then
            if [[ $last_argument = -[^-]#p ]]; then
                __fzf_generic_path_completion "$prefix" "$@" _fzf_compgen_path '' '' ' '
                return
            fi

            __fzf_generic_path_completion "${prefix#$prefix_option}" "$@$prefix_option" _fzf_compgen_path '' '' ' '
            return
        fi
    fi

    if [[ $subcommand = (delete-domain|delete-private-domain|delete-shared-domain) ]]; then
        resource=domains
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (bind-route-service|brs|unbind-route-service|urs) ]]; then
        if [[ $subcommand = u* ]]; then
            cf_options_argument_required+=(
                -c
            )
        fi

        cf_options_argument_required+=(
            --hostname
            -n
            --path
        )

        _fzf_complete_cf_parse_completing_option

        local domain
        if ! domain=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=routes
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local service_instance
        if ! service_instance=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=services
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = check-route ]]; then
        cf_options_argument_required+=(
            --path
        )

        if [[ $cf_version != 6 ]]; then
            cf_options_argument_required+=(
                --hostname
                -n
                --port
            )
        fi

        _fzf_complete_cf_parse_completing_option

        local domain_index=2
        if [[ $cf_version = 6 ]]; then
            domain_index=3

            local host
            if ! host=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
                return
            fi
        fi

        local domain
        if ! domain=$(_fzf_complete_parse_argument 2 "$domain_index" "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=domains
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (delete-route|ro|route) ]]; then
        cf_options_argument_required+=(
            --hostname
            -n
            --path
            --port
        )

        _fzf_complete_cf_parse_completing_option

        local domain
        if ! domain=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=routes
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (disable-feature-flag|enable-feature-flag|feature-flag) ]]; then
        resource=feature-flags
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = delete-isolation-segment ]]; then
        resource=isolation-segments
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (m|marketplace) ]]; then
        local service_offering_option=-e
        if [[ $cf_version = 6 ]]; then
            service_offering_option=-s
        fi

        cf_options_argument_required+=(
            $service_offering_option
        )

        if [[ $cf_version != 6 ]]; then
            cf_options_argument_required+=(
                -b
            )
        fi

        _fzf_complete_cf_parse_completing_option

        if [[ $completing_option = $service_offering_option ]]; then
            resource=marketplace
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -b ]]; then
            resource=service-brokers
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (cs|create-service) ]]; then
        cf_options_argument_required+=(
            -b
            -c
            -t
        )

        _fzf_complete_cf_parse_completing_option

        if [[ $completing_option = -b ]]; then
            resource=service-brokers
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local service
        if ! service=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=marketplace
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local plan
        if [[ -n $service ]] && ! plan=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=marketplace
            if [[ $cf_version = 6 ]]; then
                cf_arguments+=(-s "$service")
            else
                cf_arguments+=(-e "$service")

                local service_broker
                if service_broker=$(_fzf_complete_parse_option_arguments '-b' '' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}"); then
                    cf_arguments+=(-b "$service_broker")
                fi
            fi

            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (disable-service-access|enable-service-access) ]]; then
        cf_options_argument_required+=(
            -b
            -o
            -p
        )

        _fzf_complete_cf_parse_completing_option

        local service
        if ! service=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=marketplace
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -b ]]; then
            resource=service-brokers
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -o ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ -n $service ]] && [[ $completing_option = -p ]]; then
            resource=marketplace
            if [[ $cf_version = 6 ]]; then
                cf_arguments+=(-s "$service")
            else
                cf_arguments+=(-e "$service")

                local service_broker
                if service_broker=$(_fzf_complete_parse_option_arguments '-b' '' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}"); then
                    cf_arguments+=(-b "$service_broker")
                fi
            fi

            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = purge-service-offering ]]; then
        cf_options_argument_required+=(
            -b
        )

        if [[ $cf_version = 6 ]]; then
            cf_options_argument_required+=(
                -p
            )
        fi

        _fzf_complete_cf_parse_completing_option

        local service
        if ! service=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=marketplace
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -b ]]; then
            resource=service-brokers
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = service-access ]]; then
        cf_options_argument_required+=(
            -b
            -e
            -o
        )

        _fzf_complete_cf_parse_completing_option

        if [[ $completing_option = -b ]]; then
            resource=service-brokers
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -e ]]; then
            resource=marketplace
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -o ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (delete-org|org|org-users|rename-org|reset-org-default-isolation-segment) ]]; then
        resource=orgs
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (create-domain|create-private-domain) ]]; then
        local org
        if ! org=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (disable-org-isolation|enable-org-isolation|set-org-default-isolation-segment) ]]; then
        local org
        if ! org=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local isolation_segment
        if ! isolation_segment=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=isolation-segments
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = set-space-isolation-segment ]]; then
        local space
        if ! space=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=spaces
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local isolation_segment
        if ! isolation_segment=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=isolation-segments
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (set-org-role|unset-org-role) ]]; then
        if [[ $cf_version != 6 ]]; then
            cf_options_argument_required+=(
                --origin
            )

            _fzf_complete_cf_parse_completing_option
        fi

        local user
        if ! user=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            return
        fi

        local org
        if ! org=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (set-org-quota|set-quota) ]]; then
        local org
        if ! org=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local quota
        if ! quota=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=org-quotas
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (set-space-role|unset-space-role) ]]; then
        if [[ $cf_version != 6 ]]; then
            cf_options_argument_required+=(
                --origin
            )

            _fzf_complete_cf_parse_completing_option
        fi

        local user
        if ! user=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            return
        fi

        local org
        if ! org=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local space
        if ! space=$(_fzf_complete_parse_argument 2 4 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            _fzf_complete_cf-spaces-by-org '' "$org" "$@"
            return
        fi
    fi

    if [[ $subcommand = (share-private-domain|unshare-private-domain) ]]; then
        local org
        if ! org=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local domain
        if ! domain=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=domains
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = space-users ]]; then
        local org
        if ! org=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local space
        if ! space=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            _fzf_complete_cf-spaces-by-org '' "$org" "$@"
            return
        fi
    fi

    if [[ $subcommand = (t|target) ]]; then
        cf_options_argument_required+=(
            -o
            -s
        )

        _fzf_complete_cf_parse_completing_option

        if [[ $completing_option = -o ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -s ]]; then
            local org_name

            if org_name=$(_fzf_complete_parse_option_arguments '-o' '' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}"); then
                _fzf_complete_cf-spaces-by-org '' "$org_name" "$@"
                return
            fi

            resource=spaces
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = uninstall-plugin ]]; then
        resource=plugins
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (delete-org-quota|delete-quota|org-quota|quota) ]]; then
        resource=org-quotas
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (update-org-quota|update-quota) ]]; then
        cf_options_argument_required+=(
            -a
            -i
            -m
            -n
            -r
            --reserved-route-ports
            -s
        )

        _fzf_complete_cf_parse_completing_option

        local quota
        if ! quota=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=org-quotas
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = create-shared-domain ]]; then
        cf_options_argument_required+=(
            --router-group
        )

        _fzf_complete_cf_parse_completing_option

        if [[ $completing_option = --router-group ]]; then
            resource=router-groups
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (bind-running-security-group|unbind-running-security-group) ]]; then
        resource=running-security-groups
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (delete-security-group|security-group) ]]; then
        resource=security-groups
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (delete-service-broker|rename-service-broker) ]]; then
        resource=service-brokers
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = update-service-broker ]]; then
        local service_broker
        if ! service_broker=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=service-brokers
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (delete-service|ds|purge-service-instance|rename-service|service|service-keys|sk|upgrade-service) ]]; then
        resource=services
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (create-service-key|csk) ]]; then
        cf_options_argument_required+=(
            -c
        )

        _fzf_complete_cf_parse_completing_option

        local service_instance
        if ! service_instance=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=services
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (delete-service-key|dsk|service-key) ]]; then
        local service_instance
        if ! service_instance=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=services
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local service_key
        if ! service_key=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            _fzf_complete_cf-service-keys-by-service-instance '' "$service_instance" "$@"
            return
        fi
    fi

    if [[ $subcommand = (share-service|unshare-service) ]]; then
        cf_options_argument_required+=(
            -o
            -s
        )

        _fzf_complete_cf_parse_completing_option

        local service_instance
        if ! service_instance=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=services
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -o ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -s ]]; then
            local org_name

            if org_name=$(_fzf_complete_parse_option_arguments '-o' '' "${(F)cf_options_argument_required}" 'argument' "${arguments[@]}"); then
                _fzf_complete_cf-spaces-by-org '' "$org_name" "$@"
                return
            fi

            resource=spaces
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = update-service ]]; then
        cf_options_argument_required+=(
            -c
            -p
            -t
        )

        _fzf_complete_cf_parse_completing_option

        local service_instance
        if ! service_instance=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=services
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ -n $service_instance ]] && [[ $completing_option = -p ]]; then
            _fzf_complete_cf-service-plans-by-service-instance '' "$service_instance" "$@"
            return
        fi
    fi

    if [[ $subcommand = (delete-space-quota|space-quota) ]]; then
        resource=space-quotas
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = update-space-quota ]]; then
        cf_options_argument_required+=(
            -a
            -i
            -m
            -n
            -r
            --reserved-route-ports
            -s
        )

        _fzf_complete_cf_parse_completing_option

        local space_quota
        if ! space_quota=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=space-quotas
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (allow-space-ssh|disallow-space-ssh|rename-space|reset-space-isolation-segment|space|space-ssh-allowed) ]]; then
        resource=spaces
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = create-route ]]; then
        cf_options_argument_required+=(
            --hostname
            -n
            --path
            --port
        )

        _fzf_complete_cf_parse_completing_option

        local domain_index=2
        if [[ $cf_version = 6 ]]; then
            domain_index=3

            local space
            if ! space=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
                resource=spaces
                _fzf_complete_cf-resources '' "$@"
                return
            fi
        fi

        local domain
        if ! domain=$(_fzf_complete_parse_argument 2 "$domain_index" "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=domains
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (set-space-quota|unset-space-quota) ]]; then
        local space
        if ! space=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=spaces
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local space_quota
        if ! space_quota=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=space-quotas
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = stack ]]; then
        resource=stacks
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (bind-staging-security-group|unbind-staging-security-group) ]]; then
        resource=staging-security-groups
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = terminate-task ]]; then
        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}"); then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local task
        if ! task=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}"); then
            resource=tasks
            cf_arguments+=("$app")
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (update-user-provided-service|uups) ]]; then
        cf_options_argument_required+=(
            -l
            -p
            -r
            -t
        )

        _fzf_complete_cf_parse_completing_option

        local service_instance
        if ! service_instance=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=services
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ -n $service_instance ]] && [[ $completing_option = -p ]]; then
            if [[ $prefix = */* ]] && [[ $prefix != *{* ]]; then
                if [[ $last_argument = -[^-]#p ]]; then
                    __fzf_generic_path_completion "$prefix" "$@" _fzf_compgen_path '' '' ' '
                    return
                fi

                __fzf_generic_path_completion "${prefix#$prefix_option}" "$@$prefix_option" _fzf_compgen_path '' '' ' '
                return
            fi

            _fzf_complete_cf-user-provided-service-instance-credentials '--multi' "$service_instance" "$@"
            return
        fi
    fi

    _fzf_path_completion "$prefix" "$@"
}

_fzf_complete_cf-resources() {
    local fzf_options=$1
    shift

    if [[ $resource != (running-security-groups|staging-security-groups) ]]; then
        fzf_options+=(--header-lines=1)
    fi

    if [[ $cf_version = 6 ]]; then
        if [[ $resource = (droplets|packages) ]]; then
            resource=v3-$resource
        fi

        if [[ $resource = org-quotas ]]; then
            resource=quotas
        fi
    fi

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        "$cf" "$resource" "${cf_arguments[@]}" 2> /dev/null |
            awk -v resource=$resource '
                resource == "marketplace" { gsub(/^   /, "") }
                NR > 1 && !/^$|^TIP:|^broker: |^OK$/
                /^$/ && count++ { exit }
            ' |
            if [[ $resource = routes ]]; then
                _fzf_complete_colorize $fg[green] $fg[yellow] $fg[blue]
            else
                _fzf_complete_colorize $fg[yellow]
            fi
    )
}

_fzf_complete_cf-resources_post() {
    if [[ $resource = buildpacks ]]; then
        if [[ $resource_column = 1 ]]; then
            if [[ $cf_version != 6 ]]; then
                awk '{ print $1 }'
            else
                awk '{ print $2 }'
            fi
        elif [[ $resource_column = 2 ]]; then
            if [[ $cf_version != 6 ]]; then
                awk '{ print $2, "--stack=" $3 }'
            else
                awk '{ print $1, "-s", $6 }'
            fi
        fi
    elif [[ $resource = marketplace ]]; then
        if [[ -z ${cf_arguments[(r)-s|-e]} ]] && [[ -n ${cf_options_argument_required[(r)-b]} ]]; then
            if [[ -n $completing_option ]]; then
                awk '{ print $1, "-b", $NF }'
            else
                awk '{ print "-b", $NF, $1 }'
            fi
        else
            awk '{ print $1 }'
        fi
    elif [[ $resource = network-policies ]]; then
        if [[ $cf_version != 6 ]]; then
            awk '{ print $1, $2, "--protocol=" $3, "--port=" $4, "-o", $6, "-s", $5 }'
        else
            awk '{ print $1, "--destination-app=" $2, "--protocol=" $3, "--port=" $4, "-o", $6, "-s", $5 }'
        fi
    elif [[ $resource = routes ]]; then
        awk \
            -v resource_column=$resource_column '
            # space + domain + port + type/protocol + (app-protocol)
            # space + domain + port + type/protocol + (app-protocol) + apps
            # space + domain + port + type/protocol + (app-protocol) + service
            # space + domain + port + type/protocol + (app-protocol) + apps + service
            $3 ~ /^[0-9]+$/ {
                if (resource_column == "route-path") {
                    print $2 ":" $3
                } else {
                    print $2, "--port=" $3
                }
            }

            # space + host + domain + (protocol) + (app-protocol)
            # space + host + domain + (protocol) + (app-protocol) + apps
            # space + host + domain + (protocol) + (app-protocol) + service
            # space + host + domain + (protocol) + (app-protocol) + apps + serivce
            NF >= 3 && $2 !~ /\./ && $3 !~ /^[0-9]+$/ && $4 !~ /\// {
                if (resource_column == "route-path") {
                    print $2 "." $3
                } else {
                    print $3, "--hostname=" $2
                }
            }

            # space + host + domain + path + (protocol) + (app-protocol)
            # space + host + domain + path + (protocol) + (app-protocol) + apps
            # space + host + domain + path + (protocol) + (app-protocol) + service
            # space + host + domain + path + (protocol) + (app-protocol) + apps + service
            NF >= 4 && $2 !~ /\./ && $3 !~ /^[0-9]+$/ && $4 ~ /\// {
                if (resource_column == "route-path") {
                    print $2 "." $3 $4
                } else {
                    print $3, "--hostname=" $2, "--path=" $4
                }
            }

            # space + domain + path + (protocol) + (app-protocol)
            # space + domain + path + (protocol) + (app-protocol) + apps
            # space + domain + path + (protocol) + (app-protocol) + service
            # space + domain + path + (protocol) + (app-protocol) + apps + serivce
            NF >= 3 && $2 ~ /\./ && $3 ~ /\// {
                if (resource_column == "route-path") {
                    print $2 $3
                } else {
                    print $2, "--path=" $3
                }
            }

            # space + domain + (protocol) + (app-protocol)
            # space + domain + (protocol) + (app-protocol) + apps
            # space + domain + (protocol) + (app-protocol) + service
            # space + domain + (protocol) + (app-protocol) + apps + service
            NF >= 2 && $2 ~ /\./ && $3 !~ /\// && $3 !~ /^[0-9]+$/ {
                print $2
            }
        '
    elif [[ $resource = security-groups ]]; then
        awk '
            /^#/ {
                print $2
            }
            !/^#/ {
                print $1
            }
        '
    else
        awk \
            -v resource_column=$resource_column \
            '{ print $resource_column }'
    fi
}

_fzf_complete_cf-app-instances() {
    local fzf_options=$1
    local app=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        "$cf" app "${cf_arguments[@]}" "$app" 2> /dev/null |
            awk '/^#|^ +/ && !/^$|^TIP:/' |
            _fzf_complete_colorize $fg[yellow]
    )
}

_fzf_complete_cf-app-instances_post() {
    awk '{
        gsub(/^#/, "")
        print $1
    }'
}

_fzf_complete_cf-apps-by-org-space() {
    local fzf_options=$1
    local org_name=$2
    local space_name=$3
    shift 3

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        local org_guid space_guid spaces

        if [[ -z $org_name ]]; then
            space_guid=$("$cf" space --guid "$space_name" 2> /dev/null)
        else
            org_guid=$("$cf" org --guid "$org_name" 2> /dev/null)
            if [[ -z $org_guid ]]; then
                return
            fi

            spaces=$("$cf" curl "${cf_arguments[@]}" "/v2/spaces?q=organization_guid:$org_guid&q=name:$space_name" 2> /dev/null)
            if [[ -z $spaces ]]; then
                return
            fi

            space_guid=$(jq -r '.resources[] | .metadata.guid' <<< "$spaces" 2> /dev/null)
        fi

        if [[ -z $space_guid ]]; then
            return
        fi

        {
            echo name
            _fzf_complete_cf-curl-resources "/v2/spaces/$space_guid/apps?results-per-page=100" 2> /dev/null |
                jq --slurp -r 'map(.resources)[] | map(.entity.name) | sort[]' 2> /dev/null
        } | _fzf_complete_tabularize $fg[yellow]
    )
}

_fzf_complete_cf-apps-by-org-space_post() {
    awk '{ print $1 }'
}

_fzf_complete_cf-envs() {
    local fzf_options=$1
    local app=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        local app_guid=$("$cf" app "${cf_arguments[@]}" --guid "$app" 2> /dev/null)
        if [[ -z $app_guid ]]; then
            return
        fi

        {
            echo name value
            "$cf" curl "${cf_arguments[@]}" /v2/apps/$app_guid/env 2> /dev/null |
                jq -r '.environment_json | to_entries[] | "\(.key) \(.value)"' 2> /dev/null
        } | _fzf_complete_tabularize $fg[yellow]
    )
}

_fzf_complete_cf-envs_post() {
    awk '{ print $1 }'
}

_fzf_complete_cf-service-keys-by-service-instance() {
    local fzf_options=$1
    local service_instance=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        "$cf" "${cf_arguments[@]}" service-keys "$service_instance" 2> /dev/null |
            awk 'NR > 1 && !/^$|^TIP:|^OK$/' |
            _fzf_complete_colorize $fg[yellow]
    )
}

_fzf_complete_cf-service-keys-by-service-instance_post() {
    awk '{ print $1 }'
}

_fzf_complete_cf-service-plans-by-service-instance() {
    local fzf_options=$1
    local service_instance=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        local org_guid space_guid
        local service_params=("q=name:$service_instance")

        if org_guid=$(_fzf_complete_cf-target-org); then
            service_params+=("q=organization_guid:$org_guid")
        fi

        if space_guid=$(_fzf_complete_cf-target-space); then
            service_params+=("q=space_guid:$space_guid")
        fi

        local service_instances=$("$cf" curl "${cf_arguments[@]}" "/v2/service_instances?${(pj:&:)service_params}" 2> /dev/null)
        if [[ -z $service_instances ]]; then
            return
        fi

        local service_url=$(jq -r '.resources | first | .entity.service_url' <<< "$service_instances" 2> /dev/null)
        if [[ -z $service_url ]]; then
            return
        fi

        local service=$("$cf" curl "${cf_arguments[@]}" "$service_url" 2> /dev/null)
        if [[ -z $service ]]; then
            return
        fi

        local service_name=$(jq -r '.entity.label // ""' <<< "$service" 2> /dev/null)
        if [[ -z $service_name ]]; then
            return
        fi

        local service_offering=-e
        if [[ $cf_version = 6 ]]; then
            service_offering=-s
        fi

        "$cf" "${cf_arguments[@]}" marketplace "$service_offering" "$service_name" 2> /dev/null |
            awk 'NR > 1 && !/^$|^TIP:|^OK$/' |
            _fzf_complete_colorize $fg[yellow]
    )
}

_fzf_complete_cf-service-plans-by-service-instance_post() {
    awk '{ print $1 }'
}

_fzf_complete_cf-spaces-by-org() {
    local fzf_options=$1
    local org_name=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        local org_guid=$("$cf" org --guid "$org_name" 2> /dev/null)

        {
            echo name
            _fzf_complete_cf-curl-resources "/v2/organizations/$org_guid/spaces?results-per-page=100" 2> /dev/null |
                jq --slurp -r 'map(.resources)[] | map(.entity.name) | sort[]' 2> /dev/null
        } | _fzf_complete_tabularize $fg[yellow]
    )
}

_fzf_complete_cf-spaces-by-org_post() {
    awk '{ print $1 }'
}

_fzf_complete_cf-user-provided-service-instance-credentials() {
    local fzf_options=$1
    local service_instance=$2
    shift 2

    _fzf_complete --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        local org_guid space_guid
        local service_params=("q=name:$service_instance")

        if org_guid=$(_fzf_complete_cf-target-org); then
            service_params+=("q=organization_guid:$org_guid")
        fi

        if space_guid=$(_fzf_complete_cf-target-space); then
            service_params+=("q=space_guid:$space_guid")
        fi

        local service_instances=$("$cf" curl "${cf_arguments[@]}" "/v2/user_provided_service_instances?${(pj:&:)service_params}" 2> /dev/null)
        if [[ -z $service_instances ]]; then
            return
        fi

        jq -rc '.resources | first | .entity.credentials // {} | keys_unsorted[] as $k | { ($k): .[$k] }' <<< "$service_instances" 2> /dev/null
    )
}

_fzf_complete_cf-user-provided-service-instance-credentials_post() {
    local input=$(cat)
    if [[ -z $input ]]; then
        return
    fi

    jq --slurp -c 'reduce .[] as $item ({}; . * $item) | @json' <<< "$input" 2> /dev/null
}

_fzf_complete_cf-curl-resources() {
    local response
    local url=$1
    shift

    while [[ -n $url ]]; do
        if ! response=$("$cf" curl "${cf_arguments[@]}" "$@" "$url" 2> /dev/null); then
            return
        fi
        echo - "$response"
        url=$(jq -r '.next_url // ""' <<< "$response" 2> /dev/null)
    done
}

_fzf_complete_cf-target-org() {
    local configjson=${CF_HOME:-$HOME}/.cf/config.json
    if [[ ! -a $configjson ]]; then
        return 1
    fi

    local guid
    if ! guid=$(jq -re '.OrganizationFields.GUID' "$configjson" 2> /dev/null); then
        return 1
    fi

    echo - "$guid"
}

_fzf_complete_cf-target-space() {
    local configjson=${CF_HOME:-$HOME}/.cf/config.json
    if [[ ! -a $configjson ]]; then
        return 1
    fi

    local guid
    if ! guid=$(jq -re '.SpaceFields.GUID' "$configjson" 2> /dev/null); then
        return 1
    fi

    echo - "$guid"
}

_fzf_complete_cf_parse_completing_option() {
    if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)cf_options_argument_required}" ''); then
        if [[ $completing_option = --* ]]; then
            prefix_option=$completing_option=
        else
            prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
        fi
        prefix=${prefix#$prefix_option}
    fi
}
