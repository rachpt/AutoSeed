#!/bin/bash
# FileName: clean/tr.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-04-27
#
#-----------------------------#
tr_delete_old() {
  # 使用多线程技术加速
  local thread="$ROOT_PATH/tmp/thread"
  local THREAD_num=8                #定义进程数量
  if [[ -a "$thread" ]];then        #防止计数文件存在引起冲突
      \rm -f "$thread"               #若存在先删除
  fi
  mkfifo "$thread"                  #创建fifo型文件用于计数
  exec 9<> "$thread"
  
  for (( i=0;i<$THREAD_num;i++ ))   #向fd9文件中写回车，有多少个进程就写多少个
  do
      echo -ne "\n" 1>&9
  done
#-----------------------------#
  unset ID
  for ID in $($tr_remote -l|grep -Eo '^[ ]*[0-9]+'|sed 's/ //g')
  do
    read -u 9             #read一次，就减去fd9中一个回车
    {                     #当fd9中没有回车符时，脚本就会停住，达到控制进程数量的目的
    #---error torrent---#
    local tr_info="$($tr_remote -t $ID -i)"
    if [ "$(echo "$tr_info"|grep 'torrent not registered with this tracker')" ]; then
        $tr_remote -t $ID -r
    fi
    #---old torrent---#
    local seed_time=$(echo "$tr_info"|grep 'Seeding Time.*days'|grep -Eo '[0-9]+'|head -1)
    
    [ "$seed_time" ] && if [ $seed_time -ge $MAX_SEED_TIME ]; then
        $tr_remote -t $ID -r
    fi
    #---finished torrent---#
    if [ "$(echo "$tr_info"|grep 'State:.*Finished')" ]; then
        $tr_remote -t $ID -r
    fi
    unset tr_info
    echo -ne "\n" 1>&9   #某个子进程执行结束，向fd9追加一个回车符，补充循环开始减去的那个
    }&
  done
  wait                   #等待所有后台子进程结束
  \rm -f "$thread"
}

#-----------------------------#
tr_is_seeding() {
  # _tr_names in clean/clean.sh
  # transmission 第10 列开始为种子名, NR>1去掉第一行，最后一行被for去掉
  [[ ! "$_tr_names" ]] && _tr_names="$($tr_remote -l|awk \
    'NR>1{for(i=10;i<=NF;i++)print $i}')"
  [[ "$1" && "$_tr_names" ]] && {
    [[ "$_tr_names" =~ .*${1}.* ]] && delete_commit='no' || delete_commit='yes'
  } || {  [[ "$_tr_names" ]] || \
    debug_func "clean.trs.failed.to.get.seeding.lists"
    delete_commit='no' # cancel delete file !!!
  }
}
#-----------------------------#

