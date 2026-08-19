## daily maintanance installer

## make the necessary files and directories
sudo mkdir /var/log/topdiagnostics;
sudo touch /var/log/topdiagnostics/topdiagnostics.txt /var/log/topdiagnostics/dailytopdump.txt /var/log/topdiagnostics/dd_dump.txt;
## script to install borg backup utility
sudo dnf install borgbackup
## set up borg backup repository
sudo mkdir /backup
sudo borg init --encryption=repokey /backup/borgbackup; #creates local backup repository where backups will be stored. if you have a second drive, flash drive, or network drive, change final argument to create repository there instead. borg also stores an encryption key inside the repository folder. remember the password you set or else you will lose your backups.

## script that updates pc, backs up files, and collects diagnostic information each restart. using crontab to schedule each restart
## collect and dump diagnostics about system health
top -b > /var/log/topdiagnostics/dailytopdump.txt;
## add timestamp
timedatectl | grep Local >> /var/log/topdiagnostics/topdiagnostics.txt;
timedatectl | grep Universal >> /var/log/topdiagnostics/topdiagnostics.txt;
## i/o test
dd if=/dev/random of=/var/log/topdiagnostics/dd_dump.txt bs=1G count=1 2>> /var/log/topdiagnostics/topdiagnostics.txt;
## cpu, memory
cat /var/log/topdiagnostics/topdiagnostics.txt | grep 'top -' >> /var/log/topdiagnostics/topdiagnostics.txt;
cat /var/log/topdiagnostics/topdiagnostics.txt | grep Tasks >> /var/log/topdiagnostics/topdiagnostics.txt;
cat /var/log/topdiagnostics/topdiagnostics.txt | grep Cpu >> /var/log/topdiagnostics/topdiagnostics.txt;
cat /var/log/topdiagnostics/topdiagnostics.txt | grep Mem >> /var/log/topdiagnostics/topdiagnostics.txt;

## take a backup (before updating your system)
sudo borg create --stats --progress /backup/borgbackup::home-$(date '+%m%d%Y') /home; ## performs backup on home directory. switch final argument to /srv for servers or / if you want to keep full partition backups
sudo borg list /backup/borgbackup | grep -v "$(date +'%m%d%Y')" > /var/log/topdiagnostics/expired_backups; ## checks for any backup that was not created today and sends to tempfile
sudo borg delete /backup/borgbackup::$(cat /var/log/topdiagnostics/expired_backups); ## reads temp file and deletes any backup that was not created today

## update pc. vpn should be active, traffic will be encrypted now
sudo dnf check-update;
dnf upgrade -y;
dnf update  -y
