_fzf_complete_enable_aliases() {
    local expr name value
    local completers=(${@:t:r})

    local IFS=$'\n'
    for expr in $(alias); do
        name=${expr%%=*}
        value=(${(Q)${(z)${(Q)${(z)expr##*=}}}})

        if [[ -n ${completers[(r)$value[1]]} ]]; then
            eval "_fzf_complete_$name() { _fzf_complete_$value \$@ }"
        fi
    done
}

_fzf_complete_enable_aliases ${0:h:h}/completers/*
