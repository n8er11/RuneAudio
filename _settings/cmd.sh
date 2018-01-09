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
sdre() {
	echo -e '\n'$( tcolor "systemctl daemon-reload" )'\n'
	systemctl daemon-reload
}
sfpm() {
	echo -e '\n'$( tcolor "systemctl reload php-fpm" )'\n'
	systemctl reload php-fpm
}

mmc() {
	[[ $2 ]] && mntdir=/tmp/$2 || mntdir=/tmp/p$1
	if [[ ! $( mount | grep $mntdir ) ]]; then
		mkdir -p $mntdir
		mount /dev/mmcblk0p$1 $mntdir
	fi
}
pacmancache() {
	[[ -L /var/cache/pacman ]] && exit
	rm -r /var/cache/pacman
	ln -sf /mnt/MPD/USB/hdd/varcache/pacman /var/cache/pacman
}

setup() {
	if [[ -e /usr/local/bin/uninstall_addo.sh ]]; then
		echo -e "\e[30m\e[43m ! \e[0m Already setup."
	else
		wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/setup.sh
		if [[ $? == 5 ]]; then
			echo -e "\e[38;5;6m\e[48;5;6m . \e[0m Sync time ..."
			systemctl stop ntpd
			ntpdate pool.ntp.org
			systemctl start ntpd
			wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/setup.sh
		fi
		chmod +x setup.sh
		./setup.sh
	fi
}

boot() {
	mmc 5
	part=$( sed -n '/name/,/mmcblk/ p' /tmp/p5/installed_os.json | sed '/part/ d; s/\s//g; s/"//g; s/,//; s/name://; s/\/dev\/mmcblk0p//' )
	partarray=( $( echo $part ) )

	ilength=${#partarray[*]}

	echo -e "\n\e[30m\e[43m ? \e[0m Reboot to OS:"
	echo -e '  \e[36m0\e[m Cancel'
	for (( i=0; i < ilength; i++ )); do
		(( $(( i % 2 )) == 0 )) && echo -e "  \e[36m$(( i / 2 + 1 ))\e[m ${partarray[ i ]}"
	done
	echo
	echo 'Which ? '
	read -n 1 ans
	echo
	[[ -z $ans || $ans == 0 ]] && return
	partboot=$(( ans * 2 + 4 ))
 	if [[ -e /root/reboot.py ]]; then
	 	/root/reboot.py $partboot
		exit
	fi
	
 	echo $partboot > /sys/module/bcm2709/parameters/reboot_part
 	/var/www/command/rune_shutdown 2> /dev/null; reboot
}
