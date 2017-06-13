#!/bin/bash

rm install.sh

line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )

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
titleend() {
	echo -e "\n$1"
	echo -e "\n$line\n"
}

label=$(e2label /dev/sda1)
title "$info Rename current USB label, $label:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo
		echo 'New label: '
		read -n 1 label
		e2label /dev/sda1 $label
		;;
	* ) echo;;
esac

if ! grep -qs "/mnt/MPD/USB/$label" /proc/mounts; then
	titleend "$info Hard drive not mount at /mnt/MPD/USB/$label"
	exit
fi

wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/aria2/uninstall_aria.sh
chmod +x uninstall_aria.sh

if  grep '^Server = http://mirror.archlinuxarm.org/' /etc/pacman.d/mirrorlist; then
	wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/rankmirrors/rankmirrors.sh
	chmod +x rankmirrors.sh
	./rankmirrors.sh
fi
if ! pacman -Q aria2 &>/dev/null; then
	title2 "Install Aria2 ..."
	pacman -Sy --noconfirm aria2 glibc
else
	titleend "$info Aria2 already installed."
	exit
fi

title "Get WebUI files ..."
wget -qN --show-progress https://github.com/ziahamza/webui-aria2/archive/master.zip
mkdir /usr/share/nginx/html/aria2
bsdtar -xf master.zip -s'|[^/]*/||' -C /usr/share/nginx/html/aria2/
rm master.zip

[[ ! -e /media/$label ]] && mkdir /media; ln -s /mnt/MPD/USB/$label/ /media/$label
mkdir -p /media/$label/aria2
[[ ! -e /root/.config/aria2 ]] && mkdir -p /root/.config/aria2
echo 'enable-rpc=true
rpc-listen-all=true
daemon=true
disable-ipv6=true
dir=/media/$label/aria2
max-connection-per-server=4
' > /root/.config/aria2/aria2.conf

echo '[Unit]
Description=Aria2
After=network-online.target
[Service]
Type=forking
ExecStart=/usr/bin/aria2c
[Install]
WantedBy=multi-user.target
' > /usr/lib/systemd/system/aria2.service

if ! grep -qs 'aria2' /etc/nginx/nginx.conf; then
	sed -i '/end http block/ i\
	    server { #aria2\
		listen 88;\
		location / {\
		    root  /usr/share/nginx/html/aria2;\
		    index  index.php index.html index.htm;\
		}\
	    } #aria2
	' /etc/nginx/nginx.conf
fi

title "Restart nginx ..."
systemctl restart nginx

title "$info Start Aria2 on system startup:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) systemctl enable aria2;;
	* ) echo;;	
esac

title "$info Start Aria2 now:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) systemctl start aria2;;
	* ) echo;;	
esac

title2 "Aria2 successfully installed."
echo 'Uninstall: ./uninstall_aria.sh'
echo 'Start: systemctl start aria2'
echo 'Stop: systemctl stop aria2'
echo 'Download directory: /media/$label/aria2'
titleend "WebUI: [RuneAudio_IP]:88"
