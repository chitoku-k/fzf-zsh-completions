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
            source -- ${@[(r)*completers/$completer.zsh]}
            local original_func_body=$functions[_fzf_complete_$completer]
            eval "
                _fzf_complete_$name() {
                    LBUFFER=\"\${LBUFFER/$name/$completer $arguments}\"
                    () {
                        $original_func_body
                    } \${@/$name/$completer $arguments}
                    LBUFFER=\"\${LBUFFER/$completer $arguments/$name}\"
                }
            "
        fi
    done
}

_fzf_complete_enable_aliases ${0:h:h}/completers/*
