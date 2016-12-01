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

InstallRuby() {
  local _version="$1"
  \curl -L https://get.rvm.io | sudo bash -s stable
  sudo adduser $LOGNAME rvm
  exec su -l $LOGNAME
  source /etc/profile.d/rvm.sh
  rvm install $_version
}

Usage() {
  echo "Usage: $0 <platform|program> [<parameters>...]"
  echo "  platform list:"
  echo "    ubuntu raspberrypi"
  echo "  program list:"
  echo "    ruby <version> : Install Ruby"
  exit -1
}


#### Main
cmd="$1"
shift

[ -z "$cmd" ] && Usage
[ -n "$LOGNAME" ] && sudo usermod -a -G uucp,dialout $LOGNAME
sudo apt-get update
InstallPackage Common[@]
case "$cmd" in
  ubuntu)
    InstallPackage Ubuntu[@]
    [ -z "`ps xa | grep indicator-multiload | grep -v grep`" ] \
      && indicator-multiload &
    ;;
  ruby)
    version="$1"
    [ ! "$version" ] && echo "please input a ruby version" && Usage
    InstallRuby $version
    ;;
esac
