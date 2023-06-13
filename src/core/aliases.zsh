_fzf_complete_enable_aliases() {
    local expr name value completer
    local completers=("${@[@]:t:r}")

    for name expr in ${(kv)aliases[@]}; do
        value=(${(Q)${(z)expr}})
        completer=${completers[(r)$value[1]]}

        if [[ -n $completer ]]; then
            source -- "${@[(r)*completers/$completer.zsh]}"
            eval "
                _fzf_complete_$name() {
                    LBUFFER=\"\${LBUFFER/$name/\${aliases[$name]}}\"
                    () {
                        $functions[_fzf_complete_$completer]
                    } \"\${@/$name/\${aliases[$name]}}\"
                    LBUFFER=\"\${LBUFFER/\${aliases[$name]}/$name}\"
                }
            "
        fi
    done
}

_fzf_complete_enable_aliases ${0:h:h}/completers/*
