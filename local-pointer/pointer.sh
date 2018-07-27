#!/bin/bash

. /srv/http/addonstitle.sh

title -l '=' "$bar Set local browser pointer ..."

if [[ $1 == 0 ]]; then
  yesno=no
  enable=enabled
else
  yesno=yes
  enable=disabled
fi

sed -i "s/\(use_cursor \).*/\1$1 \&/" /root/.xinitrc

echo -e "$bar Restart local browser ..."
killall Xorg &> /dev/null
sleep 3
xinit &> /dev/null &

title -nt "$info Local browser pointer $( tcolor $enable )."