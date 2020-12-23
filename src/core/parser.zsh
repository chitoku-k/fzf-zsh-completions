#!/usr/bin/env zsh

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
                if [[ -n ${options_argument_required[(r)${current%=*}]} ]] || [[ -n ${options_argument_optional[(r)${current%=*}]} ]]; then
                    completing_option=${current%=*}
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
    local arguments=(${(z)3})
    local options_argument_required=(${(z)4})
    shift 4

    if (( ${#arguments} < $start_index )); then
        return 1
    fi

    local i
    local command_arguments=()
    for i in {$start_index..${#arguments}}; do
        if [[ ${(Q)arguments[$i]} = -(#c1,2)* ]]; then
            continue
        fi

        local previous_argument=$(_fzf_complete_parse_completing_option '' "${(Q)arguments[i - 1]}" "${(F)options_argument_required}" '')
        if [[ -n $previous_argument ]] && [[ ${options_argument_required[(r)$previous_argument]} = $previous_argument ]]; then
            continue
        fi

        command_arguments+=${arguments[$i]}
    done

    if [[ $index = 0 ]]; then
        echo - ${command_arguments}
        return
    fi
    echo - ${command_arguments[$index]}
    return $(( index > #command_arguments ))
}

_fzf_complete_parse_option_argument() {
    local idx value
    local short=${1#*-}
    local long=${2#*--}
    shift 2

    if [[ -n $short ]]; then
        if [[ -n ${(Q)${(z)@}[(r)-[^-]#$short?##]} ]]; then
            idx=${(Q)${(z)@}[(i)-[^-]#$short?##]}
            value=${(Q)${(z)@}[idx]/-[^-$short]#$short/}
        fi

        if [[ -n ${(Q)${(z)@}[(r)-[^-]#$short]} ]]; then
            idx=${(Q)${(z)@}[(i)-[^-]#$short]}
            value=${(Q)${(z)@}[idx+1]}
        fi
    fi

    if [[ -n $long ]]; then
        if [[ -n ${(Q)${(z)@}[(r)--$long=*]} ]]; then
            idx=${(Q)${(z)@}[(i)--$long=*]}
            value=${(Q)${(z)@}[idx]/--$long=/}
        fi

        if [[ -n ${(Q)${(z)@}[(r)--$long]} ]]; then
            idx=${(Q)${(z)@}[(i)--$long]}
            value=${(Q)${(z)@}[idx+1]}
        fi
    fi

    if [[ -z $idx ]]; then
        return 1
    fi

    echo - $value
}
