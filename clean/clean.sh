#!/bin/bash
# FileName: clean/clean.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-13
#-----------------------------#
#
# Auto clean old files/folders in 
# watch-dir which are not seeding
# on transmission#.
#
#---import settings---#
if [ -z "$ROOT_PATH"]; then
    ROOT_PATH="$(dirname "$(readlink -f "$0")")"
    ROOT_PATH="${ROOT_PATH%/*}"
    source "$ROOT_PATH/settings.sh"
fi
#-----------------------------#
# import functions
source  "$ROOT_PATH/clean/tr.sh"
source  "$ROOT_PATH/clean/qb.sh"
#-----------------------------#
is_old_file() {
  local file_modf=$(stat -c '%Y' "$FILE_PATH/$1")
  local time_interval=$(expr $(date '+%s') - $file_modf)
  if [ $time_interval -ge $TimeINTERVAL ]; then
      echo 1  # yes
  else
      echo 0  # no
  fi
}
#-----------------------------#
comparer_file_and_delete() {
  IFS_OLD=$IFS
  IFS=$'\n'
  for i in $(ls -1 "$FILE_PATH")
  do
    IFS=$IFS_OLD
    local old_status=$(is_old_file "$i") 
    if [ $old_status -eq 1 ]; then
       # 删除不在qb tr中的文件
       [ "$qb" = 'yes' ] && qb_is_seeding "$i"
       [ "$tr" = 'yes' ] && tr_is_seeding "$i"
    fi
  done
}
#-----------------------------#
disk_check() {
    DISK_AVAIL=$(df -h $FILE_PATH|grep -v Mounted|awk '{print $4}'|cut -d 'G' -f 1)
    DISK_OVER=$(awk 'BEGIN{print('$DISK_AVAIL'<'$DISK_AVAIL_MIN')}')
}
#-----------------------------#
disk_is_over_use() {
  disk_check
  if [ "$DISK_OVER" = "1" ]; then
    for i in $($tr_remote -l|grep '100%.*Done'|awk '{print $1}'|sed 's/*//')
    do
      [ "$i" -gt "0" ] && echo -n "$(date '+%m-%d %H:%M:%S') [Done] " >> "$log_Path"
      $tr_remote -t $i --remove-and-delete >> "$log_Path" 2>&1
      [ "$i" -gt "0" ] && sleep 10 && disk_check
      [ "$DISK_OVER" = "0" ] && break
    done
  fi
}

#-----------------------------#
# 清理路径列队
clean_dir() {
  if [ ! -s "$ROOT_PATH/clean/dir" ]; then
    [ "$one_TR_Dir" ] && echo "$one_TR_Dir" >> "$ROOT_PATH/clean/dir"
    : # do nothing
  else
    cat "$ROOT_PATH/clean/dir"|while read line
  do
    [ "$one_TR_Dir" != "$line" ] && {
        echo "$one_TR_Dir" >> "$ROOT_PATH/clean/dir"
        break; }
    : # do nothing
  done
  fi
  unset line
}

clean_frequence() {
  local time_threshold=$(expr 60*60*12)  # 12 hours
  local time_pass=$(expr $(date '+%s') - $(stat -c '%Y' "$ROOT_PATH/clean/dir"))
  [ $time_pass -gt $time_threshold ] && calen_main
  # 更新dir时间
  touch -m "$ROOT_PATH/clean/dir"
}

#-----------------------------#
clean_main() {
  qb='yes'
  tr='yes'
  [ "$qb" = 'yes' ] && qb_delete_old
  [ "$tr" = 'yes' ] && tr_delete_old
  cat "$ROOT_PATH/clean/dir"|while read one_line
  do
    FILE_PATH="$one_line"
    comparer_file_and_delete
    disk_is_over_use
    echo "+++++++++++++[clean]+++++++++++++" >> "$log_Path"
  done
}

#---------call func-----------#
clean_dir
clean_frequence
