#!/usr/bin/env zsh
autoload -U colors
colors

_fzf_complete_vault() {
    setopt local_options no_aliases
    local command_pos=$(_fzf_complete_get_command_pos "$@")
    local arguments=("${(Q)${(z)"$(_fzf_complete_trim_env "$command_pos" "$@")"}[@]}")
    local vault_arguments=()
    local last_argument=${arguments[-1]}
    local prefix_option completing_option

    if (( $command_pos > 1 )); then
        local -x "${(e)${(z)"$(_fzf_complete_get_env "$command_pos" "$@")"}[@]}"
    fi

    local vault_inherited_options_argument_required=(
        -address
        --address
        -agent-address
        --agent-address
        -ca-cert
        --ca-cert
        -ca-path
        --ca-path
        -client-cert
        --client-cert
        -client-key
        --client-key
        -mfa
        --mfa
        -namespace
        --namespace
        -tls-server-name
        --tls-server-name
    )
    local vault_inherited_options=(
        -tls-skip-verify
        --tls-skip-verify
    )

    local vault_options_argument_required=(
        $vault_inherited_options_argument_required
        -cas
        --cas
        -delete-version-after
        --delete-version-after
        -field
        --field
        -format
        --format
        -max-versions
        --max-versions
        -version
        --version
        -versions
        --versions
        -wrap-ttl
        --wrap-ttl
    )
    local vault_options_argument_optional=(
        -policy-override
        --policy-override
        -tls-skip-verify
        --tls-skip-verify
    )

    local subcommands=($(_fzf_complete_parse_argument 2 1 "${(F)vault_options_argument_required}" "${arguments[@]}"))

    if (( $+functions[_fzf_complete_vault_${subcommands[1]}] )) && _fzf_complete_vault_${subcommands[1]} "$@"; then
        return
    fi

    _fzf_complete_vault_parse_completing_option
    _fzf_complete_vault_parse_vault_arguments

    if [[ -z $prefix ]] || [[ ${prefix#/} != */* ]]; then
        _fzf_complete_vault-mounts '' "$@"
    else
        _fzf_complete_vault-paths '' "$@"
    fi
}

_fzf_complete_vault-mounts() {
    local fzf_options=$1
    shift

    local curl_arguments=(--silent)
    if [[ -n ${vault_arguments[(r)-tls-skip-verify]} ]] || [[ -n ${vault_arguments[(r)--tls-skip-verify]} ]]; then
        curl_arguments+=(--insecure)
    fi

    local url=$VAULT_ADDR
    if [[ -n ${vault_arguments[(r)-address*]} ]] || [[ -n ${vault_arguments[(r)--address*]} ]]; then
        url=$(_fzf_complete_parse_option_arguments '' '-address --address' "${(F)vault_options_argument_required}" 'argument' "${arguments[@]}")
    fi

    _fzf_complete --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- "$@" < <(
        local token=$(vault print token 2> /dev/null)
        if [[ -z $token ]]; then
            return
        fi

        curl \
            "${curl_arguments[@]}" \
            --header "X-Vault-Token: $token" \
            "$url/v1/sys/internal/ui/mounts" |
            jq -r '.data.secret | keys[]' 2> /dev/null
    )
}

_fzf_complete_vault-mounts_post() {
    echo -n $(cat)
}

_fzf_complete_vault-paths() {
    local fzf_options=$1
    shift

    prefix_option=${prefix%/*}/
    prefix=${prefix##*/}

    _fzf_complete --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- "$@$prefix_option" < <(
        vault kv list --format=json "${vault_arguments[@]}" "$prefix_option" 2> /dev/null | jq -r 'values[]'
    )
}

_fzf_complete_vault-paths_post() {
    echo -n $(cat)
}

_fzf_complete_vault_parse_completing_option() {
    if completing_option=$(_fzf_complete_parse_completing_option "$prefix" "$last_argument" "${(F)vault_options_argument_required}" "${(F)vault_options_argument_optional}"); then
        if [[ $completing_option = --* ]]; then
            prefix_option=$completing_option=
        else
            prefix_option=${prefix%%${completing_option[-1]}*}${completing_option[-1]}
        fi
        prefix=${prefix#$prefix_option}
    fi
}

_fzf_complete_vault_parse_vault_arguments() {
    local inherit_values
    local all_options=($vault_inherited_options_argument_required $vault_inherited_options)
    local shorts=(${all_options:#--*})
    local longs=(${all_options:#-[a-zA-Z0-9]})

    if inherit_values=$(_fzf_complete_parse_option_arguments "$shorts" "$longs" "${(F)vault_options_argument_required}" 'option argument' "${arguments[@]}"); then
        vault_arguments+=("${(Q)${(z)inherit_values}[@]}")
    fi

    if inherit_values=$(_fzf_complete_parse_option_arguments "$shorts" "$longs" "${(F)vault_options_argument_required}" 'option argument' "${(Q)${(z)RBUFFER}[@]}"); then
        vault_arguments+=("${(Q)${(z)inherit_values}[@]}")
    fi
}
