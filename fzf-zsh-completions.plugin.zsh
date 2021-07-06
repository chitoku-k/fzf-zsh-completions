() {
    setopt local_options no_aliases
    local f
    for f in ${0:h}/src/**/*.zsh(D); do
        source "$f"
    done
}
