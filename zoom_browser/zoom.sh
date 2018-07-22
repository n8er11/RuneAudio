#!/bin/bash

. /srv/http/addonstitle.sh

if ! pacman -Q chromium &> /dev/null; then
    sed -i "s/^\(zoom-level=\).*/\1$1" /root/.config/midori/config
else
    sed -i "s/\(force-device-scale-factor=\).*/\1$1" /root/.xinitrc
fi

redis-cli set zoomlevel $1 &> /dev/null

clearcache

title -l '=' "$bar Zoom level of local browser changed to $1"
