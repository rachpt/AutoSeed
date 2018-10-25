#!/bin/bash
# FileName: clean/clean.sh
#
# Author: rachpt@126.com
# Version: 2.4.2v
# Date: 2018-10-23
#-----------------------------#
#
# Auto clean old files/folders in 
# watch-dir which are not seeding
# on transmission#.
#
#---------Settings------------#

#-----------------------------#
# 删除红种(被删的种)，不会删除下载的数据
DELTE_OLD_and_ERROE_TORRENT() {
    for eachTorrentID in `"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep '[1]\?[0-9]\{1,2\}%'|awk '{print $1}'|sed "s/\*//g"`
    do
        #---error torrent---#
        if [ "`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i|grep 'torrent not registered with this tracker'`" ]; then
            "$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -r
        fi
        #---old torrent---#
        seed_time=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i|grep 'Seeding Time'|grep 'days'|cut -d : -f 2|awk '{print $1}'`
        
        [ "$seed_time" ] && if [ $seed_time -ge $MAX_SEED_TIME ]; then
            "$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -r
        fi
        #---finished torrent---#
        if [ "`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i|grep 'State:'|grep 'Finished'`" ]; then
            "$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -r
        fi
    done
}
#-----------------------------#
# 判断目录下的文件或者文件夹是否处于做种中，否则删掉 数据
IS_SEEDING() {
    IFS=$IFS_OLD
    delete_commit=0
    if [ -n "$1" ]; then
        for eachTorrentID in `"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep '%'| awk '{print $1}'`
        do
            eachTorrent=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i |grep 'Name'|head -n 1|awk '{print $2}'`
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
#-----------------------------#
# 用于处理长时间下载某个种子情况，超过设定时间下载未完成，则删之。
IS_FILE_OLD() {
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
#-----------------------------#
# 比较文件是否在 TR 做种列表中
COMPARER_FILE_and_DELETE() {
    IFS_OLD=$IFS
    IFS=$'\n'
    for i in `ls -1 $FILE_PATH`
    do
       old_status=`IS_FILE_OLD "$i"` 
       if [ $old_status -eq 1 ]; then
           IS_SEEDING "$i"
       fi
    done
    IFS=$IFS_OLD
}
#-----------------------------#
# 检查磁盘可用空间大小
DISK_CHECK() {
    DISK_AVAIL=`df -h $FILE_PATH | grep -v Mounted | awk '{print $4}' | cut -d 'G' -f 1`
    DISK_OVER=`awk 'BEGIN{print('$DISK_AVAIL'<'$DISK_AVAIL_MIN')}'`
}
#-----------------------------#
# 判断磁盘可用空间是否低于阈值，是则删掉 TR 靠前的种子，直到不低于阈值。
DISK_IS_OVER_USE() {
    DISK_CHECK
    if [ "$DISK_OVER" = "1" ]; then
        for i in `"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep 100% |grep Done| awk '{print $1}'|grep -v ID`
        do
            [ "$i" -gt "0" ] && echo -n "$(date '+%Y-%m-%d %H:%M:%S') [Done] " >> "$log_Path"
            "$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $i --remove-and-delete >> "$log_Path" 2>&1
            [ "$i" -gt "0" ] && sleep 10 && DISK_CHECK
            [ "$DISK_OVER" = "0" ] && break
        done
    fi
}

#---------call func-----------#
echo "+++++++++++++[clean]+++++++++++++" >> "$log_Path"

if [ "$TR_TORRENT_DIR" ]; then
        FILE_PATH="$TR_TORRENT_DIR"
    else
        FILE_PATH="$default_FILE_PATH"
fi

DELTE_OLD_and_ERROE_TORRENT
COMPARER_FILE_and_DELETE
DISK_IS_OVER_USE

echo -e "++++++++++++++[end]++++++++++++++\n"   >> "$log_Path"
