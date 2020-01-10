#!/bin/bash
# FileName: get_desc/hdsky_adoption.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2020-02-10
#
#-------------------------------------#
# 本 shell 脚本作用为 hdsky 认领种子。
#-------------------------------------#
call_hdsky_adoption(){
  if [[ $s_site_uid == 'hds' && $source_t_id ]]; then
    local hds_adoption_url _uid hds_faq_url
    hds_faq_url="${post_site[hds]}/faq.php"
    _uid="$(http --verify=no --timeout=10 -Ib GET "$hds_faq_url" "$cookie_hds" \
      "$user_agent"|grep -Eio 'userdetails.php\?id=[0-9]+'|grep -om1 '[0-9]*')"
    [[ $_uid ]] || debug_func "hdsky_adoption:获取用户id失败！"  #----debug---
    hds_adoption_url="${post_site[hds]}/adoption.php"
    if http --verify=no --timeout=10 --print=h -If POST "$hds_adoption_url" \
      torrentid="$source_t_id" uid="$_uid" action='add' "$cookie_hds" \
      "$user_agent" &> /dev/null; then
        debug_func "hdsky_adoption:成功认领-[$source_t_id]"  #----debug---
    else
      case $? in
        2) debug_func 'hdsky_adoption:Request timed out!' ;;
        3) debug_func 'hdsky_adoption:Unexpected HTTP 3xx Redirection!' ;;
        4) debug_func 'hdsky_adoption:HTTP 4xx Client Error!' ;;
        5) debug_func 'hdsky_adoption:HTTP 5xx Server Error!' ;;
        6) debug_func 'hdsky_adoption:Exceeded --max-redirects=<n> redirects!' ;;
        *) debug_func 'hdsky_adoption:Other Error!' ;;
      esac
    fi
  fi
}

