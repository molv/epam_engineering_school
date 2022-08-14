#!/bin/bash
#
#This scrips checks backup dir and sends email if threshold value (size\file count) has reached
#
#
RED='\033[0;31m'
NC='\033[0m' # No Color

LOG=/var/log/backup_mail.log
BACKUP=/local/backups
LOCKFILE=/run/lock/backup_mail.pid
MAILTO=root

#functions#############################################################
usage()
{
echo "This scrips checks backup dir and sends email if threshold value (size\file count) has reached"
echo -e "USAGE: \n -c 'num' Checks the number of files in the backup directory \n -s 'size in bytes' Checks size of the backup directory "
}

files_count()
{
COUNT=`find $BACKUP -type f |wc -l`
}

dir_size()
{
SIZE=`du -sb $BACKUP |cut -f1`
}

mail_count()
{
sendmail -i $MAILTO <<MAIL_END
Subject: Backup directory notification

There is $COUNT files in backup directory.
Limit is $COUNT_FLAG files.
MAIL_END
}

mail_size()
{
sendmail -i $MAILTO <<MAIL_END
Subject: Backup directory notification

Backup directory size is $SIZE bytes.
Limit is $SIZE_FLAG bytes.
MAIL_END
}

lock_del()
{
rm -f $LOCKFILE
}

#options#############################################################

while getopts ":c:s:hh:" arg
do
case $arg in
h)  usage ; exit 0 ;; #how to use
c)  COUNT_FLAG=${OPTARG} ;;  #file count mode
s)  SIZE_FLAG=${OPTARG} ;;  #dir size mode
esac
done

#execution mode was not chosen
if
[[ -z $COUNT_FLAG ]] && [[ -z $SIZE_FLAG ]];
then
echo -e "${RED}You have to choose execution mode. Please read help ${NC}\n"
usage
exit 1
fi

echo "`date +"%Y.%m.%d-%H:%M:%S"`: Lock file check" >> $LOG

if
[ -e $LOCKFILE ]; then
echo "`date +"%Y.%m.%d-%H:%M:%S"`: There is lock file, exiting." >> $LOG
exit 1
fi

if
[ ! -e $LOCKFILE ]; then
echo "$$" > $LOCKFILE
echo "`date +"%Y.%m.%d-%H:%M:%S"`: No lock file found, executing checks." >> $LOG
fi

#execute count mode
if
[[ -n $COUNT_FLAG ]];
then
files_count
    if
    [[ $COUNT -le $COUNT_FLAG ]];
    then
    echo "File threshold of $COUNT_FLAG files has not been reached"
    else
    echo "File threshold of $COUNT_FLAG has been reached. There is $COUNT files"
    mail_count
    fi
fi


#execute size mode
if
[[ -n $SIZE_FLAG ]];
then
dir_size
    if
    [[ $SIZE -le $SIZE_FLAG ]];
    then
    echo "Size threshold of $SIZE_FLAG bytes has not been reached. Dir size is $SIZE bytes"
    else
    echo "Size threshold of $SIZE_FLAG bytes has been reached. Dir size is $SIZE bytes"
    mail_size
    fi
fi

echo "`date +"%Y.%m.%d-%H:%M:%S"`: Task is completed." >> $LOG
lock_del
[[ $(find $LOG -type f -size +1M 2>/dev/null) ]] && echo  "`date +"%Y.%m.%d-%H:%M:%S"`: Truncating log file" > $LOG
