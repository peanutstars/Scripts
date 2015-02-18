#!/bin/bash

# This is based from http://stackoverflow.com/questions/19606735/raspberry-pi-and-gitlab

SWAPFILE=/swapfile
SWAP_BS=1024
SWAP_COUNT=1048576
FgNeedSwap=0

fFSize() {
	ls -al $1 | awk -F\  '{ print $5 }'
}

fMkSwapFile() {
	sudo dd if=/dev/zero of=$SWAPFILE bs=$SWAP_BS count=$SWAP_COUNT
	sudo mkswap $SWAPFILE && sudo chmod 0600 $SWAPFILE && sudo swapon $SWAPFILE
}
fAddGitUser() {
	if [ ! -e "/home/git" ] ; then
		sudo adduser --disabled-login --gecos 'GitLab' git
		sudo rm -rf /home/git/* && sudo rm -rf /home/git/.*
	fi
}
fAddFstab() {
	FgSWAP=`cat /etc/fstab | grep $SWAPFILE`
	if [ -z "$FgSWAP" ] ; then
		sudo SWAPFILE=$SWAPFILE sh -c 'echo "$SWAPFILE none swap defaults 0 0" >> /etc/fstab'
	fi
}

# Free-up space by typing
#sudo apt-get purge xorg lxde xinit openbox lightdm && sudo apt-get autoremove && sudo apt-get clean

# Add some more swap space by typing
if [ ! -e "$SWAPFILE" ] ; then
	FgNeedSwap=1
else
	let "_SIZE = $SWAP_BS * $SWAP_COUNT"
	SWSIZE=`fFSize $SWAPFILE`
	if [ "$_SIZE" -ne $SWSIZE ] ; then
		sudo swapoff $SWAPFILE
		FgNeedSwap=1
	fi
fi
if [ "$FgNeedSwap" -eq "1" ] ; then
	fMkSwapFile
fi


fAddFstab
fAddGitUser

