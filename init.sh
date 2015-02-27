#!/bin/bash

PWD=`pwd`

fInit() {
	sudo apt-get update
	sudo apt-get install -y vim
}

fInsEnv() {
	for F in init/env/*
	do
		echo " Install $PWD/$F"
		BF=`basename $F`
		ln -sf $PWD/$F ~/.$BF
	done
}

fInit
fInsEnv
