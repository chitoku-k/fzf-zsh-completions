#!/usr/bin/env zsh

autoload -U colors
colors

_fzf_complete_cf() {
    setopt local_options no_aliases
    local arguments=("${(Q)${(z)"$(_fzf_complete_trim_env "$@")"}[@]}")
    local options_and_subcommand=()
    local cf_arguments=()
    local last_argument=${arguments[-1]}
    local prefix_option completing_option resource resource_column=1

    local cf_options_argument_required=()
    local subcommand=$(_fzf_complete_parse_argument 2 1 "${(F)cf_options_argument_required}" "${arguments[@]}")

    if (( $+functions[_fzf_complete_cf_${subcommand}] )) && _fzf_complete_cf_${subcommand} "$@"; then
        return
    fi

    if [[ $subcommand = (app|d|delete|disable-ssh|e|enable-ssh|env|events|get-health-check|logs|rename|restage|restart|rg|rs|sp|ssh-enabled|st|start|stop|tasks|v3-delete|v3-droplets|v3-env|v3-get-health-check|v3-packages|v3-restart|v3-start|v3-stop) ]]; then
        resource=apps
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = (add-network-policy|remove-network-policy) ]]; then
        cf_options_argument_required+=(
            --destination-app
            -o
            --port
            --protocol
            -s
        )

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

        if [[ $completing_option = --destination-app ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -o ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -s ]]; then
            resource=spaces
            _fzf_complete_cf-resources '' "$@"
            return
        fi
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

        _fzf_complete_cf_parse_completing_option

        local source_app
        if ! source_app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local target_app
        if ! target_app=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -o ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -s ]]; then
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

    if [[ $subcommand = (map-route|unmap-route) ]]; then
        cf_options_argument_required+=(
            --hostname
            -n
            --path
            --port
        )

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
            -d
            --docker-image
            --docker-username
            --droplet
            -f
            --health-check-type
            --hostname
            -i
            -k
            -m
            -n
            -o
            -p
            --route-path
            -s
            -t
            -u
            --vars-file
            --var
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -b ]]; then
            resource=buildpacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -d ]]; then
            resource=domains
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -s ]]; then
            resource=stacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        _fzf_path_completion "$prefix" "$@"
        return
    fi

    if [[ $subcommand = (restart-app-instance|v3-restart-app-instance) ]]; then
        if [[ $subcommand = v3* ]]; then
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

    if [[ $subcommand = (rt|run-task) ]]; then
        cf_options_argument_required+=(
            -k
            -m
            --name
        )

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
        if [[ $subcommand = v3* ]]; then
            cf_options_argument_required+=(
                --process
            )
        fi

        cf_options_argument_required+=(
            -i
            -k
            -m
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (set-health-check|v3-set-health-check) ]]; then
        if [[ $subcommand = v3* ]]; then
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
        if [[ $subcommand = v3* ]]; then
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

    if [[ $subcommand = v3-create-package ]]; then
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

    if [[ $subcommand = v3-set-droplet ]]; then
        cf_options_argument_required+=(
            -d
            --droplet-guid
        )

        _fzf_complete_cf_parse_completing_option

        local app
        if ! app=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=apps
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = v3-stage ]]; then
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
            resource_column=2
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (delete-buildpack|rename-buildpack) ]]; then
        cf_options_argument_required+=(
            -s
        )

        _fzf_complete_cf_parse_completing_option

        local buildpack
        if ! buildpack=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=buildpacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -s ]]; then
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

        _fzf_complete_cf_parse_completing_option

        local buildpack
        if ! buildpack=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=buildpacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = (--assign-stack|-s) ]]; then
            resource=stacks
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        if [[ $completing_option = -i ]]; then
            resource=buildpacks
            resource_column=2
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

    if [[ $subcommand = (delete-domain|delete-shared-domain) ]]; then
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

        _fzf_complete_cf_parse_completing_option

        local host
        if ! host=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            return
        fi

        local domain
        if ! domain=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=domains
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = delete-route ]]; then
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
        cf_options_argument_required+=(
            -s
        )

        _fzf_complete_cf_parse_completing_option

        if [[ $completing_option = -s ]]; then
            resource=marketplace
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
            cf_arguments+=(-s "$service")
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
            cf_arguments+=(-s "$service")
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = purge-service-offering ]]; then
        cf_options_argument_required+=(
            -b
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

    if [[ $subcommand = create-domain ]]; then
        local org
        if ! org=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (disable-org-isolation|enable-org-isolation) ]]; then
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

    if [[ $subcommand = (set-org-role|unset-org-role) ]]; then
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

    if [[ $subcommand = set-quota ]]; then
        local org
        if ! org=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=orgs
            _fzf_complete_cf-resources '' "$@"
            return
        fi

        local quota
        if ! quota=$(_fzf_complete_parse_argument 2 3 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=quotas
            _fzf_complete_cf-resources '' "$@"
            return
        fi
    fi

    if [[ $subcommand = (set-space-role|unset-space-role) ]]; then
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
            resource=spaces
            _fzf_complete_cf-resources '' "$@"
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

    if [[ $subcommand = (delete-quota|quota) ]]; then
        resource=quotas
        _fzf_complete_cf-resources '' "$@"
        return
    fi

    if [[ $subcommand = update-quota ]]; then
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
            resource=quotas
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

    if [[ $subcommand = (delete-service|ds|purge-service-instance|rename-service|service|service-keys|sk) ]]; then
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

        local space
        if ! space=$(_fzf_complete_parse_argument 2 2 "${(F)cf_options_argument_required}" "${arguments[@]}") && [[ -z $completing_option ]]; then
            resource=spaces
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

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        cf "$resource" "${cf_arguments[@]}" 2> /dev/null |
            awk '
                NR > 1 && !/^$|^TIP:|^OK$/
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
    if [[ $resource = network-policies ]]; then
        awk '{ print $1, "--destination-app=" $2, "--protocol=" $3, "--port=" $4 }'
    elif [[ $resource = routes ]]; then
        awk '
            # space + domain + port + type
            # space + domain + port + type + apps
            # space + domain + port + type + service
            # space + domain + port + type + apps + service
            $3 ~ /^[0-9]+$/ {
                print $2, "--port=" $3
            }

            # space + host + domain + path + apps + service
            NF == 6 && $3 !~ /^[0-9]+$/ && $4 ~ /\// {
                print $3, "--hostname=" $2, "--path=" $4
            }

            # space + host + domain + apps + serivce
            NF == 5 && $2 !~ /\./ && $3 !~ /^[0-9]+$/ && $4 !~ /\// {
                print $3, "--hostname=" $2
            }

            # space + host + domain + path + apps
            # space + host + domain + path + service
            NF == 5 && $2 !~ /\./ && $3 !~ /^[0-9]+$/ && $4 ~ /\// {
                print $3, "--hostname=" $2, "--path=" $4
            }

            # space + domain + path + apps + serivce
            NF == 5 && $2 ~ /\./ && $3 ~ /\// {
                print $2, "--path=" $3
            }

            # space + host + domain + apps
            # space + host + domain + service
            NF == 4 && $2 !~ /\./ && $3 !~ /^[0-9]+$/ && $4 !~ /\// {
                print $3, "--hostname=" $2
            }

            # space + host + domain + path
            NF == 4 && $2 !~ /\./ && $3 !~ /^[0-9]+$/ && $4 ~ /\// {
                print $3, "--hostname=" $2, "--path=" $4
            }

            # space + domain + apps + service
            NF == 4 && $2 ~ /\./ && $3 !~ /^[0-9]+$/ && $3 !~ /\// {
                print $2
            }

            # space + domain + path + apps
            # space + domain + path + service
            NF == 4 && $2 ~ /\./ && $3 ~ /\// {
                print $2, "--path=" $3
            }

            # space + host + domain
            NF == 3 && $2 !~ /\./ {
                print $3, "--hostname=" $2
            }

            # space + domain + path
            NF == 3 && $2 ~ /\./ && $3 ~ /\// {
                print $2, "--path=" $3
            }

            # space + domain + apps
            # space + domain + service
            NF == 3 && $2 ~ /\./ && $3 !~ /\// {
                print $2
            }

            # space + domain
            NF == 2 {
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
        cf app "${cf_arguments[@]}" "$app" 2> /dev/null |
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

_fzf_complete_cf-envs() {
    local fzf_options=$1
    local app=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index --header-lines=1 ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        local app_guid=$(cf app "${cf_arguments[@]}" --guid "$app" 2> /dev/null)
        if [[ -z $app_guid ]]; then
            return
        fi

        {
            echo name value
            cf curl "${cf_arguments[@]}" /v2/apps/$app_guid/env 2> /dev/null |
                jq -r '.environment_json | to_entries[] | "\(.key) \(.value)"'
        } | _fzf_complete_tabularize $fg[yellow]
    )
}

_fzf_complete_cf-envs_post() {
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

        local service_instances=$(cf curl "${cf_arguments[@]}" "/v2/service_instances?${(pj:&:)service_params}" 2> /dev/null)
        if [[ -z $service_instances ]]; then
            return
        fi

        local service_url=$(jq -r '.resources | first | .entity.service_url' <<< "$service_instances" 2> /dev/null)
        if [[ -z $service_url ]]; then
            return
        fi

        local service=$(cf curl "${cf_arguments[@]}" "$service_url" 2> /dev/null)
        if [[ -z $service ]]; then
            return
        fi

        local service_name=$(jq -r '.entity.label // ""' <<< "$service" 2> /dev/null)
        if [[ -z $service_name ]]; then
            return
        fi

        cf "${cf_arguments[@]}" marketplace -s "$service_name" 2> /dev/null |
            awk 'NR > 1 && !/^$|^TIP:|^OK$/' |
            _fzf_complete_colorize $fg[yellow]
    )
}

_fzf_complete_cf-service-plans-by-service-instance_post() {
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

        local service_instances=$(cf curl "${cf_arguments[@]}" "/v2/user_provided_service_instances?${(pj:&:)service_params}" 2> /dev/null)
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

    jq --slurp -c 'reduce .[] as $item ({}; . * $item) | @json' <<< "$input"
}

_fzf_complete_cf-target-org() {
    local configjson=${CF_HOME:-$HOME}/.cf/config.json
    if [[ ! -a $configjson ]]; then
        return 1
    fi

    local guid
    if ! guid=$(jq -re '.OrganizationFields.GUID' "$configjson"); then
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
    if ! guid=$(jq -re '.SpaceFields.GUID' "$configjson"); then
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
