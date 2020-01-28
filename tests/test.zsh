#!/usr/bin/env zsh

ROOT=${0:h:h:A}
PATH=$ROOT/bin/revolver:$ROOT/bin/zunit:$PATH

__zunit_output_temp_dir=$(mktemp -d)

cd $ROOT/bin/zunit && ./build.zsh
cd $ROOT && __zunit_output_temp_dir=$__zunit_output_temp_dir zunit --output-html ${@:-tests/*.zunit}

rm -rf $__zunit_output_temp_dir
unset __zunit_output_temp_dir
