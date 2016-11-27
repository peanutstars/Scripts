#!/bin/bash

sudo apt-get update

for APP in vim git gitk ssh p7zip-fll exuberant-ctags ckermit curl meld \
        flex bison zip ncurses-dev libssl-dev openssl libtool automake \
        build-essential gcc-multilib g++-multilib libc6-dev \
        manpages-posix manpages-posix-dev \
        indicator-multiload \
        python3-pip
do
    sudo apt-get install -y $APP
done

[ -n "$LOGNAME" ] && sudo usermod -a -G uucp,dialout $LOGNAME
indicator-multiload &

