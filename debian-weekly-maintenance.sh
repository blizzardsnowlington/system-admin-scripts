## weekly maintenance script
## make the necessary files and directories
sudo mkdir /var/log/topdiagnostics;
sudo touch /var/log/topdiagnostics/topdiagnostics.txt /var/log/topdiagnostics/weeklytopdump.txt /var/log/topdiagnostics/dd_dump.txt;
## install borg backup repository
sudo dnf install borgbackup
sudo mkdir /backup
sudo borg init --encryption=repokey /backup/borgbackup;


## collect diagnostic information (time+date, disk I/O, network bandwidth, CPU, and memory)
top -b > topdump.txt;
## add timestamp
timedatectl | grep Local >> /var/log/topdiagnostics.txt;
timedatectl | grep Universal | >> /var/log/topdiagnostics.txt;
## i/o test
dd if=/dev/random of=/home/blizzardsnowlington/Apps/dd/iopstester.txt bs=1G count=1 2>> /var/log/topdiagnostics.txt;
## cpu, memory
cat topdump.txt | grep 'top -' >> /var/log/topdiagnostics.txt;
cat topdump.txt | grep Tasks >> /var/log/topdiagnostics.txt;
cat topdump.txt | grep Cpu >> /var/log/topdiagnostics.txt;
cat topdump.txt | grep Mem >> /var/log/topdiagnostics.txt;
## backup before updating system
sudo borg create --stats --progress /backup/borgbackup::home-$(date '+%m%d%Y') /home;
sudo borg list /backup/borgbackup | grep -v "$(date +'%m%d%Y')" > /var/log/topdiagnostics/expired_backups;
sudo borg delete /backup/borgbackup::$(cat /var/log/topdiagnostics/expired_backups);
## system update from repository
sudo apt-get update -y
sudo apt upgrade -y;
sudo apt update -y
