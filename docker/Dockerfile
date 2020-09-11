FROM ubuntu:18.04

### base
RUN yes | unminimize \
 && apt-get update \
 && apt-get install -yq \
     binutils-gold \
     build-essential \
     clang-tools-8 \
     curl \
     doxygen \
     g++-8 \
     git \
     jq \
     less \
     libcurl4-gnutls-dev \
     libgflags-dev \
     libgmp3-dev \
     libssl-dev \
     libusb-1.0-0-dev \
     lld-8 \
     llvm-7 \
     llvm-7-dev \
     locales \
     nano \
     nginx \
     ninja-build \
     pkg-config \
     python \
     sudo \
     vim \
     software-properties-common \
     wget \
     xz-utils \
     zlib1g-dev \
 && update-alternatives --remove-all cc \
 && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-8 100 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100 \
 && update-alternatives --remove-all c++ \
 && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-8 100 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 100 \
 && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-8 100 \
 && locale-gen en_US.UTF-8 \
 && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
 && apt-get install -yq \
     nodejs \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* \
 && npm i -g yarn typescript
ENV LANG=en_US.UTF-8

### cmake
WORKDIR /root
RUN curl -LO https://cmake.org/files/v3.13/cmake-3.13.2.tar.gz \
 && tar -xzf cmake-3.13.2.tar.gz \
 && cd cmake-3.13.2 \
 && ./bootstrap --prefix=/usr/local \
 && make -j8 \
 && make install \
 && cd /root \
 && rm -rf cmake-3.13.2.tar.gz cmake-3.13.2

### boost
RUN curl -LO https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.bz2 \
 && tar -xjf boost_1_72_0.tar.bz2 \
 && cd boost_1_72_0 \
 && ./bootstrap.sh --prefix=/usr/local \
 && ./b2 --with-iostreams --with-date_time --with-filesystem --with-system --with-program_options --with-chrono --with-test -j8 install \
 && cd /root \
 && rm -rf boost_1_72_0.tar.bz2 boost_1_72_0

### Gitpod user
# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
ENV HOME=/home/gitpod

### eosio
WORKDIR /root
USER root
RUN git clone https://github.com/EOSIO/eos.git \
 && cd eos \
 && git checkout develop \
 && git submodule update --init --recursive \
 && mkdir build \
 && cd build \
 && CC=clang-8 CXX=clang++-8 cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_AR=/usr/bin/llvm-ar-8 -DCMAKE_RANLIB=/usr/bin/llvm-ranlib-8 -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld .. \
 && CC=clang-8 CXX=clang++-8 ninja -j8 \
 && sudo ninja install \
 && sudo ln -s /usr/lib/x86_64-linux-gnu/cmake/eosio/ /usr/lib/cmake/eosio

### CDT
USER gitpod
WORKDIR /home/gitpod
RUN git clone https://github.com/EOSIO/eosio.cdt.git \
 && cd eosio.cdt \
 && git checkout eosio-cdt-2.1-staging-c \
 && git submodule update --init --recursive \
 && mkdir build \
 && cd build \
 && cmake -GNinja .. \
 && ninja -j8

ENV PATH="/home/gitpod/eos/build/bin/:/home/gitpod/eosio.cdt/build/bin/:${PATH}"

RUN echo "COPYING APP CONTRACTS"
COPY ./contracts /home/gitpod/contracts
COPY ./deploy_contracts.sh /home/gitpod/

### nginx, /password $HOME/contracts and deploy_contracts.sh
USER root
WORKDIR /root
RUN echo >/password && chown gitpod /password && chgrp gitpod /password \
 && chown -R gitpod /home/gitpod/contracts && chgrp -R gitpod /home/gitpod/contracts \
 && chown gitpod /home/gitpod/deploy_contracts.sh && chgrp gitpod /home/gitpod/deploy_contracts.sh \
 && >/run/nginx.pid \
 && chmod 666 /run/nginx.pid \
 && chmod 666 /var/log/nginx/* \
 && chmod 777 /var/lib/nginx /var/log/nginx

### Gitpod user (2)
WORKDIR $HOME
USER gitpod
# custom Bash prompt
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for Gitpod: success"

### wallet
RUN cleos wallet create --to-console | tail -n 1 | sed 's/"//g' >/password \
    && cleos wallet import --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
RUN echo '\n\
   unlock-timeout = 31536000 \n\
' >$HOME/eosio-wallet/config.ini

RUN echo "DEPLOYING CONTRACTS"
RUN /bin/bash /home/gitpod/deploy_contracts.sh

### checks
# no root-owned files in the home directory
RUN rm -f $HOME/.wget-hsts
WORKDIR $HOME
USER gitpod
RUN notOwnedFile=$(find . -not "(" -user gitpod -and -group gitpod ")" -print -quit) \
    && { [ -z "$notOwnedFile" ] \
        || { echo "Error: not all files/dirs in $HOME are owned by 'gitpod' user & group"; exit 1; } }
