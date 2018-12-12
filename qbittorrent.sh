#!/bin/bash
# FileName: qbittorrent.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-12
#
#--------------------------------------#
qb_login="${qb_HOST}:$qb_PORT/api/v2/auth/login"
qb_add="${qb_HOST}:$qb_PORT/api/v2/torrents/add"
qb_delete="${qb_HOST}:$qb_PORT/api/v2/torrents/delete"
qb_ratio="${qb_HOST}:$qb_PORT/api/v2/torrents/setShareLimits"
qb_lists="${qb_HOST}:$qb_PORT/api/v2/torrents/info"
#--------------------------------------#
qbit_webui_cookie() {
  if [ "$(http --ignore-stdin -b GET "${qb_HOST}:$qb_PORT" "$qb_Cookie"| \
    grep 'id="username"')" ]; then
    qb_Cookie="cookie:$(http --ignore-stdin -hf POST "$qb_login" \
        username="$qb_USER" password="$qb_PASSWORD"| \
        sed -En '/set-cookie:/{s/.*(SID=[^;]+).*/\1/i;p;q}')"
    # 更新 qb cookie
    if [ "$qb_Cookie" ]; then
      sed -i "s/^qb_Cookie=.*/qb_Cookie=\'$qb_Cookie\'/" "$ROOT_PATH/settings.sh" 
    else
      echo 'Failed to get qb cookie!' >> "$debug_Log"
    fi
    #----debug---
    debug_func 'qb_1:coo'  #----debug---
  fi
}

#--------------------------------------#
qb_delete_torrent() {
    qbit_webui_cookie
    # delete
    http --ignore-stdin -f POST "$qb_delete" hashes=$torrent_hash \
        deleteFiles=false "$qb_Cookie"
    debug_func 'qb_2:delet'  #----debug---
}

#---------------------------------------#
qb_set_ratio() {
  qbit_webui_cookie
  # from tr name find other info
  debug_func 'qb_3:r-start'  #----debug---
  local data="$(http --ignore-stdin --pretty=format GET "$qb_lists" sort=added_on reverse=true \
    "$qb_Cookie"|sed -Ee '/^[ ]*[},]+$/d;s/^[ ]+//;s/[ ]+[{]+//;s/[},]+//g'| \
    grep -B18 -A19 'name":'|sed -Ee \
    '/"hash":/{s/"//g};/"name":/{s/"//g};/"tracker":/{s/"//g};'|sed '/"/d')" 
  # get current site
  for site in ${!post_site[*]}; do
    [ "$(echo "$postUrl"|grep "${post_site[$site]}")" ] && \
      add_site_tracker="${trackers[$site]}" && break # get out of for loop
  done
  debug_func 'qb_3:rt_-'"$add_site_tracker"  #----debug---

  while true; do
    # qbit 没有和 tr 类似的排序特性
    # get torrent hash
    # match one!
    local pos=$(echo "$data"|sed -n "/name.*$org_tr_name/="|head -1)
    [ ! "$pos" ] && break
    debug_func 'qb_pos-'"$pos"  #----debug---
    local torrent_hash="$(echo "$data"|head -n $(expr $pos - 1)|tail -1| \
        sed 's/hash: //'|grep -Eo '[^: ]{40}')"
    # debug
    [ ! "$torrent_hash" ] && echo 'failed to get tr hs' >> "$debug_Log"
    debug_func 'qb_hash-'"$torrent_hash"  #----debug---

    local tracker_one="$(echo "$data"|head -n $(expr $pos + 1)|tail -1| \
        grep 'tracker')"
    debug_func 'qb_tracker-'"$tracker_one"  #----debug---
    # debug
    [ ! "$tracker_one" ] && echo 'failed to get qb tracker' >> "$debug_Log"
    if [ "$(echo "$tracker_one"|grep "$add_site_tracker")" ];then
      if [ "${#torrent_hash}" -eq 40 ]; then
        # set ratio and say thanks
        debug_func 'qb_5:rt'  #----debug---
        [[ $ratio_set ]] && \
        http --ignore-stdin -f POST "$qb_ratio" hashes="$torrent_hash" \
        ratioLimit=$ratio_set seedingTimeLimit="$(echo \
        ${MAX_SEED_TIME}*60*60|bc)" "$qb_Cookie" && \
        [[ $Allow_Say_Thanks == yes ]] && \
        [[ "$(eval echo '$'"say_thanks_$site")" == yes ]] && \
        http --verify=no --ignore-stdin -f POST "${post_site[$site]}/thanks.php" \
        id="$t_id" "$(eval echo '$'"cookie_$tracker")" && break 
      else
        echo 'qb failed to get torrent ID' >> "$debug_Log"
      fi
    else
      # update data, delete the first name matched
      data="$(echo "$data"|sed "1,$pos d")"
    debug_func 'qb_6:rt'  #----debug---
    fi
  done
  unset site add_site_tracker data torrent_hash tracker_one
}
  
#---------------------------------------#
qb_add_torrent_url() {
  qbit_webui_cookie
  # add url
  http --ignore-stdin -f POST "$qb_add" urls="$torrent2add" root_folder=true \
      savepath="$one_TR_Dir" skip_checking=true "$qb_Cookie"
  qb_set_ratio
  debug_func 'qb_7:aurl'  #----debug---
}
#---------------------------------------#
qb_add_torrent_file() {
  qbit_webui_cookie
  # add file
  http --ignore-stdin -f POST "$qb_add" skip_checking=true root_folder=true \
      name@"${ROOT_PATH}/tmp/${t_id}.torrent" savepath="$one_TR_Dir" "$qb_Cookie"
  #  ----> ok
  qb_set_ratio
  debug_func 'qb_8:afile'  #----debug---
}

#---------------------------------------#
# call in main.sh
qb_get_torrent_completion() {
  qbit_webui_cookie
  # need a parameter
  local data="$(http --ignore-stdin --pretty=format GET "$qb_lists" sort=added_on reverse=true \
    "$qb_Cookie"|sed -E '/^[ ]*[},]+$/d;s/^[ ]+//;s/[ ]+[{]+//;s/[},]+//g'| \
    grep -B17 -A15 'name":'|sed -E \
    '/"completed":/{s/"//g};/"name":/{s/"//g};/"save_path":/{s/"//g};/"size":/{s/"//g};'|sed '/"/d')" 
  # match one!
  local pos=$(echo "$data"|sed -n "/name.*$org_tr_name/="|tail -1)
  [[ $pos ]] && {
  local compl_one="$(echo "$data"|head -n $(expr $pos - 1)|tail -1|grep -Eo '[0-9]{4,}')"
  local size_one="$(echo "$data"|head -n $(expr $pos + 2)|tail -1|grep -Eo '[0-9]{4,}')"
  one_TR_Dir="$(echo "$data"|head -n $(expr $pos + 1)|tail -1|grep -o '/.*$')";
  }
  # return completed precent
  [[ $compl_one && $size_one ]] && \
  completion=$(awk -v a="$compl_one" -v b="$size_one" 'BEGIN{printf "%d",(a/b)*100}')
  unset data compl_one size_one pos
  debug_func 'qb_9:comp'  #----debug---
}
#---------------------------------------#
