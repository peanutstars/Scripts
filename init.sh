#!/bin/bash

CurDir=`pwd`
Home=/home/$LOGNAME
KermitDir=$HOME/kermit

fInit() {
	sudo apt-get update
	sudo apt-get install -y vim
	sudo update-alternatives --set editor /usr/bin/vim.basic
}

fInsEnv() {
	[ ! -e "$KermitDir" ] && mkdir -p $KermitDir
	[ ! -e "$HOME/env" ] && ln -sf $CurDir/init/env $HOME/env
	for EF in vimrc bash_aliases gitconfig
	do
		cp -a $HOME/env/$EF $HOME/.$EF
	done
	BASHRC=`cat $HOME/.bashrc | grep shellUtils.env`
	if [ -z "$BASHRC" ] ; then
		echo "" >> $HOME/.bashrc
		echo "##### Private Configuration" >> $HOME/.bashrc
		echo ". ~/env/shellUtils.env" >> $HOME/.bashrc
        echo "[ -r \"/etc/profile.d/rvm.sh\" ] && . /etc/profile.d/rvm.sh"
	fi
}

fInit
fInsEnv
