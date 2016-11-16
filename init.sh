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
	for EF in vimrc bash_aliases gitconfig
	do
		cp -a ~/env/$EF ~/.$EF
	done
	BASHRC=`cat ~/.bashrc | grep shellUtils.env`
	if [ -z "$BASHRC" ] ; then
		echo "" >> ~/.bashrc
		echo "##### Private Configuration" >> ~/.bashrc
		echo ". ~/env/shellUtils.env" >> ~/.bashrc
	fi
}

fInit
fInsEnv
