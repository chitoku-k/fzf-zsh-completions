#!/usr/bin/env zsh

_fzf_complete_trim_env() {
    local arguments=("${(Q)${(z)@}[@]}")
    local cmd=$(__fzf_extract_command $@)
    local idx=${arguments[(i)$cmd]}
    echo ${(q)arguments[$idx, -1]}
}

_fzf_complete_parse_completing_option() {
    local prefix=$1
    local last_argument=$2
    local options_argument_required=(${(z)3})
    local options_argument_optional=(${(z)4})
    shift 4

    local current=$prefix
    local completing_option
    local completing_option_source

    while [[ -n $current ]]; do
        case $current in
            -[A-Za-z]*)
                if [[ -n ${options_argument_required[(r)${current:0:2}]} ]] || [[ -n ${options_argument_optional[(r)${current:0:2}]} ]]; then
                    completing_option=${current:0:2}
                    completing_option_source=prefix
                    break
                fi
                ;;

            --*)
                if [[ -n ${options_argument_required[(r)${current%%=*}]} ]] || [[ -n ${options_argument_optional[(r)${current%%=*}]} ]]; then
                    completing_option=${current%%=*}
                    completing_option_source=prefix
                    break
                fi
                ;;
        esac

        if [[ $current != -[A-Za-z][A-Za-z]* ]]; then
            break
        fi

        current=${current/-[A-Za-z]/-}
    done

    current=$last_argument

    while [[ -n $current ]]; do
        if [[ -n ${options_argument_required[(r)$current]} ]]; then
            completing_option=$current
            completing_option_source=last_argument
            break
        fi

        if [[ $current != -[A-Za-z][A-Za-z]* ]]; then
            break
        fi

        current=${current/-[A-Za-z]/-}
    done

    echo - $completing_option
    case $completing_option_source in
        prefix)
            return 0
            ;;

        last_argument)
            return 1
            ;;

        *)
            return 2
            ;;
    esac
}

_fzf_complete_parse_argument() {
    local start_index=$1
    local index=$2
    local arguments=("${(Q)${(z)3}[@]}")
    local options_argument_required=(${(z)4})
    shift 4

    if (( ${#arguments} < $start_index )); then
        return 1
    fi

    local i
    local command_arguments=()
    for i in {$start_index..${#arguments}}; do
        if [[ ${arguments[$i]} = -(#c1,2)* ]]; then
            continue
        fi

        local previous_argument=$(_fzf_complete_parse_completing_option '' "${arguments[i - 1]}" "${(F)options_argument_required}" '')
        if [[ -n $previous_argument ]] && [[ ${options_argument_required[(r)$previous_argument]} = $previous_argument ]]; then
            continue
        fi

        command_arguments+=${arguments[$i]}
    done

    if [[ $index = 0 ]]; then
        echo - $command_arguments
        return
    fi
    echo - ${command_arguments[$index]}
    return $(( index > ${#command_arguments} ))
}

_fzf_complete_parse_option() {
    local result=()
    local shorts=(${(z)1})
    local longs=(${(z)2})
    local options_argument_required=(${(z)3})
    shift 3

    local cmd=("${(Q)${(z)@}[@]}")
    local cmd_shorts=(${(M)cmd:#-[^-]*})

    local option_argument_required
    for option_argument_required in $options_argument_required; do
        cmd_shorts=(${cmd_shorts%%${option_argument_required#-}*})
    done

    cmd_shorts=(-${^${(ps::)cmd_shorts}})

    result+=(${cmd_shorts:*shorts})
    result+=(${cmd:*longs})

    if [[ -z $result ]]; then
        return 1
    fi

    echo - $result
}

_fzf_complete_parse_option_arguments() {
    local result=()
    local current idx indices preoptions
    local short=${1#*-}
    local long=${2#*--}
    local options_argument_required=(${(z)3})
    shift 3

    local cmd=("${(Q)${(z)@}[@]}")
    while [[ $idx -le ${#cmd} ]]; do
        indices=()

        if [[ -n $short ]]; then
            if [[ -n ${cmd[(rb:idx+1:)-[^-=]#$short?##]} ]]; then
                current=${cmd[(ib:idx+1:)-[^-=]#$short?##]}
                preoptions=(-${^${(ps::)${${cmd[current]%%$short*}#-}}})

                if [[ -z ${options_argument_required:*preoptions} ]]; then
                    indices+=($current)
                    result[current]=${(qq)${cmd[current]/-[^-=$short]#$short/-$short}}
                fi
            fi

            if [[ -n ${cmd[(rb:idx+1:)-[^-=]#$short]} ]]; then
                current=${cmd[(ib:idx+1:)-[^-=]#$short]}

                if [[ ${#cmd} != $current ]]; then
                    indices+=($current)
                    result[current]=${(qq)${cmd[current]}}
                    result[current+1]=${(qq)${cmd[current+1]}}
                fi
            fi
        fi

        if [[ -n $long ]]; then
            if [[ -n ${cmd[(rb:idx+1:)--$long=*]} ]]; then
                current=${cmd[(ib:idx+1:)--$long=*]}
                indices+=($current)
                result[current]=${(qq)${cmd[current]}}
            fi

            if [[ -n ${cmd[(rb:idx+1:)--$long]} ]]; then
                current=${cmd[(ib:idx+1:)--$long]}

                if [[ ${#cmd} != $current ]]; then
                    indices+=($current)
                    result[current]=${(qq)${cmd[current]}}
                    result[current+1]=${(qq)${cmd[current+1]}}
                fi
            fi
        fi

        if [[ -z $indices ]]; then
            break
        fi

        idx=(${${(n)indices}[1]})
    done

    if [[ -z $result ]]; then
        return 1
    fi

    echo - $result
}
