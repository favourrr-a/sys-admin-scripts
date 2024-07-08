#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: backup.sh <source_directory> <target_directory> [<schedule>]"
    echo "	shedule can be 'daily', 'weekly', or 'monthly'"
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


setup_cronjob(){
	local cron_command="bash $(realpath "$0") $1 $2"

	case $3 in
	        daily)
        	        (crontab -l ; echo "0 12 * * * $cron_command") | crontab -
                	;;
        	weekly)
                	(crontab -l ; echo "0 12 * * 0 $cron_command") | crontab -
                	;;
        	monthly)
                	(crontab -l ; echo "0 12 1 * * $cron_command") | crontab -
               	 	;;
       	 	*)
                	echo "Invalid schedule option. Please use 'daily', 'weekly', or 'monthly'"
                	exit 1
        		;;
	esac

	if [ $? -eq 0 ]; then
		echo "Cron job set up successfully"
	else
		echo "Failed to set up cron job"
	fi
}

setup_cronjob "$1" "$2" "$3"
