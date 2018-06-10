#!/bin/bash
# FileName: main.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-09
#
#-----------import settings-------------#
AUTO_ROOT_PATH="$(dirname "$(readlink -f "$0")")"
source "$AUTO_ROOT_PATH/settings.sh"
#----------------lock func--------------#
function is_locked()
{
    if [ -f "$lock_file" ]; then
        exit
    fi
}

function create_lock()
{
    touch "$lock_file"
}

function remove_lock()
{
    rm -f "$lock_file"
}

#----------------log func---------------#
function printLogo {
	echo "+++++++++++++++++++++++++++++++++"   >> "$log_Path"
	echo -e "[`date '+%Y-%m-%d %H:%M:%S'`] \c" >> "$log_Path"
	echo "发布了：[$TR_TORRENT_NAME]"          >> "$log_Path"
}

#------------get torrent name-----------#
get_torrent_func()
{
if [ -z "$TR_TORRENT_NAME" ]; then
    for oneTorrentID in `"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep '100%'|awk '{print $1}'`
    do
	oneTorrent=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'Name'|head -n 1|sed 's/  Name: //g'`
        if [ "$new_torrent_name" = "$oneTorrent" ]; then
	        TR_TORRENT_NAME="$oneTorrent"
	        TR_TORRENT_DIR=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'Location'|head -n 1|awk '{print $2}'`
	        break
        fi
    done
fi
}

#-------------main loop func-------------#
function main_loop()
{
    create_lock  # lock file
    IFS_OLD=$IFS
    IFS=$'\n'    
    #---loop for torrent in flexget path ---#
    for i in $(find "$flexget_path" -iname "*.torrent*" |awk -F "/" '{print $NF}')
    do  
    	new_torrent_name=`$trans_show "${flexget_path}/$i"|grep 'Name'|head -n 1|sed 's/Name: //'`
        if [ "$i" != "${new_torrent_name}.torrent" ]; then
            mv "${flexget_path}/${i}" "${flexget_path}/${new_torrent_name}.torrent"
        fi
        get_torrent_func         # get TR_NAME 
    	if [ "$new_torrent_name" = "$TR_TORRENT_NAME" ]
        then
            IFS=$IFS_OLD
            echo "+++++++++++++[start]+++++++++++++" >> "$log_Path"
            echo "[`date '+%Y-%m-%d %H:%M:%S'`] 准备发布 [$TR_TORRENT_NAME]" >> "$log_Path"
            source "$AUTO_ROOT_PATH/post/post.sh"
            rm -f "$torrentPath" # delete uploaded torrent
                   
            printLogo            # print log
            TR_TORRENT_NAME=''   # next torrent
            clean_commit_main=1
        fi
    done
    IFS=$IFS_OLD
    #---clean & remove old torrent---#
    if [ "$clean_commit_main" = '1' ]; then
        source "$AUTO_ROOT_PATH/clean/clean.sh"
    fi
}

#-------------start function------------#
if [ "$disable_AutoSeed" = "yes" ]; then
    exit
fi
#---start check---#
if [ "$(find "$flexget_path" -iname '*.torrent*')" ]; then
    is_locked
    main_loop
    remove_lock
fi
