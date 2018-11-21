#!/bin/bash
# FileName: main.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-11-21
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
    else
        touch "$lock_file"
        trap remove_lock EXIT
    fi
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
    echo "发布了：[$dot_name]"                 >> "$log_Path"
}

#---------------------------------------#
torrent_completed_precent() {
    unset completion
    if [ "$TR_Client" = 'qbittorrent' ]; then
        completion="$(qb_get_torrent_completion "$org_tr_name")"
    elif [ "$TR_Client" = 'transmission' ]; then
        completion="$( $tr_remote -l|grep "$org_tr_name"|head -1|awk '{print $2}'|sed 's/%//')"
    else
        echo 'Client Selete Error!' >> "$debug_log"
    fi
}

#---------------------------------------#
generate_desc() {
    IFS_OLD=$IFS
    IFS=$'\n'
    #---loop for torrent in flexget path ---#
    for tr_i in $(find "$flexget_path" -iname "*.torrent*"|awk -F '/' '{print $NF}')
    do
        # new_torrent_name 用于和 transmission 中的种子名进行比较，
        # 以决定是否发布种子，作为方便，重命名 torrent 为该名，
        org_tr_name="$( $tr_show "${flexget_path}/$tr_i"|grep 'Name'|head -1|sed -r 's/Name:[ ]+//')"

        if [ "$tr_i" != "${org_tr_name}.torrent" ]; then
            mv "${flexget_path}/${tr_i}" "${flexget_path}/${org_tr_name}.torrent"
        fi

        #---generate desc before done---#
        if [ ! -s "${AUTO_ROOT_PATH}/tmp/${org_tr_name}_desc.txt" ]; then
            torrent_completed_precent
            [ "$test_func_probe" ] && completion=100      # convenient for test
            [ "$completion" ] && [ $completion -ge 70 ] && {
                unset completion
                source "$AUTO_ROOT_PATH/get_desc/desc.sh"
            }
        fi
    done
    IFS=$IFS_OLD
}

#-------------main loop func-------------#
function main_loop() {
    IFS_OLD=$IFS
    IFS=$'\n'
    #---loop for torrent in flexget path ---#
    for tr_i in $(find "$flexget_path" -iname "*.torrent*"|awk -F '/' '{print $NF}')
    do
        # 最后发布前会再次重命名为简单的名字减少莫名其妙的bug。
        # dot_name即点分隔名，用作 0day 名，以及构成保存简介文件名。
        #----------------------------------------------
        org_tr_name="$("$trans_show" "${flexget_path}/$tr_i"|grep 'Name'|head -1|sed -r 's/Name:[ ]+//')"
        #---use dot separated name for saving desc---#
        if [ "$(echo "$org_tr_name"|sed 's/[a-z0-9[:punct:]]//ig')" ]; then
            #---special for non-standard 0day-name---#
            dot_name="$("$tr_show" "${flexget_path}/$tr_i"|grep -A 10 'FILES'|grep -Ei '[\.0-9]+[ ]*(GB|MB)'|grep -Eio "[-\.\'a-z0-9\!@_ ]+"|tail -2|head -1|sed -r 's/^[\. ]+//;s/\.[a-z4 ]{2,5}$//i'|sed -r 's/\.sample//i;s/[ ]+/./g')"
        else
            dot_name="$(echo "$org_tr_name"|sed -r "s/[ ]+/./g;s/\.[a-z4]{2,3}$//i;")"
        fi

        #---.tr file path---#
        torrent_Path="${flexget_path}/${org_tr_name}.torrent"
        
        #-----------------------------------------------
        if [ "$org_tr_name" = "$one_TR_Name" ]; then
            #---desc---#
            if [ ! -s "${AUTO_ROOT_PATH}/tmp/${org_tr_name}_desc.txt" ]; then
                echo 'Failed to find desc file!' >> "$debug_log"
                break
            fi
            IFS=$IFS_OLD
            echo "+++++++++++++[start]+++++++++++++" >> "$log_Path"
            echo "[`date '+%Y-%m-%d %H:%M:%S'`] 准备发布 [$dot_name]" >> "$log_Path"
            source "$AUTO_ROOT_PATH/post/post.sh"

            write_log_main          # write log
            rm -f "$torrent_Path"   # delete uploaded torrent
            sed -i '1,2d' "$AUTO_ROOT_PATH/tmp/queue"
            clean_commit_main=1
            break
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
    waitfor=460
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
[ "$Disable_AutoSeed" = "yes" ] && exit

#---start check---#
# 将种子追加到列队
if [ "$#" -eq 2 ]; then
    # qbittorrent
    Torrent_Name="$1"
    Tr_Path="$2"
else
    # transmission
    Torrent_Name="$TR_TORRENT_NAME"
    Tr_Path="$TR_TORRENT_DIR"
fi
[ "$Torrent_Name" ] && echo "$Torrent_Name" >> "$AUTO_ROOT_PATH/tmp/queue"
[ "$Tr_Path" ] && echo "$Tr_Path" >> "$AUTO_ROOT_PATH/tmp/queue"
generate_desc
#---------------------------------------#
while true; do
    is_locked
    one_TR_Name="$(head -1 "$AUTO_ROOT_PATH/tmp/queue")"
    one_TR_Dir="$(sed -ne '2p;3q' "$AUTO_ROOT_PATH/tmp/queue")"
    [[ ! "$one_TR_Name" || ! "$one_TR_Dir" ]] && break

    if [ "$(find "$flexget_path" -iname '*.torrent*')" ]; then
        number_of_cpus="$(grep 'model name' /proc/cpuinfo|wc -l)"
        get_cpu_current_usage() {
            cpu_current_usage="$(echo $(uptime |awk -F 'average:' '{print $2}'|awk -F ',' '{print $1}'|sed 's/[ ]\+//g')*100/$number_of_cpus|bc|awk -F '.' '{print $1}')"
        }

        get_cpu_current_usage && [ "$cpu_current_usage" -ge 90 ] && sleep 20 
        get_cpu_current_usage && [ "$cpu_current_usage" -ge 70 ] && sleep 13 
        get_cpu_current_usage && [ "$cpu_current_usage" -ge 50 ] && sleep  9 
        get_cpu_current_usage && [ "$cpu_current_usage" -ge 30 ] && sleep  5 

        if [ "$test_func_probe" ]; then
            main_loop
        else
            TimeOut main_loop
        fi
    fi
done
