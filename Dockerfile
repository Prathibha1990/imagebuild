# Installing Ubuntu  20.04
FROM ubuntu:20.04

# Making debian non_interactive
ENV DEBIAN_FRONTEND noninteractive

# Setting Up Work dir
WORKDIR /aosp/source

#Update & install required packages
RUN apt-get update \
    && apt-get install -y \
    git git-lfs gnupg flex bison build-essential zip curl zlib1g-dev \
    libc6-dev-i386 libncurses5 lib32ncurses5-dev x11proto-core-dev \
    libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc \
    unzip fontconfig python3 ccache openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN cd /usr/bin && ln -s python3 python
RUN curl -o jdk8.tgz https://android.googlesource.com/platform/prebuilts/jdk/jdk8/+archive/master.tar.gz \
    && tar -zxf jdk8.tgz linux-x86 \
    && mv linux-x86 /usr/lib/jvm/java-8-openjdk-amd64 \
    && rm -rf jdk8.tgz

# Downloading Repo    
RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo \
    && chmod a+x /usr/local/bin/repo

# Setting Up Git User email and name
RUN git config --global user.email "prathiba.l@trustonic.com" && \
    git config --global user.name "prathibha"

# Environment SetUp
ENV USE_CCACHE 1
ENV CCACHE_EXEC /usr/bin/ccache
ENV CCACHE_DIR /aosp/ccache/cache
ENV CCACHE_TEMPDIR /aosp/ccache/tmp
