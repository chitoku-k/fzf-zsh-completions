FROM ubuntu:16.04
ARG AWK
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y update && \
    apt-get -y install \
        --no-install-recommends \
        gawk \
        git \
        jq \
        zsh && \
    update-alternatives --set awk "/usr/bin/$AWK" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
