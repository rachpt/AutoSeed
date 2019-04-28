#!/bin/bash
# FileName: clean/qb.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-04-27
#
#---------------------------------------#
qb_delete_old() {
  qbit_webui_cookie
  # from tr name find other info
  debug_func 'qb:delete-start'  #----debug---
  local _qb_data _paused_data one_1 max_time _sd_timeData
  # --pretty=format is important!!
  _qb_data="$(http --ignore-stdin --pretty=format GET "$qb_lists" sort=added_on \
    "$qb_Cookie"|grep -E '"name":|"hash":|"ratio":|"state":|"time_active":')"

  #---------------------------------------#
  # 删除停止了的种子，不删数据
  _paused_data="$(echo "$_qb_data"|grep -B3 '"state":.*pausedUP'|grep -Eio '[a-z0-9]{40}')"
  for one_1 in $_paused_data; do qb_delete_torrent "$one_1"; done
  #---------------------------------------#
  # 达到做种时间的种子
  max_time="$(($MAX_SEED_TIME * 24 * 60 * 60))" # 此处时间为秒，不是分钟
  _sd_timeData="$(echo "$_qb_data"|grep -B4 '"time_active":.*[0-9]*'|sed \
    '/"name":/d;/"ratio":/d;/"state":/d;s/[",:]//g'|sed 'N;s/\n//')"
  for one_2 in $(echo "$_sd_timeData"|awk -v t=$max_time '{if($4 >= t)print $2}')
  do
    qb_delete_torrent "$one_2"
  done
}

#---------------------------------------#
qb_is_seeding() {
  # _qb_names in clean/clean.sh
  [[ ! "$_qb_names" ]] && qbit_webui_cookie && \
    _qb_names="$(http --ignore-stdin --pretty=format -f POST "$qb_lists" sort=added_on \
    "$qb_Cookie"|grep '"name":'|uniq|sed -E 's/.*"name":[ ]+"//;s/",$//')"
  [[ "$1" && "$_qb_names" ]] && {
    [[ "$_qb_names" =~ .*${1}.* ]] && delete_commit='no' || delete_commit='yes'
  } || {  [[ "$_qb_names" ]] || \
    debug_func "clean.qbt.failed.to.get.seeding.lists"
    delete_commit='no' # concel delete file !!!
  }
}
#-----------------------------#

