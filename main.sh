#!/bin/bash
# FileName: main.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-14
#
#-----------import settings-------------#
ROOT_PATH="$(dirname "$(readlink -f "$0")")"
source "$ROOT_PATH/settings.sh"
#---------------------------------------#
# import functions
source "$ROOT_PATH/get_desc/detail_page.sh"
#----------------lock func--------------#
remove_lock() {
    rm -f "$lock_File"
    debug_func 'main_unlock'  #----debug---
}
is_locked() {
    if [ -f "$lock_File" ]; then
        exit
    else
        set -o noclobber        # 禁止重定向覆盖
        echo "$$" > "$lock_File"
        set +o noclobber        # 允许重定向覆盖
        debug_func 'main_lock'  #----debug---
        trap remove_lock INT TERM EXIT
    fi
}

#----------------log func---------------#
write_log_begin() {
    echo "-------------[start]-------------"   >> "$log_Path"
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')]\c" >> "$log_Path"
    echo "准备发布：[$org_tr_name]"            >> "$log_Path"
}
write_log_end() {
    echo "+++++++++++++++++++++++++++++++++"   >> "$log_Path"
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')]\c" >> "$log_Path"
    echo "已经发布：[$org_tr_name]"            >> "$log_Path"
}

#---------------------------------------#
torrent_completed_precent() {
    unset completion
    if [ "$fg_client" = 'qbittorrent' ]; then
        qb_get_torrent_completion
    elif [ "$fg_client" = 'transmission' ]; then
        tr_get_torrent_completion
    else
        debug_func 'main_Client_Error'  #----debug---
    fi
}

#---------------------------------------#
generate_desc() {
  IFS_OLD=$IFS; IFS=$'\n'
  #---loop for torrent in flexget path ---#
  for tr_i in $(find "$flexget_path" -iname '*.torrent*'|awk -F '/' '{print $NF}')
  do
    IFS=$IFS_OLD
    torrent_Path="${flexget_path}/$tr_i"
    # org_tr_name 用于和 transmission/qb 中的种子名进行比较，
    org_tr_name="$($tr_show "$torrent_Path"|grep Name|head -1|sed -r 's/Name:[ ]+//')"
    debug_func 'main_1:gl'  #----debug---
    one_TR_Name="$org_tr_name"
    #---generate desc before done---#
    if [ ! -s "${ROOT_PATH}/tmp/${org_tr_name}_desc.txt" ]; then
        [ ! "$test_func_probe" ] && torrent_completed_precent
        [ "$test_func_probe" ] && completion=100      # convenient for test
        debug_func 'main_comp-'"$completion"          #----debug---
        [ "$completion" ] && [ "$completion" -ge '70' ] && {
            debug_func 'main_2:gdesc'  #----debug---
            unset completion source_site_URL
            source "$ROOT_PATH/get_desc/desc.sh"
            unset source_site_URL; }
    fi
  done
  unset tr_i org_tr_name one_TR_Name one_TR_Dir
}

#-------------main loop func-------------#
main_loop() {
  IFS_OLD=$IFS; IFS=$'\n'
  #---loop for torrent in flexget path ---#
  for tr_i in $(find "$flexget_path" -iname "*.torrent*"|awk -F '/' '{print $NF}')
  do
      IFS=$IFS_OLD
      #----------------------------------------------
      org_tr_name="$("$tr_show" "${flexget_path}/$tr_i"|grep 'Name'| \
          head -1|sed -r 's/Name:[ ]+//')"

      debug_func 'main_3:ml'  #----debug---
      #-----------------------------------------------
      if [ "$org_tr_name" = "$one_TR_Name" ]; then
          #---.torrient file path---#
          torrent_Path="${flexget_path}/$tr_i"
          #---desc---#
          if [ ! -s "${ROOT_PATH}/tmp/${org_tr_name}_desc.txt" ]; then
              debug_func 'main_:Failed to find desc'  #----debug---
              break
          else
              debug_func 'main_4:post'  #----debug---
              write_log_begin         # write log
              source "$ROOT_PATH/post/post.sh"
              write_log_end           # write log
              # delete uploaded torrent
              [ ! "$test_func_probe" ] && \
              rm -f "$torrent_Path"    && \
              clean_commit_main='have_not_test'    
          fi
      fi
  done
  #---clean & remove old torrent---#
  if [ "$clean_commit_main" = 'yes' ]; then
      source "$ROOT_PATH/clean/clean.sh"
  fi
}

#--------------timeout func--------------#
time_out() {
    local waitfor=1200    # 单位秒, 1200=20 min
    local main_pid=$(cat "$lock_File")
    local user_hz=$(getconf CLK_TCK) #mostly it's 100 on x86/x86_64
    local start_time=$(cat /proc/$main_pid/stat|cut -d" " -f22)
    local sys_uptime=$(cat /proc/uptime|cut -d" " -f1)
    local run_time=$(( ${sys_uptime%.*} - $start_time/$user_hz ))
    if [[ $main_pid && $run_time -gt $waitfor ]]; then
        # 处理超时
        kill -9 $main_pid
        rm -f "$lock_File" "$ROOT_PATH/tmp/autoseed-pic.*"
    else
        # 重复运行
        debug_func '主程序正在运行，稍后重试！'
        exit
    fi
}
hold_on() {
  # 依据cpu负载设置一个延时，解决系统IO问题
  local cpu_number="$(grep 'model name' /proc/cpuinfo|wc -l)"
  local cpu_load="$(echo $(uptime |awk -F 'average:' '{print $2}'| \
      awk -F ',' '{print $1}'|sed 's/[ ]\+//g')*100/$cpu_number| \
      bc|awk -F '.' '{print $1}')"
  sleep $(echo $(uptime |awk -F 'average:' '{print $2}'| \
      awk -F ',' '{print $1}'|sed 's/[ ]\+//g')*100/$cpu_number*0.4*$Speed|bc)
  unset Speed
}

#-------------start function------------#
# 将种子追加到发布列队
if [ "$#" -eq 2 ]; then
    # qbittorrent, 2 parameter
    Torrent_Name="$1"
    Tr_Path="$2"
    debug_func 'main_0:qb_in'  #----debug---
else
    # transmission, no parameter
    Torrent_Name="$TR_TORRENT_NAME"
    Tr_Path="$TR_TORRENT_DIR"
    [[ $TR_TORRENT_NAME ]] && sleep 2 && \
    debug_func 'main_0:tr_in'  #----debug---
fi
[[ $Torrent_Name && $Tr_Path ]] && \
    echo -e "${Torrent_Name}\n${Tr_Path}" >> "$queue"
unset Torrent_Name Tr_Path
#---------------------------------------#
[ "$Disable_AutoSeed" = "yes" ] && exit
#---------------------------------------#
# 禁止重复运行
debug_func '进程['"$(ps -C 'main.sh' --no-headers|wc -l)"']个' #----debug---
[[ "$(ps -C 'main.sh' --no-headers|wc -l)" -gt 2 ]] && time_out
#
is_locked            # 锁住进程，防止多开
# 生成简介于发布循环不能异步运行，\
# 否则有可能出现 .torrent 文件被改名\
# 而出现路径错误，因此只能顺序执行
generate_desc        # 提前生成简介
#---------------------------------------#
#---start check---#
main_lp_counter=0
while true; do
    one_TR_Name="$(head -1 "$queue")"
    one_TR_Dir="$(head -2 "$queue"|tail -1|sed 's!/$!!')"
    [[ ! "$one_TR_Name" || ! "$one_TR_Dir" ]] && break
    [[ $main_lp_counter -gt 50 ]] && break
    debug_func 'main_5:qu'  #----debug---

    if [ "$(find "$flexget_path" -iname '*.torrent*')" ]; then
        hold_on        # dynamic delay
        debug_func 'main_6:q.p'  #----debug---
        main_loop
    fi
    [ ! "$test_func_probe" ] && \
    sed -i '1,2d' "$queue" # delete record
    ((main_lp_counter++))  # C 形式的增1
done
#---------------------------------------#
debug_func 'main_exit'  #----debug---
