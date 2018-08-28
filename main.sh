#!/bin/bash
# FileName: main.sh
#
# Author: rachpt@126.com
# Version: 2.2v
# Date: 2018-06-23
#
#-----------import settings-------------#
AUTO_ROOT_PATH="$(dirname "$(readlink -f "$0")")"
source "$AUTO_ROOT_PATH/settings.sh"
source "$AUTO_ROOT_PATH/test.sh"
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
    rm -f "$source_detail_desc" "$source_detail_html"
}

#----------------log func---------------#
write_log_main()
{
    echo "+++++++++++++++++++++++++++++++++"   >> "$log_Path"
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]\c"  >> "$log_Path"
    echo "发布了：[$TR_TORRENT_NAME]"          >> "$log_Path"
}

#------------get torrent name-----------#
get_torrent_func()
{
if [ -z "$TR_TORRENT_NAME" ]; then
    for oneTorrentID in `"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep '100%'|awk '{print $1}'|sed 's/\*//g'|sort -nr`
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
        #---.tr file path---#
        torrentPath="${flexget_path}/${new_torrent_name}.torrent"
        #---use dot name save desc---#
        dot_name="$(echo "$new_torrent_name"|sed "s/[ ]\+/./g;s/\(.*\)\.mp4/\1/g;s/\(.*\)\.mkv/\1/g")"

        #---generate desc before done---#
        if [ ! -s "${AUTO_ROOT_PATH}/tmp/${dot_name}_desc.txt" ]; then
            completion="$("$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep "$new_torrent_name"|head -n 1|awk '{print $2}'|sed 's/%//')"
            [ "$completion" ] && if [ $completion -ge 70 ]; then
                unset completion
                source "$AUTO_ROOT_PATH/get_desc/desc.sh"
                break           # must have not completed
            fi
        fi

        #---if completed---#
        get_torrent_func            # get TR_NAME
        if [ "$new_torrent_name" = "$TR_TORRENT_NAME" ]; then
            IFS=$IFS_OLD
            echo "+++++++++++++[start]+++++++++++++" >> "$log_Path"
            echo "[`date '+%Y-%m-%d %H:%M:%S'`] 准备发布 [$TR_TORRENT_NAME]" >> "$log_Path"
            source "$AUTO_ROOT_PATH/post/post.sh"

            write_log_main          # write log
            unset TR_TORRENT_NAME   # next torrent
            rm -f "$torrentPath"    # delete uploaded torrent
            clean_commit_main=1
        fi
    done
    IFS=$IFS_OLD
    #---clean & remove old torrent---#
    if [ "$clean_commit_main" = '1' ]; then
        source "$AUTO_ROOT_PATH/clean/clean.sh"
    fi
}

#--------------timeout func--------------#
TimeOut()
{
    waitfor=480
    main_loop_command=$*
    $main_loop_command &
    main_loop_pid=$!

    ( sleep $waitfor ; kill -9 $main_loop_pid  > /dev/null 2>&1 && echo -e "脚本因超时被强制中断\n" >> "$log_Path" ) &
    main_loop_sleep_pid=$!

    wait $main_loop_pid > /dev/null 2>&1
    sleep 2
    kill -9 $main_loop_sleep_pid > /dev/null 2>&1
}

#-------------start function------------#
[ "$disable_AutoSeed" = "yes" ] && exit

#---start check---#
if [ "$(find "$flexget_path" -iname '*.torrent*')" ]; then
    is_locked
    TimeOut main_loop
    #main_loop
    trap remove_lock EXIT
fi
