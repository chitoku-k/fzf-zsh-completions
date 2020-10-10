_fzf_complete_constants() {
    local fzf_options=$1
    local values=$2
    shift 2

    _fzf_complete --ansi --tiebreak=index ${(Q)${(Z+n+)fzf_options}} -- $@$prefix_option < <(echo $values)
}

_fzf_complete_constants_post() {
    local input=$(cat)

    if [[ -z $input ]]; then
        return
    fi

    if [[ $input = *= ]]; then
        echo -n $input
    else
        echo $input
    fi
}
