#!/bin/bash
# FileName: post/post.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-07-16
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
    #---judge to get away from dupe---#
    #[ "$postUrl" = "${post_site[whu]}/takeupload.php" ] && \
        #judge_torrent_func # $ROOT_PATH/post/judge.sh
    [ "$postUrl" = "${post_site[nanyangpt]}/takeupload.php" ] && \
        judge_torrent_func # $ROOT_PATH/post/judge.sh
    #---necessary judge---# 
    if [ "$(grep -E '禁止转载|禁转|独占资源' "$source_desc")" ]; then
        up_status='no'  # give up upload
        echo "禁转禁发资源"                      >> "${log_Path}-$index"
    elif [[ "$(grep -E '.类.*别.*情色' "$source_desc")" ]]; then
        up_status='no'  # give up upload
        echo "情色电影。--"                      >> "${log_Path}-$index"
    fi

    unset t_id        # set t_id to none
    #---post---#
    if [[ $up_status = yes ]]; then
        #---log---#
        echo "-----------[post data]-----------" >> "${log_Path}-$index"
        echo "name=${dot_name}"                  >> "${log_Path}-$index"
        echo "small_descr=${chinese_title}"      >> "${log_Path}-$index"
        echo "imdburl=${imdb_url}"               >> "${log_Path}-$index"
        echo "uplver=${anonymous}"               >> "${log_Path}-$index"
        echo "${postUrl%/*}"                     >> "${log_Path}-$index"
    fi
}

add_t_id_2_client() {        
    #---if get t_id then add it to tr---#
    t_id="${t_id/$'\n'*/}"  # use first line
    [[ $up_status = yes ]] && if [[ -z $t_id ]]; then
        echo '=!==!=[failed to get tID]==!==!==' >> "${log_Path}-$index"
    else
        echo "t_id: [$t_id]"                     >> "${log_Path}-$index"
        #---add torrent---#
        torrent2add="${downloadUrl}${t_id}&passkey=${passkey}"
        source "$ROOT_PATH/post/add.sh"
    fi
    unset t_id torrent2add
}
#---------------------------------------#
# 用于辅种
reseed_torrent() {
  local result name
  # 分辨率
  name="$(echo "$dot_name"|sed -E 's/(1080[pi]|720p|4k|2160p).*//i')"
  # 介质
  name="$(echo "$name"|sed -E 's/(hdtv|blu-?ray|web-?dl|bdrip|dvdrip|webrip).*//i')"
  # 删除季数
  name="$(echo "$name"|sed -E 's/[ \.]s([012]?[1-9])(ep?[0-9]+)?[ \.].*//i')"
  name="$(echo "$name"|sed -E 's/[ \.]ep?[0-9]{1,2}(-e?p?[0-9]{1,2})?[ \.].*//i')"
  # 删除合集
  name="$(echo "$name"|sed -E 's/[ \.]Complete[\. ].*//i')"
  result="$(http --verify=no --ignore-stdin -b --timeout=25 GET "${postUrl%/*}/torrents.php?search=${name}&incldead=1" "$cookie" "$user_agent")"
  t_id=$(echo "$result"|grep "$dot_name"|grep -Eoi '[^a-z]details\.php\?id=[0-9]+'|head -1|grep -Eo '[0-9]+')
  [[ ! $t_id ]] && {
  result="$(http --verify=no --ignore-stdin -b --timeout=25 GET "${postUrl%/*}/torrents.php?search=${dot_name}&incldead=1" "$cookie" "$user_agent")"
  t_id=$(echo "$result"|grep "$dot_name"|grep -Eoi '[^a-z]details\.php\?id=[0-9]+'|head -1|grep -Eo '[0-9]+')
  }
  debug_func "post:reseed-get[$t_id]"  #----debug---
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
    [[ $up_status = yes ]] && cmct_post_func
    add_t_id_2_client) &
fi

if [ "$enable_tjupt" = 'yes' ]; then
    ((++index))
    (source "$ROOT_PATH/post/tjupt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && tjupt_post_func
    add_t_id_2_client) &
fi
#---------------------------------------#
wait
#---------------unset-------------------#

unset_tempfiles

#---------------------------------------#

