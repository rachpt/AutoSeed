#!/bin/bash
# FileName: main.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-05
#
#-----------import settings-------------#
ROOT_PATH="$(dirname "$(readlink -f "$0")")"
source "$ROOT_PATH/settings.sh"
#---------------------------------------#
# import functions
source "$ROOT_PATH/get_desc/detail_page.sh"
#----------------lock func--------------#
function remove_lock() {
    rm -f "$lock_file"
}
function is_locked() {
    if [ -f "$lock_file" ]; then
        exit
    else
        touch "$lock_file"
        trap remove_lock EXIT
    fi
}

#----------------log func---------------#
write_log_begin() {
    echo "+++++++++++++[start]+++++++++++++"   >> "$log_Path"
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]\c"  >> "$log_Path"
    echo "准备发布：[$org_tr_name]"            >> "$log_Path"
}
write_log_end() {
    echo "+++++++++++++++++++++++++++++++++"   >> "$log_Path"
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]\c"  >> "$log_Path"
    echo "以发布：[$org_tr_name]"              >> "$log_Path"
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
    IFS_OLD=$IFS; IFS=$'\n'
    #---loop for torrent in flexget path ---#
    for tr_i in $(find "$flexget_path" -iname '*.torrent*'|awk -F '/' '{print $NF}')
    do
        IFS=$IFS_OLD
        # new_torrent_name 用于和 transmission 中的种子名进行比较，
        # 以决定是否发布种子，作为方便，重命名 torrent 为该名，
        org_tr_name="$($tr_show "${flexget_path}/$tr_i"|grep 'Name'|head -1|sed -r 's/Name:[ ]+//')"

        if [ "$tr_i" != "${org_tr_name}.torrent" ]; then
            mv "${flexget_path}/${tr_i}" "${flexget_path}/${org_tr_name}.torrent"
        fi
        local one_TR_Name="$org_tr_name"
        local one_TR_Dir="$(grep -A2 "$org_tr_name" "$queue"|tail -1)"
        torrent_Path="${flexget_path}/${org_tr_name}.torrent"
        #---generate desc before done---#
        if [ ! -s "${ROOT_PATH}/tmp/${org_tr_name}_desc.txt" ]; then
            [ ! "$test_func_probe" ] && torrent_completed_precent
            [ "$test_func_probe" ] && completion=100      # convenient for test
            [ "$completion" ] && [ $completion -ge 70 ] && {
                unset completion
                source "$ROOT_PATH/get_desc/desc.sh"
                unset source_site_URL
            }
        fi
    done
    unset tr_i org_tr_name one_TR_Name one_TR_Dir
}

#-------------main loop func-------------#
function main_loop() {
    IFS_OLD=$IFS; IFS=$'\n'
    #---loop for torrent in flexget path ---#
    for tr_i in $(find "$flexget_path" -iname "*.torrent*"|awk -F '/' '{print $NF}')
    do
        IFS=$IFS_OLD
        #----------------------------------------------
        org_tr_name="$("$tr_show" "${flexget_path}/$tr_i"|grep 'Name'|head -1|sed -r 's/Name:[ ]+//')"
        
        #---.tr file path---#
        torrent_Path="${flexget_path}/${org_tr_name}.torrent"
        
        #-----------------------------------------------
        if [ "$org_tr_name" = "$one_TR_Name" ]; then
            #---desc---#
            if [ ! -s "${ROOT_PATH}/tmp/${org_tr_name}_desc.txt" ]; then
                echo 'Failed to find desc file!' >> "$debug_log"
                break
            else
                write_log_begin         # write log
                source "$ROOT_PATH/post/post.sh"
                write_log_end           # write log
                rm -f "$torrent_Path"   # delete uploaded torrent
                sed -i '1,2d' "$queue"
                clean_commit_main=1
            fi
        fi
    done
    #---clean & remove old torrent---#
    if [ "$clean_commit_main" = '1' ]; then
        source "$ROOT_PATH/clean/clean.sh"
    fi
    break
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

#---------------------------------------#
#-------------start function------------#
[ "$Disable_AutoSeed" = "yes" ] && exit
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
[ "$Torrent_Name" ] && echo "$Torrent_Name" >> "$queue"
[ "$Tr_Path" ] && echo "$Tr_Path" >> "$queue"
generate_desc
#---------------------------------------#
#---start check---#
while true; do
    is_locked
    one_TR_Name="$(head -1 "$queue")"
    one_TR_Dir="$(sed -n '2p;3q' "$queue")"
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
    else
        break
    fi
done
