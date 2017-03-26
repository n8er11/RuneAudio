#!/bin/bash

line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )

# functions #######################################
title2() {
	echo -e "\n$line2\n"
	echo -e "$bar $1"
	echo -e "\n$line2\n"
}
title() {
	echo -e "\n$line"
	echo $1
	echo -e "$line\n"
}

# check installed #######################################
if ! pacman -Q transmission-cli > /dev/null 2>&1; then
	title "$info Transmission not found."
	exit
fi

title2 "$bar Uninstall Transmission ..."
# uninstall package #######################################
pacman -Rs --noconfirm transmission-cli

# remove files #######################################
title "Remove files ..."
rm -rfv /var/lib/transmission/.config/transmission-daemon

title2 "$bar Transmission successfully uninstalled."

rm tranuninstall.sh
