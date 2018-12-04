#!/bin/bash
# FileName: post/add.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-04
#
#-------------settings----------------#

torrent2add="${download_url}&passkey=${passkey}"

#-----------call function-------------#
if [ "$one_TR_Dir" ]; then
    if [ "$postUrl" = "${post_site[whu]}/takeupload.php" ]; then
        http --ignore-stdin -d "$torrent2add" -o "${ROOT_PATH}/tmp/${t_id}.torrent"

        if [ "$TR_Client" = 'qbittorrent' ]; then
            qb_add_torrent_file
        elif [ "$TR_Client" = 'transmission' ]; then
            tr_add_torrent_file
        else
            echo 'Client Selete Error! [whu]' >> "$debug_log"
        fi
    else
        if [ "$TR_Client" = 'qbittorrent' ]; then
            qb_add_torrent_url
        elif [ "$TR_Client" = 'transmission' ]; then
            tr_add_torrent_url
        else
            echo 'Client Selete Error!' >> "$debug_log"
        fi
    fi
    echo "+++++++++++++[added]+++++++++++++" >> "$log_Path"
    rm -f "${ROOT_PATH}/tmp/${t_id}.torrent"
else
    echo "没有找到本地文件！" >> "$log_Path"
fi
