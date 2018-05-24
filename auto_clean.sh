#!/bin/bash
# FileName: auto_clean.sh
#
# Author: rachpt@126.com
# Version: 1.2v
# Date: 2018-05-19
#-----------------------------#
#
# Auto clean old files/folders in 
# watch-dir which are not seeding
# on transmission#.
#
#---------Settings------------#

#-----------------------------#
ERROE_TR()
{
    for eachTorrentID in `$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep '[0-9]\*'|awk '{print $1}'|awk -F '*' '{print $1}'`
    do
        if [ "`$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i|grep 'torrent not registered with this tracker'`" ]; then
            $trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -r
        fi
    done
}

IS_SEEDING()
{
    IFS=$IFS_OLD
    delete_commit=0
    if [ -n "$1" ]; then
        for eachTorrentID in `$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep %| awk '{print $1}'`
        do
	    eachTorrent=`$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i |grep Name|head -n 1|awk '{print $2}'`
        if [ "$1" = "$eachTorrent" ]; then
		    delete_commit=1
        fi
        done

        if [ $delete_commit -eq 0 ]; then
            rm -rf "$FILE_PATH/$1"
            echo "[`date '+%Y-%m-%d %H:%M:%S'`] deleted Torrent [$1]" >> $log_Path
        fi
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
        for i in `$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep 100% |grep Done| awk '{print $1}'|grep -v ID`
        do
            [ "$i" -gt "0" ] && echo -n "$(date '+%Y-%m-%d %H:%M:%S') [Done] " >> $log_Path
            $trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $i --remove-and-delete >> $log_Path 2>&1
            [ "$i" -gt "0" ] && sleep 10 && DISK_CHECK
            [ "$DISK_OVER" = "0" ] && break
        done
    fi
}

#----------call func--------------#
echo "+++++++++++++[clean]+++++++++++++" >> $log_Path

if [ -z "$default_FILE_PATH" ]; then
        FILE_PATH="$TR_TORRENT_DIR"
    else
        FILE_PATH="$default_FILE_PATH"
fi

COMPARER_FILE
ERROE_TR
IS_OVER_USE

