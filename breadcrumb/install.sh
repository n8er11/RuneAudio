#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=brea

. /srv/http/addonstitle.sh

installstart $@

getuninstall

echo -e "$bar Modify files ..."

file=/srv/http/app/templates/footer.php
echo $file
echo '<script src="<?=$this->asset('"'"'/js/breadcrumb.js'"'"')?>"></script>' >> $file

file=/srv/http/app/templates/playback.php
echo $file
sed -i -e '/id="db-level-up"/ {
s/^/<!--enh/
s/$/enh-->/
i\
            <div id="db-currentpath" class="hide">\
                <i id="db-home" class="fa fa-folder-open"></i> <span>Home</span>\
                <i id="db-up" class="fa fa-arrow-left"></i>\
            </div>
}
' -e '/db-currentpath/ {N;N; s/^/<!--enh/; s/$/enh-->/}
' $file

installfinish $@
