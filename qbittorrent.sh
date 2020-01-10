#!/bin/bash
# FileName: qbittorrent.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2020-01-10
#
#--------------------------------------#
qb_login="${qb_HOST}:$qb_PORT/api/v2/auth/login"
qb_add="${qb_HOST}:$qb_PORT/api/v2/torrents/add"
qb_delete="${qb_HOST}:$qb_PORT/api/v2/torrents/delete"
qb_ratio="${qb_HOST}:$qb_PORT/api/v2/torrents/setShareLimits"
qb_lists="${qb_HOST}:$qb_PORT/api/v2/torrents/info"
qb_reans="${qb_HOST}:$qb_PORT/api/v2/torrents/reannounce"
qb_addTker="${qb_HOST}:$qb_PORT/api/v2/torrents/addTrackers"
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
      debug_func 'qb:failed-to-get-cookie'  #----debug---
    fi
    debug_func 'qb:update-cookie'  #----debug---
  fi
}

#--------------------------------------#
qb_reannounce() {
    if [[ $qb_USER ]]; then
        qbit_webui_cookie
        http --ignore-stdin -f POST "$qb_reans" hashes=all "$qb_Cookie"
    fi
}
#--------------------------------------#
qb_delete_torrent() {
    qbit_webui_cookie
    # delete torrent, need a parameter; used in clean/qb.sh
    http --ignore-stdin -f POST "$qb_delete" hashes="$1" \
        deleteFiles=false "$qb_Cookie"
    debug_func "qb:del:[$1]"  #----debug---
}

#---------------------------------------#
qb_set_ratio_queue() {
  local add_site_tracker
  for site in ${!post_site[*]}; do
    [[ "$postUrl" =~ ${post_site[$site]}.* ]] && {
      add_site_tracker="${trackers[$site]}"
      break; }
  done

  debug_func "qb:set-ratio-queue[$site]"  #----debug---
  echo -e "${org_tr_name}\n${add_site_tracker}\n${ratio_set}" >> \
      "${qb_rt_queue}-$index"
  # say thanks 
  [[ $Allow_Say_Thanks == yes ]] && \
  [[ "$(eval echo '$'"say_thanks_$site")" == yes ]] && \
  if http --verify=no --ignore-stdin -h -f POST "${post_site[$site]}/thanks.php" \
    id="$t_id" "$(eval echo '$'"cookie_$site")" "$user_agent" &> /dev/null; then
    debug_func "qb:set-ratio-say-thanks-[$site]"  #----debug---
  else
    case $? in
      2) debug_func 'qbit[thx]:Request timed out!' ;;
      3) debug_func 'qbit[thx]:Unexpected HTTP 3xx Redirection!' ;;
      4) debug_func 'qbit[thx]:HTTP 4xx Client Error!' ;;
      5) debug_func 'qbit[thx]:HTTP 5xx Server Error!' ;;
      6) debug_func 'qbit[thx]:Exceeded --max-redirects=<n> redirects!' ;;
      *) debug_func 'qbit[thx]:Other Error!' ;;
    esac
    curl -k -b "`eval echo '$'"cookie_$site"|sed -E 's/^cookie:[ ]?//i'`" -X POST \
      -F "id=$t_id" -A "`echo "$user_agent"|sed -E 's/^User-Agent:[ ]?//i'`" \
      "${post_site[$site]}/thanks.php" && debug_func 'qbit:used-curl-say-thanks'
  fi

  unset site
}

#---------------------------------------#
qb_get_hash() {
  # $1 name; $2 tracker; $3 qb info lists; return hash(echo), used in qb_set_ratio_loop
  local _hash _one _pos
  echo "$3"|sed -n "/name.*$1/="|while read _pos; do
    _hash="$(echo "$3"|sed -n "$((_pos - 1)) {s/hash: *//;p}")"
    _one="$(echo "$3"|sed -n "$((_pos + 1)) {s/tracker: *//;s/passkey=.*//;p}")"
    [[ "$(echo "$_one"|grep "$2")" ]] && echo "$_hash" && break
  done
}

#---------------------------------------#
qb_set_ratio_loop() {
  [[ -f "${qb_rt_queue}-1" ]] && {
    local tmp f
    for f in "${qb_rt_queue}-"[0-9]*;do tmp="${tmp}$(< "$f")\n";done
    printf '%b' "$tmp" > "$qb_rt_queue"
    unset tmp f
    #\cat "${qb_rt_queue}-"[0-9]* > "$qb_rt_queue"
    \rm -f "${qb_rt_queue}-"[0-9]* ; }
  if [ -s "$qb_rt_queue" ]; then
    local data qb_lp_counter trker rtio tr_hash
    sleep 20 # 延时
    qbit_webui_cookie
    data="$(http --ignore-stdin --pretty=format -f POST "$qb_lists" sort=added_on reverse=true \
    "$qb_Cookie"|sed -E '/^[ ]*[},]+$/d;s/^[ ]+//;s/[ ]+[{]+//;s/[},]+//g'| \
    grep -B18 -A19 'name":'|sed -E \
    '/"hash":/{s/"//g};/"name":/{s/"//g};/"tracker":/{s/"//g};'|sed '/"/d')" 
    qb_lp_counter=0
    while true; do
      name="$(head -1 "$qb_rt_queue")"                    # line one
      [[ ! $name ]] && break                              # jump out
      [[ $qb_lp_counter -gt 50 ]] && break                # jump out
      trker="$(head -2 "$qb_rt_queue"|tail -1)"           # line second
      rtio="$(head -3 "$qb_rt_queue"|tail -1)"            # line third
      tr_hash="$(qb_get_hash "$name" "$trker" "$data")"   # get hash
      # 设置qbit 做种时间以及做种分享率，一天1440分钟，qbt时间分钟
      [ "${#tr_hash}" -eq 40 ] && debug_func "find[$tr_hash]" && \
      if http --ignore-stdin -f POST "$qb_ratio" hashes="$tr_hash" \
        ratioLimit=$rtio seedingTimeLimit="$(echo "$MAX_SEED_TIME * 1440"|bc)" \
        "$qb_Cookie" &> /dev/null; then
          # mteam 添加 ipv6 tracker 链接
          [[ $trker = ${trackers[mt]} ]] && {
            local mt_ipv6
            sleep 10
            mt_ipv6="https://ipv6.${post_site[mt]##*//}/announce.php?passkey=$passkey_mt"
            http -If POST "$qb_addTker" hash="$tr_hash" urls="$mt_ipv6" "$qb_Cookie"
          }
          debug_func "qb:sussess_set_rt[$trker]"       #----debug---
      else
        case $? in
          2) debug_func 'qbit[rtio]:Request timed out!' ;;
          3) debug_func 'qbit[rtio]:Unexpected HTTP 3xx Redirection!' ;;
          4) debug_func 'qbit[rtio]:HTTP 4xx Client Error!' ;;
          5) debug_func 'qbit[rtio]:HTTP 5xx Server Error!' ;;
          6) debug_func 'qbit[rtio]:Exceeded --max-redirects=<n> redirects!' ;;
          *) debug_func 'qbit[rtio]:Other Error!' ;;
        esac
        curl -k -b "`echo "$qb_Cookie"|sed -E 's/^cookie:[ ]?//i'`" -X POST \
          -F "hashes=$tr_hash" -F "ratioLimit=$rtio" \
          -F "seedingTimeLimit=$(echo "$MAX_SEED_TIME * 1440"|bc)" \
          "$qb_ratio" && debug_func "qb:sussess_set_rt-curl[$trker]"
      fi
      sed -i '1,3d' "$qb_rt_queue"                     # delete record
      ((qb_lp_counter++))                              # C 形式的增1
    done
    debug_func 'main:exit\n'  #----debug---
  fi
}

#---------------------------------------#
qb_add_torrent_url() {
  sleep 2
  qbit_webui_cookie
  # add url
  debug_func 'qb:add-from-url'  #----debug---
  if http --ignore-stdin -f POST "$qb_add" urls="$torrent2add" root_folder=true \
    savepath="$one_TR_Dir" skip_checking=true "$qb_Cookie" &> /dev/null; then
    echo 'qbit添加种子成功'
    debug_func 'qbit:添加种子成功'  #----debug---
  else
    case $? in
      2) debug_func 'qbit:Request timed out!' ;;
      3) debug_func 'qbit:Unexpected HTTP 3xx Redirection!' ;;
      4) debug_func 'qbit:HTTP 4xx Client Error!' ;;
      5) debug_func 'qbit:HTTP 5xx Server Error!' ;;
      6) debug_func 'qbit:Exceeded --max-redirects=<n> redirects!' ;;
      *) debug_func 'qbit:Other Error!' ;;
    esac
    echo 'qbit添加种子失败'
    sleep 5
    debug_func "urls=${torrent2add/passkey*/} path=$one_TR_Dir $qb_Cookie"
    curl -k -b "`echo "$qb_Cookie"|sed -E 's/^cookie:[ ]?//i'`" -X POST \
      -F "urls=$torrent2add" -F 'root_folder=true' -F "savepath=$one_TR_Dir" \
      -F 'skip_checking=true' "$qb_add" && debug_func 'qbit:used-curl-POST'
  fi

  sleep 12  # 保证tracker字段值
  qb_set_ratio_queue
}
#---------------------------------------#
qb_add_torrent_file() {
  sleep 2
  qbit_webui_cookie
  # add file
  debug_func 'qb:add-from-file'  #----debug---
  http --ignore-stdin -f POST "$qb_add" skip_checking=true root_folder=true \
      name@"${ROOT_PATH}/tmp/${t_id}.torrent" savepath="$one_TR_Dir" "$qb_Cookie"
  #  ----> ok
  # curl 
# curl -k -b "`echo "$qb_Cookie"|sed -E 's/^cookie:[ ]?//i'`" -X POST -F 'root_folder=true' \
#   -F "name=@$${ROOT_PATH}/tmp/${t_id}.torrent" -F "savepath=$one_TR_Dir" \
#   -F 'skip_checking=true' "$qb_add" && debug_func 'qbit:used-curl-POST'
  sleep 12
  qb_set_ratio_queue
}

#---------------------------------------#
# call in main.sh
qb_get_torrent_completion() {
  qbit_webui_cookie
  # need a parameter
  local data pos compl_one size_one
  data="$(http --ignore-stdin --pretty=format -f POST "$qb_lists" sort=added_on reverse=true \
    "$qb_Cookie"|sed -E '/^[ ]*[},]+$/d;s/^[ ]+//;s/[ ]+[{]+//;s/[},]+//g'| \
    grep -B17 -A15 'name":'|sed -E \
    '/"completed":/{s/"//g};/"name":/{s/"//g};/"save_path":/{s/"//g};/"size":/{s/"//g};'|sed '/"/d')" 
  # match the torrent recently added.
  pos=$(echo "$data"|sed -n "/name.*$org_tr_name/{=;q}")
  [[ $pos =~ [0-9]+ ]] && {
   compl_one="$(echo "$data"|sed -n "$((pos - 1)) p"|grep -Eo '[0-9]{4,}')"
   size_one="$(echo "$data"|sed -n "$((pos + 2)) p"|grep -Eo '[0-9]{4,}')"
   # one_TR_Dir is not local variable
   one_TR_Dir="$(echo "$data"|sed -n "$((pos + 1)) p"|grep -o '/.*$')";
  } || {
    debug_func "qbit:completion-pos[$pos]"  #----debug---
  }
  # return completed precent
  [[ $compl_one && $size_one ]] && \
  completion=$(awk -v a="$compl_one" -v b="$size_one" 'BEGIN{printf "%d",(a/b)*100}')
  unset data compl_one size_one pos
  #debug_func 'qb:complete-func'  #----debug---
}
#---------------------------------------#

