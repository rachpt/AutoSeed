#!/bin/bash
# FileName: post/post.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-12-21
#
#---------------------------------------#
# 将简介以及种子以post方式发布
#---------------------------------------#
# import functions
source "$ROOT_PATH/get_desc/desc.sh"    # get source site
[[ `type -t from_desc_get_param` != "function" ]] && \
  source "$ROOT_PATH/post/parameter.sh"
[[ `type -t judge_torrent_func` != "function" ]] && \
  source "$ROOT_PATH/post/judge.sh"
[[ `type -t match_douban_imdb` != "function" ]] && \
    source "$ROOT_PATH/get_desc/match.sh"
#---------------------------------------#
judge_before_upload() {
  up_status='yes'    # judge code
  yellow_mv='no'
  #---judge to get away from dupe---#
  #[ "$postUrl" = "${post_site[whu]}/takeupload.php" ] && \
      #judge_torrent_func # $ROOT_PATH/post/judge.sh
  [ "$postUrl" = "${post_site[nanyangpt]}/takeupload.php" ] && \
      judge_torrent_func # $ROOT_PATH/post/judge.sh
  #---necessary judge---#
  if [ "$(grep -Em1 '禁止转载|禁转|独占资源' "$source_desc")" ]; then
      up_status='no'  # give up upload
      printf '%b' "禁转禁发资源\n"             >> "${log_Path}-$index"
  elif [[ "$(grep -Em1 '.类.*别.*情色' "$source_desc")" ]]; then
      up_status='no'  # give up upload
      yellow_mv='yes'
      printf '%b' "情色电影。--\n"             >> "${log_Path}-$index"
  fi

  unset t_id        # set t_id to none
  #---post---#
  if [[ $up_status = yes ]]; then
    #---log---#
    printf '%s\n' "-----------[post data]-----------" >> "${log_Path}-$index"
    printf '%s\n' "name=${dot_name}"                  >> "${log_Path}-$index"
    printf '%s\n' "small_descr=${chinese_title}"      >> "${log_Path}-$index"
    printf '%s\n' "imdburl=${imdb_url}"               >> "${log_Path}-$index"
    printf '%s\n' "uplver=${anonymous}"               >> "${log_Path}-$index"
    printf '%s\n' "${postUrl%/*}"                     >> "${log_Path}-$index"
  fi
}

add_t_id_2_client() {        
  #---if get t_id then add it to tr---#
  t_id="${t_id/$'\n'*/}"  # use first line
  [[ $up_status = yes ]] && if [[ -z $t_id ]]; then
    printf '%s\n' '=!==!=[failed to get tID]==!==!==' >> "${log_Path}-$index"
  else
    printf '%s\n' "t_id: [$t_id]"                     >> "${log_Path}-$index"
    #---add torrent---#
    if [[ $downloadUrl =~ .*m-team.cc.* ]]; then
      torrent2add="${downloadUrl}${t_id}&passkey=${passkey}&https=1"  # &ipv6=1
    else
      torrent2add="${downloadUrl}${t_id}&passkey=${passkey}"
    fi
    source "$ROOT_PATH/post/add.sh"
  fi
  unset t_id torrent2add
}
#---------------------------------------#
# 用于辅种
reseed_torrent() {
  local result name
  shopt -s extglob  # 开启扩展匹配
  # 分辨率
  name="${dot_name//*(1080[PpIi]|720[Pp]|4[Kk]|2160[Pp])}"
  name="${name,,}"  # 小写
  # 介质
  name="${name//*(hdtv|blu?(-)ray|web?(-)dl|bdrip|dvdrip|webrip)}"
  # 删除季数
  name="${name//*([ \.]s(?[012][1-9])?(e?p+[0-9])[ \.]*)}"
  name="${name//*([ \.]e?p[0-9]?[0-9]?(-?e?p[0-9]?[0-9])[ \.]*)}"
  #name="$(echo "$name"|sed -E 's/[ \.]ep?[0-9]{1,2}(-e?p?[0-9]{1,2})?[ \.].*//i')"
  # 删除合集
  name="${name//[ \.][Cc]omplete[\. ].*/}"
  name="${name//+(.)/.}"
  result="$(http --verify=no --ignore-stdin -b --timeout=25 GET "${postUrl%/*}/torrents.php?search=${name}&incldead=1" "$cookie" "$user_agent")"
  t_id=$(printf '%s' "$result"|grep "$dot_name"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')
  [[ ! $t_id ]] && {
  result="$(http --verify=no --ignore-stdin -b --timeout=25 GET "${postUrl%/*}/torrents.php?search=${dot_name}&incldead=1" "$cookie" "$user_agent")"
  t_id=$(printf '%s' "$result"|grep "$dot_name"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')
  }
  t_id="${t_id/$'\n'*/}"  # use first line
  debug_func "post:reseed-get[$t_id]"  #----debug---
  shopt -u extglob  # 关闭扩展匹配
}

#---------------------------------------#
unset_tempfiles() {
  [[ -f "${log_Path}-1" ]] && {
    local tmp f
    for f in "${log_Path}-"[0-9]*;do tmp="${tmp}$(< "$f")\n";done
    printf '%b' "$tmp" >> "$log_Path"
    unset tmp f
    #\cat "${log_Path}-"[0-9]* >> "$log_Path"
    \rm -f "${log_Path}-"[0-9]* ; }

  [ ! "$test_func_probe" ] && \
    \rm -f "$source_desc" "$source_html" "$source_desc2tjupt"
    unset source_desc source_html source_desc2tjupt index
    unset douban_poster_url source_site_URL source_t_id imdb_url douban_url
    echo "----------[deleted tmp]----------"   >> "$log_Path"
}

#-----import and call functions---------#
# 获得发布所需参数
from_desc_get_param      # $ROOT_PATH/post/parameter.sh
# 简介头
[[ $No_Headers = yes ]] || set_desc_headers # static.sh
# 美剧imdb链接修正
match_douban_imdb "$dot_name" 'series'
match_douban_imdb "$org_tr_name" 'series'
index=0  # 线程标识符
if [ "$enable_whu" = 'yes' ]; then
    ((index++))
    (source "$ROOT_PATH/post/whu.sh"
    judge_before_upload
    [[ $up_status = yes ]] && whu_post_func
    add_t_id_2_client) &
fi

if [ "$enable_hudbt" = 'yes' ]; then
    ((index++))
    (source "$ROOT_PATH/post/hudbt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && hudbt_post_func
    add_t_id_2_client) &
fi

if [ "$enable_npupt" = 'yes' ]; then
    ((++index))
    (source "$ROOT_PATH/post/npupt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && npupt_post_func
    add_t_id_2_client) &
fi

if [ "$enable_nanyangpt" = 'yes' ]; then
    ((++index))
    (source "$ROOT_PATH/post/nanyangpt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && nanyangpt_post_func
    add_t_id_2_client) &
fi

if [ "$enable_byrbt" = 'yes' ]; then
    ((++index))
    (source "$ROOT_PATH/post/byrbt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && byrbt_post_func
    add_t_id_2_client) &
fi

if [ "$enable_cmct" = 'yes' ]; then
    ((++index))
    (source "$ROOT_PATH/post/cmct.sh"
    judge_before_upload
    [[ $up_status = yes || $yellow_mv = yes ]] && cmct_post_func
    add_t_id_2_client) &
fi
# 只转发特定小组资源
[[ $dot_name =~ .*-(WiKi|HDChina)$ ]] && {
if [ "$enable_mt" = 'yes' ]; then
    ((++index))
    (source "$ROOT_PATH/post/mteam.sh"
    judge_before_upload
    [[ $up_status = yes || $yellow_mv = yes ]] && mt_post_func
    add_t_id_2_client) &
fi
}

if [ "$enable_tjupt" = 'yes' ]; then
    ((++index))
    (source "$ROOT_PATH/post/tjupt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && tjupt_post_func
    add_t_id_2_client) &
fi

if [ "$enable_tlfbits" = 'yes' ]; then
    ((++index))
    (source "$ROOT_PATH/post/tlfbits.sh"
    #judge_before_upload
    up_status='yes'
    tlfbits_post_func
    add_t_id_2_client) &
fi
#---------------------------------------#
wait
#---------------unset-------------------#

unset_tempfiles

#---------------------------------------#

