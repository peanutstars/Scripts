#!/bin/bash

sudo apt-get update
sudo apt-get install vim git gitk ssh subversion gawk aptitude
sudo apt-get install p7zip-full exuberant-ctags ckermit wget curl meld
sudo apt-get install flex bison gperf zip ncurses-dev libssl-dev openssl 
sudo apt-get install minissdpd
sudo apt-get install squashfs-tools
sudo apt-get install libtool automake ccache
sudo apt-get install build-essential
sudo apt-get install gcc-multilib
sudo apt-get install g++-multilib
sudo apt-get install libc6-dev zlib1g-dev
sudo apt-get install libncurses5-dev:i386 libreadline6-dev:i386 zlib1g-dev:i386
sudo apt-get install manpages-posix manpages-posix-dev
sudo usermod -a -G uucp,dialout `whoami`
