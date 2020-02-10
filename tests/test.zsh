#!/usr/bin/env zsh

ROOT=${0:h:h:A}
PATH=$ROOT/bin/revolver:$ROOT/bin/zunit:$PATH

setup() {
    local test_args=()
    zparseopts -D -E r+:=regex -regex+:=regex

    if [[ -n $regex ]]; then
        for (( i = 2; i <= ${#regex}; i = i + 2 )); do
            local argument=(${(s:@:)${regex[$i]}})
            local test_file
            local test_name
            if [[ ${#argument} == 1 ]]; then
                test_file=''
                test_name=${argument[1]}
            else
                test_file=${argument[1]}
                test_name=${argument[2]}
            fi
            local pattern='^ *@test  *([^ ]'$test_name')  *\{ *(.*)$'
            IFS=$'\n' local lines=($(grep -H -E $pattern ${test_file:-tests/*.zunit}))
            local line
            for line in $lines; do
                test_args+=(${test_file:-${line%%:*}}@${^${line#*\'}%\'*})
            done
        done
    fi

    args=($@ ${test_args})
}

run() {
    local args=()
    setup $@

    cd $ROOT/bin/zunit && ./build.zsh
    cd $ROOT && zunit ${args:-tests/*.zunit}
}

run $@
