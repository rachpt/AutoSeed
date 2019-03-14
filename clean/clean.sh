#!/bin/bash
# FileName: clean/clean.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-03-14
#-----------------------------#
#
# Auto clean old files/folders in 
# watch-dir which are not seeding
# on transmission and qbittorrent.
#
#---import settings---#
if [ -z "$ROOT_PATH" ]; then
    ROOT_PATH="$(dirname "$(readlink -f "$0")")"
    ROOT_PATH="${ROOT_PATH%/*}"
    source "$ROOT_PATH/settings.sh"
fi
#-----------------------------#
# import functions
source  "$ROOT_PATH/clean/tr.sh"
source  "$ROOT_PATH/clean/qb.sh"
#-----------------------------#
# judge function, return a value
is_old_file() {
  # need a parameter, return a 0/1 code
  local file_modf=$(stat -c '%Y' "$FILE_PATH/$1")
  local time_interval=$(expr $(date '+%s') - $file_modf)
  if [ $time_interval -ge $TimeINTERVAL ]; then
      echo 1  # yes
  else
      echo 0  # no
  fi
}
#-----------------------------#
# it's a call function
comparer_file_and_delete() {
  IFS_OLD=$IFS; IFS=$'\n'; local f _qb_names _tr_names old_status
  for f in $(ls -1 "$FILE_PATH"); do
    IFS=$IFS_OLD
    old_status=$(is_old_file "$i") 
    if [[ $old_status -eq 1 ]]; then
       # 删除不在qb tr中的文件
       local delete_commit
       [[ $use_trs = yes ]] && qb_is_seeding "$f"
       [[ $use_qbt = yes && $delete_commit = yes ]] && tr_is_seeding "$f"
       [[ $use_qbt != yes && $use_trs != yes ]] && delete_commit='no'
       if [[ "$f" && $delete_commit = yes ]]; then
         debug_func "clean:del-file:[$f]"  #----debug---
         \rm -rf "$FILE_PATH/$f"
         echo "[$(date '+%m-%d %H:%M:%S')]deleted Torrent[$f]" >> "$log_Path"
       fi
    fi
  done
  unset f _qb_names _tr_names old_status
}
#-----------------------------#
# judge function, return a value
disk_check() {
  disk_avail=$(\df -h "$FILE_PATH"|grep "^/dev/.*"|awk '{print $4}'|cut -d 'G' -f 1)
  disk_over=$(echo "${disk_avail:-0} < ${DISK_AVAIL_MIN:-0}"|bc)  # var default 0
  # bc true = 1, false = 0
}
#-----------------------------#
# it's a call function
disk_is_over_use() {
  local disk_over disk_avail i
  disk_check
  if [[ "$disk_over" -eq 1 && $use_trs = yes ]]; then
    for i in $($tr_remote -l|grep -Eo '[0-9]+.+100%'|grep -Eo '^[0-9]+'); do
      $tr_remote -t $i --remove-and-delete >> "$log_Path" 2>&1
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
# 清理路径列队
clean_dir() {
  if [ ! -s "$ROOT_PATH/clean/dir" ]; then
    # add to the first line
    [[ "$one_TR_Dir" ]] && echo "$one_TR_Dir" > "$ROOT_PATH/clean/dir"
  else
    OLD_IFS="$IFS"; IFS=$'\n'
    local line add_to_dir
    add_to_dir=1
    for line in $(cat "$ROOT_PATH/clean/dir"); do
       [[ "$one_TR_Dir" == "$line" ]] && {
        add_to_dir=0 # give up add
        break; }
    done
    IFS="$OLD_IFS"
    [[ $add_to_dir -eq 1 && $one_TR_Dir ]] && \
      echo "$one_TR_Dir" >> "$ROOT_PATH/clean/dir"
  fi
  unset line add_to_dir
}

clean_frequence() {
  # 限制清理频率
  local time_threshold time_pass
  time_threshold=$(( 60 * 60 * 12))  # 12 hours
  # use $(( )) to calculate number
  time_pass=$(($(date '+%s') - $(stat -c '%Y' "$ROOT_PATH/clean/dir")))
  [[ $time_pass -gt $time_threshold ]] && {
    sleep 20 # 延时
    clean_main
    # 更新dir时间
    touch -m "$ROOT_PATH/clean/dir"; }
}

#-----------------------------#
clean_main() {
  local one_line
  [[ $use_qbt = yes ]] && qb_delete_old  # will not delete file
  [[ $use_trs = yes ]] && tr_delete_old  # will not delete file
  [ -s "$ROOT_PATH/clean/dir" ] && \
  cat "$ROOT_PATH/clean/dir"|while read one_line; do
    FILE_PATH="$one_line"      # no slash end !!!
    comparer_file_and_delete   # make sure new file will not be deleted
    disk_is_over_use           # make sure free space
  done
  unset one_line
  echo "+++++++++++++[clean]+++++++++++++" >> "$log_Path"
}

#---------call func-----------#
clean_dir                # update clean queue
# maybe need more test !!!
clean_frequence          # check and clean

