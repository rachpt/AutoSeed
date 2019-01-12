#!/bin/bash
# FileName: transmission.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-19
#
#---------------------------------------#
#
#---path of transmission-remote---#
tr_remote="transmission-remote ${tr_HOST}:${tr_PORT} \
    --auth ${tr_USER}:${tr_PASSWORD}"

#---------------------------------------#
tr_set_ratio() {
    # transmission 具有排序特性，最后一个即是新添加的
    for Tr_ID in $($tr_remote -l|sed -En 's/^[ ]*([0-9]+).*/\1/gp'|sort -nr)
    do
	    name_in_tr=$($tr_remote -t $Tr_ID -i|awk -F 'Name: ' '/Name/{print $2}')
      if [ "$one_TR_Name" = "$name_in_tr" ]; then
          debug_func 'tr:set_ratio'  #----debug---
          for tracker in ${!trackers[*]}; do
              [ "$($tr_remote -t $Tr_ID -i|grep "${trackers[$tracker]}")" ] && \
              $tr_remote -t $Tr_ID -sr "$(eval echo '$'"ratio_$tracker")" && \
              [[ $Allow_Say_Thanks == yes ]] && \
              [[ "$(eval echo '$'"say_thanks_$tracker")" == yes ]] && \
  http --verify=no --ignore-stdin -f POST "${post_site[$tracker]}/thanks.php" \
                id="$t_id" "$(eval echo '$'"cookie_$tracker")" && \
                debug_func 'tr:set_rt_success' && break 2
          done
      fi
    done
}

#------------add torrent--------------#
tr_add_torrent_file() {
    $tr_remote --no-torrent-done-script &> /dev/null
    sleep 2
    debug_func 'tr:add-from-file'  #----debug---
    $tr_remote --add "${ROOT_PATH}/tmp/${t_id}.torrent" -w "$one_TR_Dir"
    $tr_remote --torrent-done-script "$ROOT_PATH/main.sh" &> /dev/null
    #---set seed ratio---#
    tr_set_ratio
}

#------------add torrent--------------#
tr_add_torrent_url() {
    debug_func 'tr:add-from-url'  #----debug---
    $tr_remote --no-torrent-done-script &> /dev/null
    $tr_remote --add "$torrent2add" -w "$one_TR_Dir"
    $tr_remote --torrent-done-script "$ROOT_PATH/main.sh" &> /dev/null
    #---set seed ratio---#
    tr_set_ratio
}

#---------------------------------------#
# call in main.sh
tr_get_torrent_completion() {
    local id_t=$($tr_remote -l|grep "$org_tr_name"|head -1| \
        awk '{print $1}'|grep -Eo '[0-9]+')
    [[ $id_t ]] &&  { 
    debug_func 'tr_4:comp'  #----debug---
    completion=$($tr_remote -t $id_t -i|grep 'Percent Done:'|grep -Eo '[0-9]+'|head -1)
    one_TR_Dir="$($tr_remote -t $id_t -i|grep 'Location:'|grep -o '/.*$')"
    unset id_t; }
    debug_func 'tr:complete'  #----debug---
}

#---------------------------------------#
tr_reannounce() {
    $tr_remote  -t all --reannounce 
}

#---------------------------------------#

