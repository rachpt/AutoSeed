#!/bin/bash
# FileName: post/judge.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-05
#
#----------------------------------------#
judge_torrent_func() {
    local base_name_search="$(echo "$dot_name"|grep -Eo '.*[12][098][0-9]{2}')"
    if [ "$(echo "$dot_name"|grep -i 'ipad'|grep -i 'BluRay')" ]; then
        local url="${postUrl%/*}/torrents.php?search=${base_name_search}+iPad+BluRay"
    elif [ "$(echo "$dot_name"|grep -i 'ipad')" ]; then
        local url="${postUrl%/*}/torrents.php?search=${base_name_search}+iPad"
    elif [ "$(echo "$dot_name"|grep -i '720p')" ]; then
        local url="${postUrl%/*}/torrents.php?search=${base_name_search}+720p"
    elif [ "$(echo "$dot_name"|grep -i '1080p')" ]; then
        local url="${postUrl%/*}/torrents.php?search=${base_name_search}+1080p"
    fi
    local search_result="$(http --ignore-stdin GET "$url" "$cookie")"
    if [ "$(echo "$search_result"|grep '搜索结果')" ]; then
        if [ "$(echo "$search_result"|grep -E '没有种子。请用准确的关键字重试|没有种子|找到0条结果')" ]; then
            up_status=1  # upload
        else
            count_item_720p=$(echo "$search_result"|grep -i '720p'|grep -i 'x264'|grep 'torrentname'|wc -l)
            count_item_1080p=$(echo "$search_result"|grep -i '1080p'|grep -i 'x264'|grep 'torrentname'|wc -l)
            count_ipad_720p=$(echo "$search_result"|grep -i 'ipad'|grep -i '720p'|grep 'torrentname'|wc -l)
            count_ipad_1080p=$(echo "$search_result"|grep -i 'ipad'|grep -i '1080p'|grep 'torrentname'|wc -l)
            #---deal with none---#
            [ ! "$count_ipad_720p" ] && count_ipad_720p=0
            [ ! "$count_ipad_1080p" ] && count_ipad_1080p=0
            [ ! "$count_item_1080p" ] && count_item_1080p=0
            [ ! "$count_item_720p" ] && count_item_720p=0
            #---nanyangpt dupe judge---#
            if [ "$postUrl" = "${post_site[nanyangpt]}/takeupload.php" ]; then
                if [ $(expr $count_item_720p - $count_ipad_720p) -le 1 ]; then
                    up_status=1  # upload
                elif [ $(expr $count_item_1080p - $count_ipad_1080p) -le 1 ]; then
                    up_status=1  # upload
                else
                    up_status=0  # give up upload
                    echo "Dupe! [${postUrl%/*}]" >> "$log_Path"
                fi
            #---normal dupe judge---#
            else
		            if [ ! "$(echo "$search_result"|grep 'torrent-title'|grep -i "$(echo "$dot_name" |grep -Eo '.*[12][098][0-9]{2}.*0p')")" ]; then
                    up_status=1  # upload
                else
                    up_status=0  # give up upload
                    echo "Dupe! [${postUrl%/*}]" >> "$log_Path"
                fi
            fi
        fi
    fi

    unset search_result base_name_search url
}

#----------------------------------------#

