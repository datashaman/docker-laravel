FROM ubuntu:18.04

ARG BUILD_MIRROR="%%BUILD_MIRROR%%"
ARG BUILD_USER="%%BUILD_USER%%"

ENV DEBIAN_FRONTEND=noninteractive

RUN useradd --shell /bin/bash -u 1000 -o -c "" -m ${BUILD_USER}

RUN sed -i "s#http://archive.ubuntu.com#${BUILD_MIRROR}#g" /etc/apt/sources.list

RUN apt-get update -y \
    && apt-get install -yq --no-install-recommends \
        acl \
        apt-transport-https \
        awscli \
        ca-certificates \
        curl \
        git \
        gnupg \
        lsof \
        net-tools \
        procps \
        rsync \
        sqlite3 \
        telnet \
        tmux \
        unzip \
        vim
