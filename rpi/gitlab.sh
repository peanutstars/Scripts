#!/bin/bash

# This is based from http://stackoverflow.com/questions/19606735/raspberry-pi-and-gitlab

SWAPFILE=/swapfile

# Free-up space by typing
#sudo apt-get purge xorg lxde xinit openbox lightdm && sudo apt-get autoremove && sudo apt-get clean

# Add some more swap space by typing
if [ ! -e "$SWAPFILE" ] ; then
	sudo dd if=/dev/zero of=$SWAPFILE bs=1024 count=1048576
	sudo mkswap $SWAPFILE && sudo chmod 0600 $SWAPFILE && sudo swapon $SWAPFILE
endif

FgSWAP=`cat /etc/fstab | grep $SWAPFILE`
if [ -z "$FgSWAP" ] ; then
	sudo echo "$SWAPFILE none swap defaults 0 0" >> /etc/fstab
fi

# Add the Git user
sudo adduser --disabled-login --gecos 'GitLab' git
sudo rm -rf /home/git/* && sudo rm -rf /home/git/.*

