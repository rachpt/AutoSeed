#!/bin/bash
# FileName: post/judge.sh
#
# Author: rachpt@126.com
# Version: 2.1v
# Date: 2018-08-16
#
#----------------------------------------#
function judge_torrent()
{
    base_movie_name_search="$(echo "$new_torrent_name" |egrep -o '.*[12][098][0-9]{2}')"
    if [ "`echo "$new_torrent_name"|grep -i 'ipad'|grep -i 'BluRay'`" ]; then
        url="${postUrl%/*}/torrents.php?search=${base_movie_name_search}+iPad+BluRay"
    elif [ "`echo "$new_torrent_name"|grep -i 'ipad'`" ]; then
        url="${postUrl%/*}/torrents.php?search=${base_movie_name_search}+iPad"
    elif [ "`echo "$new_torrent_name"|grep -i '720p'`" ]; then
        url="${postUrl%/*}/torrents.php?search=${base_movie_name_search}+720p"
    elif [ "`echo "$new_torrent_name"|grep -i '1080p'`" ]; then
        url="${postUrl%/*}/torrents.php?search=${base_movie_name_search}+1080p"
    fi
    search_html_page="$(http --ignore-stdin GET "$url" "$cookie")"
    if [ "$(echo "$search_html_page"|grep '搜索结果')" ]; then
        if [ "$(echo "$search_html_page"|egrep '没有种子。请用准确的关键字重试|没有种子|找到0条结果')" ]; then
            up_status=1  # upload
        else
            count_item_720p=$(echo "$search_html_page"|grep -i '720p'|grep -i 'x264'|grep 'torrentname'|wc -l)
            count_item_1080p=$(echo "$search_html_page"|grep -i '1080p'|grep -i 'x264'|grep 'torrentname'|wc -l)
            count_ipad_720p=$(echo "$search_html_page"|grep -i 'ipad'|grep -i '720p'|grep 'torrentname'|wc -l)
            count_ipad_1080p=$(echo "$search_html_page"|grep -i 'ipad'|grep -i '1080p'|grep 'torrentname'|wc -l)
            #---deal with none---#
            [ ! "$count_ipad_720p" ] && count_ipad_720p=0
            [ ! "$count_ipad_1080p" ] && count_ipad_1080p=0
            [ ! "$count_item_1080p" ] && count_item_1080p=0
            [ ! "$count_item_720p" ] && count_item_720p=0
            #---nanyangpt dupe judge---#
            if [ "$postUrl" = "https://nanyangpt.com/takeupload.php" ]; then
                if [ $(expr $count_item_720p - $count_ipad_720p) -le 1 ]; then
                    up_status=1  # upload
                elif [ $(expr $count_item_1080p - $count_ipad_1080p) -le 1 ]; then
                    up_status=1  # upload
                else
                    up_status=0  # give up upload
                    echo "Dupe! [${postUrl%/*}]" >> "$log_Path"
                fi
            #---npupt dupe judge---#
            elif [ "$postUrl" = "https://npupt.com/takeupload.php" ]; then
                up_status=1  # upload
            #---normal dupe judge---#
            else
		            if [ ! "$(echo "$search_html_page"|grep 'torrent-title'|grep -i "$(echo "$new_torrent_name" |egrep -o '.*[12][098][0-9]{2}.*0p')")" ]; then
                    up_status=1  # upload
                else
                    up_status=0  # give up upload
                    echo "Dupe! [${postUrl%/*}]" >> "$log_Path"
                fi
            fi
        fi
    fi

    #if [ "$(egrep '禁止转载|禁转|情色' "$source_detail_desc")" ]; then
        #up_status=0  # give up upload
        ##echo "禁转资源" >> "$log_Path"
    #fi
    search_html_page=''
    base_movie_name_search=''
    url=''
}

#----------------------------------------#
judge_torrent

