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
	for F in init/env/*
	do
		echo " Install $CurDir/$F"
		BF=`basename $F`
		ln -sf $CurDir/$F ~/.$BF
	done
}

fInit
fInsEnv
