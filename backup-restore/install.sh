#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=back

. /srv/http/addonstitle.sh
. /srv/http/addonsedit.sh

installstart $@

getuninstall

echo -e "$bar Modify files ..."

dir=/srv/http/tmp
echo $dir
mkdir -p $dir
#----------------------------------------------------------------------------------
file=/srv/http/app/libs/runeaudio.php
echo $file

comment '/run/backup_' 'mpdscribble.conf /etc/spop'

string=$( cat <<'EOF'
        $filepath = '/srv/http/tmp/backup_'.date( 'Ymd' ).'.tar.gz';
        $cmdstring = 'rm -f /srv/http/tmp/backup_* &> /dev/null; '.
            'redis-cli save; '.
            'bsdtar -czpf '.$filepath.
                ' --exclude /etc/netctl/examples'.
                ' /etc/netctl'.
                ' /mnt/MPD/Webradio'.
                ' /var/lib/redis/rune.rdb'.
                ' /var/lib/mpd'.
                ' /etc/mpd.conf'.
                ' /etc/mpdscribble.conf'.
                ' /etc/spop';
EOF
)
insert 'mpdscribble.conf /etc/spop'
#----------------------------------------------------------------------------------
file=/srv/http/app/templates/settings.php
echo $file

commentH -n -3 'Restore player config'

string=$( cat <<'EOF'
    <form class="form-horizontal" id="restore">
EOF
)
appendH -n -3 'Restore player config'

commentH 'Browse...'

string=$( cat <<'EOF'
                            Browse... <input type="file" accept=".tar.gz" id=="filebackup" name="filebackup">
EOF
)
appendH 'Browse...'

commentH 'id="btn-backup-upload"'

string=$( cat <<'EOF'
                    <button id="btn-restore" class="btn btn-primary btn-lg" disabled>Restore</button>
EOF
)
appendH 'id="btn-backup-upload"'
#----------------------------------------------------------------------------------
file=/srv/http/app/templates/footer.php
echo $file

[[ -e $file.backup ]] && file=$file.backup

string=$( cat <<'EOF'
<script src="<?=$this->asset('/js/backuprestore.js')?>"></script>
EOF
)
appendH '$'
#----------------------------------------------------------------------------------

echo -e "$bar Add new files ..."

#----------------------------------------------------------------------------------
file=/srv/http/assets/js/backuprestore.js
echo $file

string=$( cat <<'EOF'
$( '#filebackup' ).on( 'change', function() {
	var label = $( this ).val().split( /[\\/]/ ).pop();
	if ( label.indexOf( '.tar.gz' ) === -1 ) {
		$( '#backup-file' ).html( '<i class="fa fa-times dx red"></i> not a valid backup file');
		return;
	}
	$( '#backup-file' ).html( '<i class="fa fa-check dx green"> </i>'+ label );
	$( '#btn-backup-upload' ).prop( 'disabled', false );
} );
$( '#restore' ).submit( function() {
    var formData = new FormData( $( this )[ 0 ] );
    $.ajax( {
        url: 'restore.php',
        type: 'POST',
        data: formData,
        cache: false,
        contentType: false,
        enctype: 'multipart/form-data',
        processData: false,
        success: function ( response ) {
			info( {
				  icon    : response == 0 ? 'info-circle' : 'warning'
				, title   : 'Restore Settings' 
				, message : 'Settings restored '+ response == 0 ? 'successfully.' : 'failed.'
			} );
        }
    });
    return false
} );
$( '#btn-restore' ).click( function() {
	$( '#restore' ).submit();
} );
EOF
)
echo "$string" > $file
#----------------------------------------------------------------------------------
file=/srv/http/backuprestore.php
echo $file

string=$( cat <<'EOF'
<?php
$file = $_FILES[ 'filebackup' ];
$filename = $file[ 'name' ];
$filetmp = $file[ 'tmp_name' ];
$filedest = '/srv/http/tmp/'.$filename;
$filesize = filesize( $filetmp );

if ( !$filesize ) die( '-1' );

exec( 'rm -f /srv/http/tmp/backup_*' );
if ( ! move_uploaded_file( $filetmp, $filedest ) ) die( 'File move error !' );

echo exec( 'sudo /srv/http/backuprestore.sh "'.$filedest.'"; echo $?' );
EOF
)
echo "$string" > $file
#----------------------------------------------------------------------------------
file=/srv/http/backuprestore.sh
echo $file

string=$( cat <<'EOF'
#!/bin/bash

systemctl stop mpd redis
bsdtar -xpf "$1" -C /
rm "$1"
systemctl start mpd redis
mpc update Webradio
hostnamectl set-hostname $( redis-cli get hostname )
sed -i "s/opcache.enable=./opcache.enable=$( redis-cli get opcache )/" /etc/php/conf.d/opcache.ini
EOF
)
echo "$string" > $file
#----------------------------------------------------------------------------------
file=/etc/sudoers.d/http-backup
echo $file

string=$( cat <<'EOF'
http ALL=NOPASSWD: ALL
EOF
)
echo "$string" > $file
#----------------------------------------------------------------------------------
chmod 755 /srv/http/backuprestore.* /srv/http/tmp
chown http:http /srv/http/backuprestore.* /srv/http/tmp

installfinish $@

reinitsystem
