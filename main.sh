#!/bin/bash
# FileName: main.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-09-02
#
#-----------import settings-------------#
ROOT_PATH="$(dirname "$(readlink -f "$0")")"
# use source command run
[[ $ROOT_PATH == /*bin* ]] && \
ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_PATH/settings.sh"
source "$ROOT_PATH/static.sh"
#---------------------------------------#
# import extra functions
source "$ROOT_PATH/get_desc/detail_page.sh"
source "$ROOT_PATH/get_desc/customize.sh"
source "$ROOT_PATH/get_desc/extract.sh"
source "$ROOT_PATH/get_desc/match.sh"
#----------------lock func--------------#
remove_lock() {
    \rm -f "$lock_File" "$qb_rt_queue" "$ROOT_PATH/tmp/$$.debug"
}
is_locked() {
    if [ -f "$lock_File" ]; then
        exit 0
    else
        set -o noclobber             # 禁止重定向覆盖
        printf "$$" > "$lock_File"   # pid 写入文件
        set +o noclobber             # 允许重定向覆盖
        trap remove_lock INT TERM EXIT
    fi
}

#----------------log func---------------#
write_log_begin() {
    printf '%s\n' "-------------[start]-------------"   >> "$log_Path"
    printf '%s'   "[$(date '+%Y-%m-%d %H:%M:%S')]"      >> "$log_Path"
    printf '%s\n' "准备发布:[$org_tr_name]"             >> "$log_Path"
}
write_log_end() {
    printf '%s\n' "+++++++++++++++++++++++++++++++++"   >> "$log_Path"
    printf '%s'   "[$(date '+%Y-%m-%d %H:%M:%S')]"      >> "$log_Path"
    printf '%s\n' "已经处理:[$org_tr_name]"             >> "$log_Path"
}

#--------------is-completed-------------#
torrent_completed_precent() {
    unset completion # clean, use_qbt use_trs cannot be setted here!
    case "$fg_client" in
      qbittorrent)
        qb_get_torrent_completion ;;
      transmission)
        tr_get_torrent_completion ;;
      *)
        debug_func 'main:Client-Error'  #----debug---
    esac
}

#----------------desc-------------------#
generate_desc_func() {
  #---loop for torrent in flexget path---#
  for tr_i in "$flexget_path"/*.torrent; do [[ -f "$tr_i" ]] && {
    torrent_Path="${tr_i}"
    [[ $only_tlfbits == 'yes' ]] || {
      # test rar included torrent
      $tr_show "$torrent_Path"|grep -A 99 FILES|grep -Eq '.*\.rar |.*\.r[0-9]+ '
      [[ "$?" -eq 0 ]] && \rm -f "$torrent_Path" && break; } # delete rar torrent
    # org_tr_name 用于和 transmission/qb 中的种子名进行比较，
    org_tr_name="$(get_torrents_name "$torrent_Path")"
    one_TR_Name="$org_tr_name"
    #---generate desc before done---#
    if [[ ! -s "${ROOT_PATH}/tmp/${org_tr_name}_desc.txt" ]]; then
      unset completion
      [[ "$test_func_probe" || $HAND == yes ]]  && completion=100 || \
          torrent_completed_precent   # 获取下载完成百分比
      [[ "$completion" && $completion -ge 50 ]] && {
          debug_func "mainr:completed-[$completion]"  #----debug---
          debug_func 'main:gen_desc[生成简介]'        #----debug---
          source "$ROOT_PATH/get_desc/desc.sh" ; }
    fi
  }; done
  unset tr_i org_tr_name one_TR_Name one_TR_Dir # clean
}

#-------------main loop func-------------#
main_loop_func() {
  #---loop for torrent in flexget path ---#
  for tr_i in "$flexget_path"/*.torrent; do [[ -f "$tr_i" ]] && {
    #----------------------------------------------
    org_tr_name="$(get_torrents_name "$tr_i")"

    debug_func 'main:m-loop'           #----debug---
    #-----------------------------------------------
    if [[ "$org_tr_name" == "$one_TR_Name" ]]; then
      #---.torrient file path---#
      torrent_Path="$tr_i"
      #---desc---#
      if [[ ! -s "${ROOT_PATH}/tmp/${org_tr_name}_desc.txt" ]]; then
        debug_func 'main:failed to find desc'  #----debug---
        break
      else
        debug_func 'main:to-post'  #----debug---
        write_log_begin         # write log
        source "$ROOT_PATH/post/post.sh"
        write_log_end           # write log
        # delete uploaded torrent
        [[ ! "$test_func_probe" ]] && {
          \rm -f "$torrent_Path"
          clean_commit_main='yes'; }
      fi
    fi
  }; done
  #---clean & remove old torrent---#
  if [[ "$clean_commit_main" == 'yes' ]]; then
      debug_func 'main:clean'  #----debug---
      source "$ROOT_PATH/clean/clean.sh"
      printf '\n' >> "$log_Path" # new line
  fi
}

#--------------timeout func--------------#
time_out_func() {
  [[ -s "$lock_File" ]] && {
    local waitfor main_pid user_hz start_time sys_uptime run_time
    waitfor=1200    # 单位秒, 1200=20 min
    main_pid=$(< "$lock_File")
    user_hz=$(getconf CLK_TCK) #mostly it's 100 on x86/x86_64
    [[ $main_pid =~ [0-9]+ ]] && {
      start_time=$(awk '{print $22}' /proc/$main_pid/stat)
      sys_uptime=$(awk '{print $1}' /proc/uptime)
      run_time=$(( ${sys_uptime%.*} - $start_time/$user_hz )); }
  }
  if [[ $main_pid && $run_time -gt $waitfor ]]; then
      # 处理超时
      kill -9 $main_pid
      \rm -f "$lock_File" "$qb_rt_queue" "$ROOT_PATH/tmp/autoseed-"*
      debug_func "程序因超时[$run_time]被强制终止！"  #----debug---
  else
      # 重复运行
      debug_func '主程序正在运行，稍后重试！'  #----debug---
      exit 0
  fi
}
hold_on_func() {
  [[ $HAND != yes || ! $test_func_probe ]] && {
    # 依据cpu负载设置一个延时，解决系统IO问题
    # ${var:-default} Use new value if undefined or null.
    local cpu_number cpu_load _time
    cpu_number="$(grep 'model name' /proc/cpuinfo|wc -l)"
    cpu_load="$(uptime|awk -F 'average:' '{print $2}'|awk \
        -F ',' '{print $1}'|sed 's/ //g')"
    _time="$(bc <<< ${cpu_load:-0.4}*100/${cpu_number:-1}*0.4*${Speed:-1})"
    sleep "${_time:-0}" # 默认值 0 秒
    debug_func "main:hold-on[${_time:-0}]"  #----debug---
    unset Speed _time
  }
}
#---------------------------------------#
#-------------start function------------#
# 将种子追加到发布列队
if [[ "$#" -ge 2 ]]; then
  # manual, 2 parameters; one is file path
  if [[ -f "$1" ]]; then
    flexget_path="$ROOT_PATH/tmp"
    Torrent_Name="$(get_torrents_name "$1")"
    Tr_Path="$2"
    HAND='yes'
    \cp -f "$1" "${flexget_path%/}/handTorrent-$RANDOM.torrent"
  elif [[ -f "$2" ]]; then
    flexget_path="$ROOT_PATH/tmp"
    Torrent_Name="$(get_torrents_name "$2")"
    Tr_Path="$1"
    HAND='yes'
    \cp -f "$2" "${flexget_path%/}/handTorrent-$RANDOM.torrent"
  # qbittorrent, 2 parameters; one is directory
  elif [[ -d "$1" ]]; then
    Torrent_Name="$2"
    Tr_Path="$1"
    debug_func 'main:run_from_QB'
  elif [[ -d "$2" ]]; then
    Torrent_Name="$1"
    Tr_Path="$2"
    debug_func 'main:run_from_QB'
  fi
else
    # no parameter
    [[ $TR_TORRENT_NAME ]] && { 
      # transmission
      Torrent_Name="$TR_TORRENT_NAME"
      Tr_Path="$TR_TORRENT_DIR"
      debug_func 'main:run_from_TR'
    } || {
      # 提前发布
      [[ -f "$ROOT_PATH/enhance.sh" ]] && \
        source "$ROOT_PATH/enhance.sh"
    }
fi
[[ "$Torrent_Name" && "$Tr_Path" ]] && {
  [[ $HAND != yes ]] && {
    hold_on_func     # main.sh, sleep some time
    [[ $only_tlfbits == 'yes' ]] || {
      extract_rar_files     # get_desc/extract.sh
    }
  } || {
    tr_name_hand="$Torrent_Name"
    tr_path_hand="$Tr_Path"
  }
  while [[ ! -e $quene_lock ]]; do
    printf "$$" > "$quene_lock"   # quene lock
    printf '%s\n%s\n' "${Torrent_Name}" "${Tr_Path%/}" >> "$queue"
  done
  \rm -f "$quene_lock"
}
unset Torrent_Name Tr_Path
#---------------------------------------#
[[ "$Disable_AutoSeed" == yes ]] && exit 0
#---------------------------------------#
# move the end slash
flexget_path=${flexget_path%/}
[[ $HAND == yes ]] && {
  while [[ -f "$lock_File" ]]; do
    sleep 1
  done
} || {
  # 禁止重复运行; crontab 会开两个 main.sh 进程
  [[ "$(ps -C 'main.sh' --no-headers|wc -l)" -gt 2 ]] && time_out_func
}
is_locked            # 锁住进程，防止多开
# 生成简介于发布循环不能异步运行，\
# 否则有可能出现 .torrent 文件被改名\
# 而出现路径错误，因此只能顺序执行
generate_desc_func    # 提前生成简介
#-------------start check---------------#
main_counter=0
while [[ $main_counter -le 20 ]]; do
    one_TR_Name="$(head -1 "$queue")"
    one_TR_Dir="$(head -2 "$queue"|tail -1)"
    one_TR_Dir="${one_TR_Dir%/}"  # no slash end
    [[ "$one_TR_Name" && "$one_TR_Dir" ]] || break
    debug_func "main:queue-loop[$main_counter]"  #----debug---

    if [[ $(count "$flexget_path"/*.torrent) -ne 0 ]]; then
        hold_on_func                    # dynamic delay
        debug_func 'main:queue-in'      #----debug---
        main_loop_func
    fi
    sed -i '1,2d' "$queue"              # delete record
    ((main_counter++))                  # C 形式的增1
done

#---------------------------------------#
# qbittorrent set ratio
qb_set_ratio_loop
# reannounce
#debug_func "end-进程[$(ps -C 'main.sh' --no-headers|wc -l)]个" #----debug---
[[ "$(ps -C 'main.sh' --no-headers|wc -l)" -le 2 ]] && {
  [[ $use_trs == yes ]] && tr_reannounce
  [[ $use_qbt == yes ]] && qb_reannounce; }
#---------------------------------------#

