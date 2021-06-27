_fzf_complete_enable_aliases() {
    local expr name value completer arguments
    local completers=(${@:t:r})

    local IFS=$'\n'
    for expr in $(alias); do
        name=${expr%%=*}
        value=(${(Q)${(z)${(Q)${(z)expr##*=}}}})
        completer=${completers[(r)$value[1]]}
        arguments=${(@)value[2,-1]}

        if [[ -n $completer ]]; then
            local original_func=$(declare -f _fzf_complete_$completer)
            eval "
                _fzf_complete_$name() {
                    local wrapper=\$(declare -f _fzf_complete_$name)
                    $original_func
                    LBUFFER=\"\${LBUFFER/$name/$completer $arguments}\"
                    _fzf_complete_${completer} \${@/$name/$completer $arguments}
                    LBUFFER=\"\${LBUFFER/$completer $arguments/$name}\"
                    eval \"\$wrapper\"
                }
            "
        fi
    done
}

_fzf_complete_enable_aliases ${0:h:h}/completers/*
