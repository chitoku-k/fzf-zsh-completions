typeset -g mock_dir=${funcsourcetrace[1]:P:h:h}/_support/mock

mock() {
    local target=$1
    shift

    local mock_timesfile=$mock_dir/${target}_mock_times
    echo 0 > $mock_timesfile

    $target() {
        local target=${funcstack[1]}
        local mock_timesfile=$mock_dir/${target}_mock_times
        local mock_times=$(($(cat -- $mock_timesfile) + 1))
        local mock_failfile=$mock_dir/${target}_mock_${mock_times}_fail
        echo $mock_times > $mock_timesfile

        if ${target}_mock_$mock_times "$@" &> $mock_failfile; then
            cat -- $mock_failfile
            rm -- $mock_failfile
        fi
    }
}

unmock() {
    local target=$1
    shift

    if (( $+functions[$target] )); then
        unfunction $target
    fi

    local mock_timesfile=$mock_dir/${target}_mock_times

    local i len
    if [[ -e $mock_timesfile ]]; then
        len=$(cat -- $mock_timesfile)
    fi

    for (( i = 1; i <= len; i++ )); do
        local mock=${target}_mock_$i
        local mock_failfile=$mock_dir/${mock}_fail
        if [[ -e $mock_failfile ]]; then
            echo "$mock: $(cat -- $mock_failfile)"
        fi
    done

    rm -f -- $mock_timesfile $mock_dir/${target}_mock_*_fail(N)
}
