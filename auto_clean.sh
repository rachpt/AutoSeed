#!/bin/bash
# FileName: auto_clean.sh
#
# Author: rachpt@126.com
# Version: 1.0v
# Date: 2018-05-17
#-----------------------------#
#
# Auto clean old files/folders in 
# watch-dir which are not seeding
# on transmission#.
#
#---------Settings------------#
# Watch folder for clean.
FILE_PATH='download/torrent/path'

# Output logs.
LOG_PATH='path/of/log'

# Need transmission-remote
HOST='127.0.0.1'
PORT='9090'
USER='admin'
PASSWORD='password'

# Do not delete for some time after the modification,
# unit seconds, default 2 days(172800 s).
TimeINTERVAL=172800

# The minimum allowed disk (G)
DISK_AVAIL_MIN=50

#---------Settings------------#

IS_SEEDING()
{
    IFS=$IFS_OLD
    delete_commit=0
    if [ ! -n "$1" ]; then
        for eachTorrentID in `transmission-remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep %| awk '{print $1}'`
        do
	    eachTorrent=`transmission-remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i |grep Name|awk '{print $2}'`
        if [ '$1' = '$eachTorrent' ]; then
		    delete_commit=1
        fi
        done
    fi
    if [ ! -f $LOG_PATH ]; then
        touch $LOG_PATH
    fi

    if [ $delete_commit -eq 0 ]; then
        rm -rf "$FILE_PATH/$1"
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] deleted Torrent [$1]" >> $LOG_PATH
    fi
}

IS_FILE_OLD()
{
    IFS=$IFS_OLD
    fileDate=`stat "$FILE_PATH/$1" |grep Modify|awk '{print $2}'`
    fileTime=`stat "$FILE_PATH/$1" |grep Modify|awk '{split($3,var,"."); print var[1]}'`
    time_interval=`expr $(date +%s) - $(date -d "$fileDate $fileTime" +%s)`
    if [ $time_interval -ge $TimeINTERVAL ]; then
        echo 1
    else
        echo 0
    fi
}

COMPARER_FILE()
{
    IFS_OLD=$IFS
    IFS=$'\n'
    for i in `ls -1 $FILE_PATH`
    do
       status=`IS_FILE_OLD "$i"` 
       if [ $status -eq 1 ]; then
           IS_SEEDING "$i"
       fi
    done
    IFS=$IFS_OLD
}

DISK_CHECK()
{
    DISK_AVAIL=`df -h $FILE_PATH | grep -v Mounted | awk '{print $4}' | cut -d 'G' -f 1`
    DISK_OVER=`awk 'BEGIN{print('$DISK_AVAIL'<'$DISK_AVAIL_MIN')}'`
}

IS_OVER_USE()
{
    DISK_CHECK
    if [ "$DISK_OVER" = "1" ]; then
        for i in `transmission-remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep 100% |grep Done| awk '{print $1}'|grep -v ID`
        do
            [ "$i" -gt "0" ] && echo -n "$(date '+%Y-%m-%d %H:%M:%S') [Done] " >> $LOG_PATH
            transmission-remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $i --remove-and-delete >> $LOG_PATH 2>&1
            [ "$i" -gt "0" ] && sleep 10 && DISK_CHECK
            [ "$DISK_OVER" = "0" ] && break
        done
    fi
}

#----------Call-functions--------------#
COMPARER_FILE
IS_OVER_USE

