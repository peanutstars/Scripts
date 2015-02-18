#!/bin/bash

PWD=`pwd`

fInsEnv() {
	for F in env/*
	do
		echo " Install $PWD/$F"
		BF=`basename $F`
		ln -sf $PWD/$F ~/.$BF
	done
}

fInsEnv
