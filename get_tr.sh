#!/bin/bash
# FileName: get_tr.sh
#
# Author: rachpt@126.com
# Version: 1.5v
# Date: 2018-05-22
#
#------------------------------------#
#---path---#
if [ -z "$TR_TORRENT_NAME" ]; then
    for eachTorrentID in `$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep '100%'|awk '{print $1}'`
    do
	eachTorrent=`$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i |grep 'Name'|head -n 1|sed 's/  Name: //g'`
        if [ "$new_torrent_name" = "$eachTorrent" ]; then
	        TR_TORRENT_NAME="$eachTorrent"
	        TR_TORRENT_DIR=`$trans_remote ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $eachTorrentID -i |grep 'Location'|head -n 1|awk '{print $2}'`
	        break
        fi
    done
fi
   
#------------------------------------#
