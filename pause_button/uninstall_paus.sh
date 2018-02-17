#!/bin/bash

alias=paus

. /srv/http/addonstitle.sh

uninstallstart $@

echo -e "$bar Restore files ..."

file=/srv/http/app/templates/header.php
echo $file
sed -i '/id="pause"/ d' $file

file=/srv/http/assets/js/runeui.js
echo $file
sed -i -e 's|/\*paus\|paus\*/||
' -e '/paus0/,/paus1/ d
' $file

uninstallfinish $@
