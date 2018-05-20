#!/bin/bash
# FileName: auto_add.sh
#
# Author: rachpt@126.com
# Version: 1.2v
# Date: 2018-05-19
#
#-------------settings---------------#

torrent2add="${download_url}&passkey=${passkey}"

#-------------functions---------------#
function set_ratio()
{
    for eachTorrentID in `$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep %| awk '{print $1}'`
    do
	    eachTorrent=`$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i |grep Name|awk '{print $2}'`
	    set_commit=`$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i |grep "hudbt.hust.edu.cn"`
        if [ "$TR_TORRENT_NAME" = "$eachTorrent" ] && [ -n "$set_commit" ]; then
		    $trans_remote ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $eachTorrentID -sr $ratio
        fi
    done
    echo "+++++++++++++[added]+++++++++++++" >> $logoPath
}

function add_torrent()
{
    $trans_remote ${HOST}:${PORT} -n ${USER}:${PASSWORD} --add "$torrent2add" -w "$TR_TORRENT_DIR"
    sleep 10
    set_ratio
}

#-------------call function---------------#
if [ "$torrent2add" ]; then
    add_torrent
fi
