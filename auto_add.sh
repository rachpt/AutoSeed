#!/bin/bash
# FileName: auto_add.sh
#
# Author: rachpt@126.com
# Version: 1.5v
# Date: 2018-05-22
#
#-------------settings---------------#

torrent2add="${download_url}&passkey=${passkey}"

#-------------functions---------------#
function set_ratio()
{
    for eachTorrentID in `$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep %| awk '{print $1}'`
    do
	    eachTorrent=`$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i |grep Name|awk '{print $2}'`
	    set_commit_hust=`$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i |grep "hudbt.hust.edu.cn"`
	    set_commit_whu=`$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i |grep "whupt"`
        if [ "$TR_TORRENT_NAME" = "$eachTorrent" ] && [ -n "$set_commit_hust" ]; then
		    $trans_remote ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $eachTorrentID -sr $ratio_hudbt
        fi

        if [ "$TR_TORRENT_NAME" = "$eachTorrent" ] && [ -n "$set_commit_whu" ]; then
		    $trans_remote ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $eachTorrentID -sr $ratio_whu
        fi
    done
    echo "+++++++++++++[added]+++++++++++++" >> $log_Path
}

function add_torrent()
{
    $trans_remote ${HOST}:${PORT} -n ${USER}:${PASSWORD} --add "$torrent2add" -w "$TR_TORRENT_DIR"
    set_ratio
}

#-------------call function---------------#
if [ "$torrent2add" ]; then
    add_torrent
fi
