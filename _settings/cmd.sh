#!/bin/bash

alias ls='ls -a --color --group-directories-first'
export LS_COLORS='tw=01;34:ow=01;34:ex=00;32:or=31'

tcolor() { 
	echo -e "\e[38;5;10m$1\e[0m"
}

sstt() {
	echo -e '\n'$( tcolor "systemctl status $1" )'\n'
	systemctl status $1
}
ssta() {
	echo -e '\n'$( tcolor "systemctl start $1" )'\n'
	systemctl start $1
}
ssto() {
	echo -e '\n'$( tcolor "systemctl stop $1" )'\n'
	systemctl stop $1
}
sres() {
	echo -e '\n'$( tcolor "systemctl restart $1" )'\n'
	systemctl restart $1
}
srel() {
	echo -e '\n'$( tcolor "systemctl reload $1" )
	systemctl reload $1
}
sdrel() {
	echo -e '\n'$( tcolor "systemctl daemon-reload" )'\n'
	systemctl daemon-reload
}

mmc() {
	[[ $2 ]] && mntdir=/tmp/$2 || mntdir=/tmp/p$1
	if [[ ! $( mount | grep $mntdir ) ]]; then
		mkdir -p $mntdir
		mount /dev/mmcblk0p$1 $mntdir
	fi
}

bootx() {
 	if [[ -e /root/reboot.py ]]; then
	 	/root/reboot.py $1
		exit
	fi
 	echo $1 > /sys/module/bcm2709/parameters/reboot_part
 	/var/www/command/rune_shutdown
 	reboot
}
bootosmc() {
 	bootx 6 &
}
bootrune() {
	bootx 8 &
}

setup() {
	if [[ ! -e /etc/motd.logo ]]; then
		echo -e "\e[36m\e[46m . \e[0m Set date-time ..."
		systemctl stop ntpd
		ntpdate pool.ntp.org
		systemctl start ntpd
		wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/setup.sh
		chmod +x setup.sh
		./setup.sh
	else
		echo -e "\e[30m\e[43m ! \e[0m Already setup."
	fi
}
resetosmc() {
	. osmcreset n
	if [[ $success != 1 ]]; then
		echo -e "\e[37m\e[41m ! \e[0m OSMC reset failed."
		return
	fi
	# preload initial setup
	wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/presetup.sh
	. presetup.sh
	# preload command shortcuts
	mmc 7
	wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/cmd.sh -P /tmp/p7/etc/profile.d
	
	[[ $ansre == 1 ]] && bootosmc
}

hardreset() {
	echo -e "\n\e[30m\e[43m ? \e[0m Reset to virgin OS:"
	echo -e '  \e[36m0\e[m Cancel'
	echo -e '  \e[36m1\e[m OSMC'
	echo -e '  \e[36m2\e[m NOOBS: OSMC + Rune'
	echo
	echo -e '\e[36m0\e[m / 1 / 2 ? '
	read -n 1 ans
	echo
	case $ans in
		1) resetosmc;;
		2) noobsreset;;
		*) ;;
	esac
}
