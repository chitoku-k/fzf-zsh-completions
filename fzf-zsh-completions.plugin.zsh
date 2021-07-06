() {
    setopt local_options no_aliases
    local f
    for f in ${@:h}/src/**/*.zsh(D); do
        source "$f"
    done
} "$0"
