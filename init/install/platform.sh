#!/bin/bash

#### Configuration
Common=( "vim" "git" "ssh" "exuberant-ctags" "ckermit" "curl"
  "zip" "ncurses-dev" "libssl-dev" "openssl" "libtool" "automake"
  "python3-pip" "flex" "bison"
  "build-essential" "gcc-multilib" "g++-multilib" "libc6-dev"
  "libreadline6-dev" "libyaml-dev" "libsqlite3-dev" "sqlite3"
  "manpages-posix" "manpages-posix-dev"
)

Ubuntu=( "indicator-multiload" )


#### Functions
InstallPackage() {
  local _param="${!1}"
  for App in $_param
  do
    sudo apt-get install -y $App
  done
}

Usage() {
  echo "Usage: $0 <platform>"
  echo "  platform list:"
  echo "    ubuntu raspberrypi"
}


#### Main
cmd="$1"

[ -z "$cmd" ] && Usage && exit 1
[ -n "$LOGNAME" ] && sudo usermod -a -G uucp,dialout $LOGNAME
sudo apt-get update
InstallPackage Common[@]
case "$cmd" in
  ubuntu)
    InstallPackage Ubuntu[@]
    [ -z "`ps xa | grep indicator-multiload | grep -v grep`" ] \
      && indicator-multiload &
    ;;
esac
