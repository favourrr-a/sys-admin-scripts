#! bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: backup.sh <source_directory> <target_directory>"
    exit 1
fi

if ! command -v rsync > /dev/null 2>&1; then
    echo "rsync command not found"
    exit 2
fi


current_date=$(date +%Y-%m-%d)

backup_file="$2/backup-$current_date.tar.gz"
backup_log="$2/backup-$current_date.log"

if [ ! -d "$2" ]; then
    mkdir -p "$2"
fi

rsync_options="-avb --backup-dir $2/$current_date --delete "

$(which rsync) $rsync_options $1 $2/current-$current_date >> $backup_log

tar -czf $backup_file $1 

if [ $? -eq 0 ]; then
    echo "Backup of $1 completed successfully"
else
    echo "Backup of $1 failed"
fi