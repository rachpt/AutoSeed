#!/bin/bash
# FileName: clean/qb.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-13
#
#---------------------------------------#
qb_delete_old() {
  qbit_webui_cookie
  # from tr name find other info
  debug_func 'qb_3:r-start'  #----debug---
  local data="$(http --ignore-stdin --pretty=format GET "$qb_lists" sort=added_on \
    "$qb_Cookie"|sed -E 's/^ +//g;/[{}]/d;/"hash":/{s/"//g};/"name":/{s/"//g};/"ratio":/{s/"//g};/"state":/{s/"//g};/"time_active":/{s/"//g};'|sed '/"/d')" 

#---------------------------------------#
# 停止的种子
  local data="$(http --ignore-stdin --pretty=format GET "$qb_lists" "$qb_Cookie"| \
      sed -E 's/^ +//g;/[{}]/d;/"hash":/{s/"//g};/"state":/{s/"//g};/"/d')" 
  echo "$data"|grep -B1 "state.*pausedUP"|grep hash|sed 's/hash:[ ]*//;s/,//'|while read one
  do
      local torrent_hash="$one"
      qb_delete_torrent
  done
#---------------------------------------#
# 达到做种时间的种子
  local max_time="$(expr $MAX_SEED_TIME * 60 * 60)"
  local data="$(http --ignore-stdin --pretty=format GET "$qb_lists" sort=time_active \
    "$qb_Cookie"|sed -E 's/^ +//g;/[{}]/d;/"hash":/{s/"//g};/"time_active":/{s/"//g};/"/d;s/,//;s/\[//;s/]//;/^$/d'| \
    sed -n '{N;s/\n/\t/p}')"
  echo "$data"|awk -v time=$max_time '{if($4 >= time)print $2}'|while read one
  do
      local torrent_hash="$one"
      qb_delete_torrent
  done
}
  
#---------------------------------------#
qb_is_seeding() {
  local delete_commit='yes'
  local data="$(http --ignore-stdin --pretty=format GET "$qb_lists" sort=added_on \
    "$qb_Cookie"|sed -E 's/^ +//g;/[{}]/d;/"name":/{s/"//g};/"/d;s/,//;s/\[//;s/]//;/^$/d')" 
  if [ -n "$1" ]; then
    echo "$data"|grep "name"|sed 's/name:[ ]*//;s/,//'|while read one
    do
      if [ "$1" = "$one" ]; then
	      delete_commit='no'
        break
      fi
    done
    unset one
    if [ "$delete_commit" = 'yes' ]; then
        rm -rf "$FILE_PATH/$1"
        echo "[$(date '+%m-%d %H:%M:%S')]deleted Torrent [$1]" >> "$log_Path"
    fi
  fi
}
#-----------------------------#

