#!/bin/bash
LOGFILE=/tmp/bluehost_backup.log
EXPECTED_ARGUMENTS=4
exec 6>&1           # Link file descriptor #6 with the standard output
exec > $LOGFILE     # stdout sent to $LOGFILE

#Check script arguments
if [ $# -ne $EXPECTED_ARGUMENTS ]
then
    echo "No arguments supplied."
    echo "Script usage:"
    echo " $0 bluehost_db_username bluehost_db_password target_folder dest_mail"
    exit 1
fi
USERNAME=$1
PASSWORD=$2
OUTPUT_FOLDER=$3
DEST_MAIL=$4
FILE_NAME="bluehost_db_backup_$(date +"%d%m%Y").sql.gz"
echo "Starting Bluehost Backup: $(date +"%d/%m/%Y %H:%M:%S")"
echo "Backup All Bluehost DBs"
ssh -C mornatin@mornati.net "mysqldump --opt --compress --all-databases -u $1 --password='$2' | gzip -9 -c" > $FILE_NAME
sudo mv ./$FILE_NAME $3
echo "Backup Completed: $(date +"%d/%m/%Y %H:%M:%S")!"

mail -s "Bluehost Backup Report" $DEST_MAIL < $LOGFILE
 
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
rm -f $LOGFILE
echo "Backup Completed!"
exit 0
