#!/usr/bin/env zsh

_fzf_complete_get_command_pos() {
    local arguments=("${(Q)${(z)@}[@]}")
    local cmd=$(__fzf_extract_command "$@")
    echo ${arguments[(i)$cmd]}
}

_fzf_complete_trim_env() {
    local command_pos=$1
    shift 1
    local arguments=("${(Q)${(z)@}[@]}")
    echo ${(q)arguments[$command_pos, -1]}
}

_fzf_complete_get_env() {
    local command_pos=$1
    shift 1
    local arguments=("${${(z)@}[@]}")
    echo ${arguments[1, $command_pos - 1]}
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
        if [[ $current = -[A-Za-z]* ]]; then
            if [[ -n ${options_argument_required[(r)${current:0:2}]} ]] || [[ -n ${options_argument_optional[(r)${current:0:2}]} ]]; then
                completing_option=${current:0:2}
                completing_option_source=prefix
                break
            fi
        fi

        if [[ -n ${options_argument_required[(r)${current%%=*}]} ]] || [[ -n ${options_argument_optional[(r)${current%%=*}]} ]]; then
            completing_option=${current%%=*}
            completing_option_source=prefix
            break
        fi

        if [[ $current != -[A-Za-z][A-Za-z]* ]]; then
            break
        fi

        current=${current/-[A-Za-z]/-}
    done

    current=$last_argument

    while [[ -n $current ]]; do
        if [[ -n ${options_argument_required[(r)${current[1,2]}]} ]] && (( ${#current} > 2 )); then
            break
        fi

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
    local options_argument_required=(${(z)3})
    shift 3

    local arguments=("$@")
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
    local shorts=(${(z)1})
    local longs=(${(z)2})
    local options_argument_required=(${(z)3})
    shift 3

    local i j parsing_argument
    local result=()
    local start_index=2
    local arguments=("$@")

    for i in {$start_index..${#arguments}}; do
        if [[ -n $parsing_argument ]]; then
            parsing_argument=
            continue
        fi

        if [[ ${arguments[$i]} = -- ]]; then
            break
        else
            if [[ ${options_argument_required[(r)${arguments[$i]}]} = ${arguments[$i]} ]]; then
                parsing_argument=1
            elif [[ ${longs[(r)${arguments[$i]%%=*}]} = ${arguments[$i]%%=*} ]]; then
                parsing_argument=
                result+=(${arguments[$i]%%=*})
            fi

            if [[ ${arguments[$i]} != -[^-]* ]]; then
                continue
            fi

            for j in {$start_index..${#arguments[$i]}}; do
                if [[ ${options_argument_required[(r)-${arguments[$i][$j]}]} = -${arguments[$i][$j]} ]]; then
                    if [[ $j = ${#arguments[$i]} ]]; then
                        parsing_argument=1
                    else
                        parsing_argument=
                        break
                    fi
                elif [[ ${shorts[(r)-${arguments[$i][$j]}]} = -${arguments[$i][$j]} ]]; then
                    result+=(-${arguments[$i][$j]})
                fi
            done
        fi
    done

    if [[ -z $result ]]; then
        return 1
    fi

    echo - $result
}

_fzf_complete_parse_option_arguments() {
    local shorts=(${(z)1})
    local longs=(${(z)2})
    local options_argument_required=(${(z)3})
    local types=(${(z)4})
    shift 4

    local i j parsing_argument
    local result=()
    local start_index=1
    local arguments=("$@")

    for i in {$start_index..${#arguments}}; do
        if [[ -n $parsing_argument ]]; then
            parsing_argument=
            continue
        fi

        if [[ ${arguments[$i]} = -- ]]; then
            break
        else
            if [[ ${arguments[$i]} = --[^-]* ]]; then
                if [[ ${options_argument_required[(r)${arguments[$i]%%=*}]} != ${arguments[$i]%%=*} ]]; then
                    continue
                fi
            fi

            if [[ ${longs[(r)${arguments[$i]}]} = ${arguments[$i]} ]]; then
                parsing_argument=1

                if (( ${#arguments} > $i )); then
                    if [[ ${types[(r)option]} = option ]]; then
                        result+=(${arguments[$i]})
                    fi
                    if [[ ${types[(r)argument]} = argument ]]; then
                        result+=("${arguments[$i+1]}")
                    fi
                fi
            elif [[ ${longs[(r)${arguments[$i]%%=*}]} = ${arguments[$i]%%=*} ]]; then
                parsing_argument=

                if [[ ${types[(r)option]} = option ]] && [[ ${types[(r)argument]} = argument ]]; then
                    result+=(${arguments[$i]})
                elif [[ ${types[(r)option]} = option ]]; then
                    result+=(${arguments[$i]%%=*})
                elif [[ ${types[(r)argument]} = argument ]]; then
                    result+=(${arguments[$i]#*=})
                fi
            fi

            if [[ ${arguments[$i]} != -[A-Za-z0-9]* ]]; then
                continue
            fi

            for j in {$start_index..${#arguments[$i]}}; do
                if [[ ${options_argument_required[(r)-${arguments[$i][$j]}]} != -${arguments[$i][$j]} ]]; then
                    continue
                fi

                if [[ $j = ${#arguments[$i]} ]]; then
                    parsing_argument=1

                    if [[ ${shorts[(r)-${arguments[$i][$j]}]} = -${arguments[$i][$j]} ]] && (( ${#arguments} > $i )); then
                        if [[ ${types[(r)option]} = option ]]; then
                            result+=(-${arguments[$i][$j]})
                        fi
                        if [[ ${types[(r)argument]} = argument ]]; then
                            result+=("${arguments[$i+1]}")
                        fi
                    fi
                else
                    parsing_argument=

                    if [[ ${shorts[(r)-${arguments[$i][$j]}]} = -${arguments[$i][$j]} ]]; then
                        if [[ ${types[(r)option]} = option ]] && [[ ${types[(r)argument]} = argument ]]; then
                            result+=("-${arguments[$i][$j,-1]}")
                        elif [[ ${types[(r)option]} = option ]]; then
                            result+=("-${arguments[$i][$j]}")
                        elif [[ ${types[(r)argument]} = argument ]]; then
                            result+=("${arguments[$i][$j+1,-1]}")
                        fi
                    fi
                    break
                fi
            done
        fi
    done

    if [[ -z $result ]]; then
        return 1
    fi

    echo - ${(q)result}
}
