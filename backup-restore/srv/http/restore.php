<?php
$file = $_FILES['filebackup'];
$filename = $file['name'];
$filetmp = $file['tmp_name'];
$filedest = '/srv/http/tmp/'.$filename;
$filesize = filesize($filetmp);

if ($filesize === 0) die('File upload error !');
if (! move_uploaded_file($filetmp, $filedest)) die('File move error !');

$restore = exec("sudo /srv/http/restore.sh $filedest; echo $?");

if ($restore == 0) {
	echo 'Restored successfully.';
} else {
	echo 'Restore failed !';
}
