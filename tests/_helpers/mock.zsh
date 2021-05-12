mock() {
    local target=$1
    shift

    echo 0 > ${target}_mock_times

    $target() {
        local target=${funcstack[1]}
        local mock_times=$(($(cat -- ${target}_mock_times) + 1))
        local mock_failfile=${target}_mock_${mock_times}_fail
        echo $mock_times > ${target}_mock_times

        if ${target}_mock_$mock_times $@ &> $mock_failfile; then
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

    rm -f -- ${target}_mock_times ${target}_mock_*_fail(N)
}
