_zunit_assert_mock_times() {
    local target=$1
    local count=$2
    shift 2

    local len=$(cat -- $mock_dir/${target}_mock_times)
    if [[ $len != $count ]]; then
        echo "'$target' is called $len time(s)"
        exit 1
    fi

    local i
    for (( i = 1; i <= len; i++ )); do
        local mock=${target}_mock_$i
        local mock_failfile=$mock_dir/${mock}_fail
        if [[ -e $mock_failfile ]]; then
            echo "$mock: $(cat -- $mock_failfile)"
            rm -f -- $mock_failfile
            exit 1
        fi
    done
}

_zunit_post_assert() {
    local -A replacements=(
        \$reset_color $reset_color
        \$bold_color $bold_color
    )

    local var key value name target
    for var in fg fg_bold fg_no_bold bg bg_bold bg_no_bold; do
        for key in ${(k)${(P)var}}; do
            name="\$$var\[$key\]"
            replacements[$name]=${${(P)var}[$key]}
        done
    done

    local input=$(cat)
    for key in ${(k)replacements}; do
        target=${key//\\/}
        [[ -z $tap ]] && target='\e[4;38;5;242m'$target'\e[4;31m'

        input=${input//${replacements[$key]}/$target}
    done

    echo -n - $input
}
