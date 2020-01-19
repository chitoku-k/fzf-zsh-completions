#!/usr/bin/env zsh

ROOT=${0:h:h:A}
PATH=$ROOT/bin/revolver:$ROOT/bin/zunit:$PATH

cd $ROOT/bin/zunit && ./build.zsh
cd $ROOT && zunit ${@:-tests/*.zunit}
