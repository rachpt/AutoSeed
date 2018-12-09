#!/bin/bash
# FileName: qbittorrent.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-08
#
#--------------------------------------#
qb_login="${qb_HOST}:$qb_PORT/api/v2/auth/login"
qb_add="${qb_HOST}:$qb_PORT/api/v2/torrents/add"
qb_delete="${qb_HOST}:$qb_PORT/api/v2/torrents/delete"
qb_ratio="${qb_HOST}:$qb_PORT/api/v2/torrents/setShareLimits"
qb_lists="${qb_HOST}:$qb_PORT/api/v2/sync/maindata"
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
  fi
}

#--------------------------------------#
qb_delete_torrent() {
    qbit_webui_cookie
    # delete
    http --ignore-stdin -f POST "$qb_delete" hashes=$torrent_hash \
        deleteFiles=false "$qb_Cookie"
}

#---------------------------------------#
qb_set_ratio() {
  qbit_webui_cookie
  # from tr name find other info
  local data="$(http --ignore-stdin --pretty=format GET "$qb_lists" \
    "$qb_Cookie"|sed -Ee '1,/"torrents": \{/d;/^[ ]*[},]+$/d;s/^[ ]+//;s/[ ]+[{]+//;s/[},]+//g'| \
    grep -B18 -A13 'name":'|sed -Ee \
    '/".{40}"/{s/"//g};/"magnet_uri":/{s/"//g};/"name":/{s/"//g}'|sed '/"/d')" 
  # get current site
  for site in ${!post_site[*]}; do
    [ "$(echo "$postUrl"|grep "$post_site[$site]")" ] && \
      add_site_tracker="$tracker[$site]" && break # get out of for loop
  done

  while true; do
    # qbit 没有和 tr 类似的排序特性
    # get torrent hash
    # match one!
    local pos=$(echo "$data"|grep -n 'name.*'"$org_tr_name"|head -1|grep -Eo '^[0-9]+')
    [ ! "$pos" ] && break
    local torrent_hash="$(echo "$data"|head -n $(expr $pos - 2)|tail -1| \
        grep -Eo '[0-9a-zA-Z]{40}')"
    # debug
    [ ! "$torrent_hash" ] && echo 'failed to get tr hs' >> "$debug_Log"

    local tracker_one="$(echo "$data"|head -n $(expr $pos - 1)|tail -1| \
        grep 'magnet_uri')"
    # debug
    [ ! "$tracker_one" ] && echo 'failed to get qb tracker' >> "$debug_Log"
    if [ "$(echo "$tracker_one"|grep "$add_site_tracker")" ];then
      if [ "${#torrent_hash}" -eq 40 ]; then
        # set ratio and say thanks
        [[ $ratio_set ]] && \
        http --ignore-stdin -f POST "$qb_ratio" hashes="$torrent_hash" \
        ratioLimit=$ratio_set seedingTimeLimit="$(echo \
        ${MAX_SEED_TIME}*60*60|bc)" "$qb_Cookie" && \
        [[ $Allow_Say_Thanks == yes ]] && \
        [[ "$(eval echo '$'"say_thanks_$site")" == yes ]] && \
        http --verify=no --ignore-stdin -f POST "${post_site[$site]}/thanks.php" \
        id="$t_id" "$(eval echo '$'"cookie_$tracker")" && break 
      else
        echo 'Failed to get torrent ID' >> "$debug_Log"
      fi
    else
      # update data, delete the first name matched
      data="$(echo "$data"|sed "0,/name.*$one_TR_Name/{//d}")"
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
}
#---------------------------------------#
qb_add_torrent_file() {
  qbit_webui_cookie
  # add file
  http --ignore-stdin -f POST "$qb_add" skip_checking=true root_folder=true \
      name@"${ROOT_PATH}/tmp/${t_id}.torrent" savepath="$one_TR_Dir" "$qb_Cookie"
  #  ----> ok
  qb_set_ratio
}

#---------------------------------------#
# call in main.sh
qb_get_torrent_completion() {
  qbit_webui_cookie
  # need a parameter
  local data="$(http --ignore-stdin --pretty=format GET "$qb_lists" \
    "$qb_Cookie"|sed -E '1,/"torrents": \{/d;/^[ ]*[},]+$/d;s/^[ ]+//;s/[ ]+[{]+//;s/[},]+//g'| \
    grep -B18 -A13 'name":'|sed -E \
    '/"completed":/{s/"//g};/"name":/{s/"//g};/"save_path":/{s/"//g};/"size":/{s/"//g};'|sed '/"/d')" 
  # match one!
  local pos=$(echo "$data"|grep -n 'name.*'"$org_tr_name"|head -1|grep -Eo '^[0-9]+')
  [[ $pos ]] && {
  local compl_one="$(echo "$data"|head -n $(expr $pos - 1)|tail -1|grep -Eo '[0-9]{4,}')"
  local size_one="$(echo "$data"|head -n $(expr $pos + 2)|tail -1|grep -Eo '[0-9]{4,}')"
  one_TR_Dir="$(echo "$data"|head -n $(expr $pos + 1)|tail -1|grep -o '/.*$')";
  }
  # return completed precent
  [[ $compl_one && $size_one ]] && \
  completion=$(awk -v a="$compl_one" -v b="$size_one" 'BEGIN{printf "%d",(a/b)*100}')
  unset data compl_one size_one pos
}
#---------------------------------------#
