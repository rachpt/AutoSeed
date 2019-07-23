#!/bin/bash
# FileName: clean/clean.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-04-28
#-----------------------------#
#
# Auto clean old files/folders in 
# watch-dir which are not seeding
# on transmission and qbittorrent.
#
#-----------test--------------#
# 测试说明：
# `bash -x clean.sh test 1 0` 测试 qbittorrent
# `bash -x clean.sh test 0 1` 测试 transmission
# 测试不会删除数据，但是会删除已经停止了的种子
# 测试会忽略清理频率限制(至少12小时一次)
#-----------------------------#
#---import settings---#
if [ -z "$ROOT_PATH" ]; then
    ROOT_PATH="$(dirname "$(readlink -f "$0")")"
    ROOT_PATH="${ROOT_PATH%/*}"
    source "$ROOT_PATH/settings.sh"
fi
unset test_c
[[ "$1" = test ]] && test_c=1 && {
  [[ "$2" = 1 ]] && use_qbt='yes' || use_qbt='no'
  [[ "$3" = 1 ]] && use_trs='yes' || use_trs='no'; }
#-----------------------------#
# import functions
source  "$ROOT_PATH/clean/tr.sh"
source  "$ROOT_PATH/clean/qb.sh"
#-----------------------------#
# judge function, return a value
is_old_file() {
  # need a parameter, return a 0/1 code
  local file_modf time_interval
  file_modf=$(stat -c '%Y' "$FILE_PATH/$1")
  time_interval=$(($(date '+%s') - ${file_modf:-0}))
  if [[ $time_interval -ge ${TimeINTERVAL:-7200} ]]; then
      printf 1  # yes
  else
      printf 0  # no
  fi
}
#-----------------------------#
# it's a called function
comparer_file_and_delete() {
  # _qb_names _tr_names 在main中使用local限定，可以减少重复工作
  IFS_OLD=$IFS; IFS=$'\n'; local f old_status
  for f in $(ls -1 "$FILE_PATH"); do
    IFS=$IFS_OLD
    old_status=$(is_old_file "$f") 
    if [[ $old_status -eq 1 && "$f" ]]; then
       # 删除不在qb tr中的文件
       local delete_commit
       # transmission 判断更容易，所以放前面。
       [[ $use_trs = yes ]] && tr_is_seeding "$f" || delete_commit='yes'
       [[ $use_qbt = yes && $delete_commit = yes ]] && qb_is_seeding "$f"
       # 如果两个客户端都未使用，则不删文件。
       [[ $use_qbt != yes && $use_trs != yes ]] && delete_commit='no'
       if [[ $delete_commit = yes ]]; then
         debug_func "clean:del-file:[$f]"  #----debug---
         [[ "$f" && -e "$FILE_PATH/$f" && ! $test_c ]] && \rm -rf "$FILE_PATH/$f"
         printf '%s\n' "[$(date '+%m-%d %H:%M:%S')]deleted Torrent[$f]" >> "$log_Path"
       fi
    fi
  done
  unset f old_status
}
#-----------------------------#
# judge function, return a value
disk_check() {
  disk_avail=$(\df -h "$FILE_PATH"|awk '/^\//{split($4,a,"G");print a[1]}')
  disk_over=$(bc <<< "${disk_avail:-0} < ${DISK_AVAIL_MIN:-0}")  # var default 0
  # bc true = 1, false = 0
}
#-----------------------------#
# it's a called function
disk_is_over_use() {
  local disk_over disk_avail i
  disk_check
  if [[ "$disk_over" -eq 1 && $use_trs = yes ]]; then
    for i in $($tr_remote -l|grep -Eo '[0-9]+.+100%'|grep -Eo '^[0-9]+'); do
      $tr_remote -t "$i" --remove-and-delete >> "$log_Path" 2>&1
      debug_func "clean::reach-limit[$i]"  #----debug---
      sleep 10 && disk_check
      [[ "$disk_over" -eq 0 ]] && break
    done
  fi
  if [[ "$disk_over" -eq 1 && $use_qbt = yes ]]; then
    : # 我好像用不到，此处不写
  fi
}

#-----------------------------#
# 清理路径列队，用于更新 dir 里面的值
clean_dir() {
  if [ ! -s "$ROOT_PATH/clean/dir" ]; then
    # add to the first line
    [[ "$one_TR_Dir" ]] && printf '%s\n' "$one_TR_Dir" > "$ROOT_PATH/clean/dir"
  else
    local line add_to_dir
    add_to_dir=1
    while read -r line; do
       [[ "$one_TR_Dir" == "$line" ]] && {
        add_to_dir=0 # give up add
        break; }
    done < "$ROOT_PATH/clean/dir"
    [[ $add_to_dir -eq 1 && $one_TR_Dir ]] && \
      printf '%s\n' "$one_TR_Dir" >> "$ROOT_PATH/clean/dir"
  fi
  unset line add_to_dir
}

#----------call-func----------#
clean_frequence() {
  # 限制清理频率
  local time_threshold time_pass
  [[ $test_c ]] && time_threshold=1 || time_threshold=$((60 * 60 * 12))  # 12 hours to seconds
  # use $(( )) to calculate number
  time_pass=$(($(date '+%s') - $(stat -c '%Y' "$ROOT_PATH/clean/dir")))
  [[ $time_pass -gt $time_threshold ]] && {
    debug_func "clean:use_qbt[$use_qbt]-use_trs[$use_trs]"
    [[ $test_c ]] || sleep 20 # 延时
    clean_main
    # 更新dir时间
    touch -m "$ROOT_PATH/clean/dir"; }
}

#----------main-loop----------#
clean_main() {
  local one_line _qb_names _tr_names # *_names为客户端做种列表
  [[ $use_qbt = yes ]] && qb_delete_old  # will not delete file
  [[ $use_trs = yes ]] && tr_delete_old  # will not delete file
  [ -s "$ROOT_PATH/clean/dir" ] && \
  while read -r one_line; do
    FILE_PATH="$one_line"      # no slash end !!!
    comparer_file_and_delete   # make sure new file will not be deleted
    disk_is_over_use           # make sure free space
  done < "$ROOT_PATH/clean/dir"
  unset one_line _qb_names _tr_names
  printf '%s\n' "+++++++++++++[clean]+++++++++++++" >> "$log_Path"
}

#---------call func-----------#
clean_dir                # update clean queue
# maybe need more test !!!
clean_frequence          # check and clean

