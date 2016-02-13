#!/bin/bash

CurDir=`pwd`
KermitDir=~/kermit

fInit() {
	sudo apt-get update
	sudo apt-get install -y vim
	sudo update-alternatives --set editor /usr/bin/vim.basic
}

fInsEnv() {
	[ ! -e "$KermitDir" ] && mkdir -p $KermitDir
	[ ! -e "~/env" ] && ln -sf $CurDir/init/env ~/env
	cp -a ~/env/vimrc ~/.vimrc
	BashRc=`cat ~/.bashrc | grep shellUtils.env`
	if [ -z "$BashRc" ] ; then
		echo "" >> ~/.bashrc
		echo ". ~/env/shellUtils.env" >> ~/.bashrc
		echo ". ~/env/bash_aliases" >> ~/.bashrc
	fi
}

fInit
fInsEnv
