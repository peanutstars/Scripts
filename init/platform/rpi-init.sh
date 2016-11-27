#!/bin/bash

sudo apt-get update

for APP in vim git p7zip-fll exuberant-ctags curl \
        flex bison zip ncurses-dev libssl-dev openssl libtool automake \
        build-essential gcc-multilib g++-multilib libc6-dev \
        manpages-posix manpages-posix-dev \
        python3-pip
do
    sudo apt-get install -y $APP
done

[ -n "$LOGNAME" ] && sudo usermod -a -G uucp,dialout $LOGNAME

