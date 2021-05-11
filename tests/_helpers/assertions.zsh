_zunit_assert_mock_times() {
    local target=$1
    local count=$2
    shift 2

    local len=$(cat -- ${target}_mock_times)
    if [[ $len != $count ]]; then
        echo "'$target' is called for $len times(s)"
        exit 1
    fi

    local i
    for (( i = 1; i <= $len; i++ )); do
        local mock=${target}_mock_$i
        if [[ -e ${mock}_fail ]]; then
            echo "$mock: $(cat -- ${mock}_fail)"
            exit 1
        fi
    done
}
