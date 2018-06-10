#!/bin/bash
# FileName: post/judge.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-09
#
#----------------------------------------#
function judge_torrent()
{
    if [ "`echo "$new_torrent_name"|grep -i 'ipad'|grep -i 'BluRay'`" ]; then
        url="${postUrl%/*}/torrents.php?search=`echo "$new_torrent_name" |egrep -o '.*[12][098][0-9]{2}'`+iPad+BluRay"
    elif [ "`echo "$new_torrent_name"|grep -i 'ipad'`" ]; then
        url="${postUrl%/*}/torrents.php?search=`echo "$new_torrent_name" |egrep -o '.*[12][12][098][0-9]{2}'`+iPad"
    elif [ "`echo "$new_torrent_name"|grep -i '720p'`" ]; then
        url="${postUrl%/*}/torrents.php?search=`echo "$new_torrent_name" |egrep -o '.*[12][098][0-9]{2}'`+720p"
    elif [ "`echo "$new_torrent_name"|grep -i '1080p'`" ]; then
        url="${postUrl%/*}/torrents.php?search=`echo "$new_torrent_name" |egrep -o '.*[12][098][0-9]{2}'`+1080p"
    fi
    no_one_here="`http --ignore-stdin GET "$url" "$cookie"|egrep '没有种子。请用准确的关键字重试|没有种子|找到0条结果'`"
    
    if [ "$no_one_here" ]; then
        up_status=1  # upload 
    else
        up_status=0  # give up upload
        echo "Dupe!" >> "$log_Path"
    fi

    if [ "$(egrep '禁止转载|禁转' "$source_detail_desc")" ]; then
        up_status=0  # give up upload
        echo "禁转资源" >> "$log_Path"
    fi

}

#----------------------------------------#
judge_torrent

