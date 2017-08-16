How To
---
**Issues**  
- RuneAudio 'Backup' works but `redis-cli save` was missing before backup
- Restore with 'Upload' was disabled for pending code

**Fixes**  
- Backup:
    - add `redis-cli save`
    - include `/mnt/MPD/Webradio`
    - exclude unnecessary `/etc/netctl/examples`
    - delete previous temporary file
- Restore:
    - remove default form event to avoid page change
    - upload file by ajax instead
    - use new php script to upload file
- Write permission:
    - http user cannot write outside `./http` or `sudo` bash commands directly
    - allow no password sudo in `/etc/sudoers.d`
    - use external bash script to restore
    
**Install**
```sh
wget -qN --show-progress https://raw.githubusercontent.com/rern/RuneAudio/master/backup-restore/install.sh; chmod +x install.sh; ./install.sh
```