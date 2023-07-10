FROM ubuntu:16.04
ARG AWK
ARG NODE_VERSION=16
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y update && \
    apt-get -y install \
        --no-install-recommends \
        ca-certificates \
        curl \
        gawk \
        git \
        jq \
        php \
        zsh && \
    update-alternatives --set awk "/usr/bin/$AWK" && \
    curl -fsSL "https://deb.nodesource.com/setup_$NODE_VERSION.x" | bash - && \
    curl -fsSL 'https://dl.yarnpkg.com/debian/pubkey.gpg' | gpg --dearmor > /usr/share/keyrings/yarnkey.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main' > /etc/apt/sources.list.d/yarn.list && \
    apt-get -y update && \
    apt-get -y install \
        --no-install-recommends \
        nodejs \
        yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
