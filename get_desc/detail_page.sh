#!/bin/bash
# FileName: get_desc/detail_page.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2020-01-09
#
#-------------------------------------#
# 通过搜索原种站点(依据torrent文件中的tracker信息)，
# 只有预定义的站点才有效。
# 获得的原种简介仅筛选 iNFO 以及 screens 保留到临时文件
# source_desc[html 用于 byrbt]，
# 后续合并通过豆瓣生成的简介。
#-------------------------------------#
no_source_2_source() {
   # 来自 byr
   if [[ $source_site_URL =~ .*byr.* ]]; then
       source_site_URL="${post_site[byrbt]}"
       enable_byrbt='no'
       s_site_uid='byrbt'
   # 来自 nanyangpt
   elif [[ $source_site_URL =~ .*nanyangpt.* ]]; then
       source_site_URL="${post_site[nanyangpt]}"
       enable_nanyangpt='no'
       s_site_uid='nanyangpt'
   # 来自 npupt
   elif [[ $source_site_URL =~ .*npupt.* ]]; then
       source_site_URL="${post_site[npupt]}"
       enable_npupt='no'
       s_site_uid='npupt'
   # 来自 tjupt
   elif [[ $source_site_URL =~ .*tjupt.* ]]; then
       source_site_URL="${post_site[tjupt]}"
       enable_tjupt='no'
       s_site_uid='tjupt'
   fi
}

#--------------prepare-func-----------#
get_source_site() {
    # s_site_uid 用于qbittorrent 设置原种 ratio. qbittorrent.sh
    unset source_site_URL cookie_source_site unknown_site source_t_id s_site_uid
    local tracker_info
    tracker_info="$($tr_show "$torrent_Path"|grep -A6 'TRACKERS'| \
        sed '/FILES/,$d;/^$/d;/[ ]*http/!d')"
    # 获取种子原站点
    if [[ "$tracker_info" =~ .*hdsky.* ]]; then
        source_site_URL="${post_site[hds]}"
        s_site_uid='hds'
    elif [[ "$tracker_info" =~ .*totheglory.* ]]; then
        source_site_URL="${post_site[ttg]}"
        s_site_uid='ttg'
    elif [[ "$tracker_info" =~ .*hdchina.* ]]; then
        source_site_URL="${post_site[hdc]}"
        s_site_uid='hdc'
    elif [[ "$tracker_info" =~ .*m-team.cc.* ]]; then
        source_site_URL="${post_site[mt]}"
        s_site_uid='mt'
        enable_mt='no'
    elif [[ "$tracker_info" =~ .*springsunday.net.* ]]; then
        source_site_URL="${post_site[cmct]}"
        s_site_uid='cmct'
        enable_cmct='no'
    #elif [[ "$tracker_info" =~ .*newsite.* ]]; then
    #    source_site_URL="${post_site[newsite]}"
    else
        source_site_URL="$(echo "$tracker_info"|grep -Eo 'https?://[^:/]*'| \
          head -1|sed 's/ssl.empirehost.me/iptorrents.com/;
          s/tracker\.//;s/routing.bgp.technology/iptorrents.com/;
          s/localhost.stackoverflow.tech/iptorrents.com/')"
        # IPT trackers
    fi
    no_source_2_source # 减少不必要的过程
    # set cookie
    [[ $s_site_uid ]] && \
    cookie_source_site="$(eval echo '$'cookie_$s_site_uid)"
}

#-------------------------------------#
set_source_site_cookie() {
    # 供二次编辑简介使用
    if [[ $source_site_URL = ${post_site[hds]} ]]; then
        s_site_uid='hds'
        cookie_source_site="$cookie_hds"
    elif [[ $source_site_URL = ${post_site[ttg]} ]]; then
        s_site_uid='ttg'
        cookie_source_site="$cookie_ttg"
    elif [[ $source_site_URL = ${post_site[hdc]} ]]; then
        s_site_uid='hdc'
        cookie_source_site="$cookie_hdc"
    elif [[ $source_site_URL = ${post_site[mt]} ]]; then
        s_site_uid='mt'
        cookie_source_site="$cookie_mt"
    elif [[ $source_site_URL = ${post_site[cmct]} ]]; then
        s_site_uid='cmct'
        cookie_source_site="$cookie_cmct"
    elif [[ $source_site_URL = ${post_site[byrbt]} ]]; then
        s_site_uid='byrbt'
        cookie_source_site="$cookie_byrbt"
    elif [[ $source_site_URL = ${post_site[npupt]} ]]; then
        s_site_uid='npupt'
        cookie_source_site="$cookie_npupt"
    elif [[ $source_site_URL = ${post_site[nanyangpt]} ]]; then
        s_site_uid='nanyangpt'
        cookie_source_site="$cookie_nanyangpt"
    elif [[ $source_site_URL = ${post_site[tjupt]} ]]; then
        s_site_uid='tjupt'
        cookie_source_site="$cookie_tjupt"
    fi
}

#-------------------------------------#
get_search_keys() {
  local name season season_db year num
  # 剧集季数
  season="$(echo "$1"|grep -Eio '[ \.]s0?(10|20|[1-9]+).?(ep?[0-9]+)?[ \.]')"
  [[ $season ]] && season_db="$(echo "$season"|sed -E \
    's/s0?(10|20|[1-9]+).?(ep?[0-9]+)?[ \.]/Season.\1/i')"
  # 年份
  year="$(echo "$1"|sed 's/1080//;s/2160//'|grep -Eo '[12][098][0-9]{2}'|tail -1)"
  num="$(echo "$1"|sed 's/1080//;s/2160//'|grep -Eo '[12][098][0-9]{2}'|wc -l)" # 统计year个数
  # 删除分辨率
  name="$(echo "$1"|sed -E 's/(1080[pi]|720p|4k|2160p).*//i')"
  # 删除介质
  name="$(echo "$name"|sed -E 's/(hdtv|blu-?ray|web-?(dl)?|bdrip|dvdrip|webrip).*//i')"
  # 删除季数
  name="$(echo "$name"|sed -E 's/[ \.]s0?(10|20|[1-9]+).?(ep?[0-9]+)?[ \.].*//i')"
  name="$(echo "$name"|sed -E 's/[ \.]ep?[0-9]{1,2}(-e?p?[0-9]{1,2})?[ \.].*//i')"
  # 删除合集
  name="$(echo "$name"|sed -E 's/[ \.]Complete[\. ].*//i')"
  # 删除年份
  [[ $num -ge 1 ]] && name="$(echo "$name"|sed -E 's/[ \.][12][098][0-9]{2}[ \.]*/./g')"
  # 删除连续点和空格
  name="$(echo "$name"|sed -E 's/[ \.]+/./g')"
  # 返回
  [[ "$2" = db ]] && echo "$name" || \
  if [[ $year ]]; then
    if [[ $season ]]; then
      echo "${name}+${year}+${season}"
    else
      echo "${name}+${year}"
    fi
  else
    echo "${name}"
  fi
}

#-------------------------------------#
form_source_site_get_tID() {
if [[ "$source_site_URL" && "$cookie_source_site" ]]; then
  local _sw_2 _sw_3 _sw_4
  _get_s_id() {
  ## TODO 搜索原种ID; 一个参数：关键词
  if [[ "$source_site_URL" = ${post_site[ttg]} ]]; then
    # TTG
    local s_search_URL="${source_site_URL}/browse.php"

    source_t_id="$(http --verify=no --ignore-stdin --timeout=25 -b GET \
    "$s_search_URL" c==M search_field=="$1" "$cookie_source_site" "$user_agent"| \
    grep -Eo "id=[0-9]+[^\"]*hit=1"|head -1|grep -Eo '[0-9]{3,}')"
  else
    # 一般形式
    local s_search_URL="${source_site_URL}/torrents.php"

    source_t_id="$(http --verify=no --ignore-stdin --timeout=25 -b GET \
    "$s_search_URL" search=="$1" "$cookie_source_site" "$user_agent"| \
    grep -Eo "id=[0-9]+[^\"]*hit=1"|head -1|grep -Eo '[0-9]{3,}')"
  fi
  }
  # 先判断源cookie是否有效
  [[ "$(http --verify=no --ignore-stdin -b "$source_site_URL" \
    "$cookie_source_site" "$user_agent"|grep 'name="username"')" ]] && { \
    echo "[ $source_site_URL ] Invalid cookie!!!" >> "$log_Path"
    debug_func "detail_p:[ $source_site_URL ] Invalid cookie!!!" # 无效 cookie
  } || {

  # First try
  _get_s_id "$dot_name"

  # Second try
  if [ ! "$source_t_id" ]; then
      debug_func "detail_p:关键词[$dot_name]未搜索到原种id！"
      _sw_2="$(get_search_keys "$dot_name")"
      [[ $dot_name != $_sw_2 ]] && _get_s_id "$_sw_2"
  fi

  #---deal with wrong year---#
  if [ ! "$source_t_id" ]; then
      _sw_3="$(echo "$_sw_2"|sed "s/+[12][089][0-9][0-9]//g")"
      [[ $_sw_3 != $_sw_2 ]] && _get_s_id "$_sw_3"
  fi
  #---try just with base name---#
  if [ ! "$source_t_id" ]; then
      _sw_4="$(echo "$_sw_3"|sed "s/\.+\..*//g")"
      [[ $_sw_4 != $_sw_3 ]] && _get_s_id "$_sw_3"
  fi
  [[ $source_t_id ]] && debug_func "detail_p:source-t_id[$source_t_id]" || \
    debug_func "detail_p:[$_sw_4]未搜索到原种id！"
  }
  unset _search_w
  unset -f _get_s_id
fi
}

#--------------main-func--------------#
form_source_site_get_Desc() {
  [[ $s_site_uid ]] && echo "got source_site: [$s_site_uid]" >> "$log_Path"
  unset imdb_url douban_url extra_subt # 防止上次结果影响到下一次
  form_source_site_get_tID
  # source_t_id will be unset in generate.sh
  if [ "$source_t_id" ]; then
    #---hdsky 认领种子---#
    [[ -f "${ROOT_PATH}/get_desc/hdsky_adoption.sh" ]] && {
      source "${ROOT_PATH}/get_desc/hdsky_adoption.sh"
      call_hdsky_adoption; }
    #---define temp file name---#
    source_full="${ROOT_PATH}/tmp/${org_tr_name}_full.txt"
    http --verify=no --ignore-stdin --timeout=25 -b GET \
        "${source_site_URL}/details.php?id=${source_t_id}" \
        "$cookie_source_site" "$user_agent" > "$source_full"
  #---desc-full--start
  if [ -s "$source_full" ]; then
    # imdb 和豆瓣链接,用于生成简介
    imdb_url="$(grep -Eo 'tt[0-9]{7,8}' "$source_full"|head -1)"
    douban_url="$(grep -Eo 'douban\.com/subject/[0-9]{7,8}' "$source_full"|head -1)"
    [[ $douban_url ]] && douban_url="https://movie.douban.com/subject/${douban_url##*/}"
    [[ "$(grep -E '禁止转载|禁转资源|谢绝转发|独占资源|禁转资源|No forward anywhere' "$source_full")" ]] && local forbid='yes'

    # 匹配官方组 简介中的 info 以及 screens 所在行号
    local start_line end_line middle_line _ep ## extra_subt 原种副标题，非局域变量
    if [[ "$source_site_URL" = "${post_site[hds]}" ]]; then
      extra_subt="$(grep '&passkey=' "$source_full"|sed -E 's/.*">//;s%</.*>%%g')"
      start_line=$(sed -n '/影片参数/=' "$source_full"|head -1)
      end_line=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -1) # 第一个

    elif [[ "$source_site_URL" = "${post_site[hdc]}" ]]; then
      extra_subt="$(grep -A1 '<h2' "$source_full"|grep '<h3>'|sed -E \
        "s/[[:space:]]+/ /;s%</?h3>%%g")"
      start_line=$(sed -n '/<fieldset><legend>/=' "$source_full"|tail -1)
      end_line=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -2|tail -1) # 第二个

    elif [[ "$source_site_URL" = "${post_site[ttg]}" ]]; then
      extra_subt="$(grep '<h1>' "$source_full"|sed -E "s/[^\[]+\[//;s/\]//;s%</?h1>%%g")"
      sed -E -i "s%<br[ ]?/>%<br />\n%ig" "$source_full" # 2019-02-19 update
      # 使用 sed -n '/匹配内容/=' 获取行号
      start_line=$(sed -n '/\.[cC]omparisons/=;/\.[sS]elected\.[sS]creens/=;
      /\.[mM]ore\.[sS]creens/=;/\.[pP]lot/=' "$source_full"|head -1)
      middle_line=$(sed -n '/.x264.[iI]nfo/=' "$source_full"|head -1)
      end_line=$(sed -n "$middle_line,$(($middle_line + 10))p" \
        "$source_full"|sed -n '/<\/table>/='|head -1)  # ttg
      end_line=$(($middle_line + $end_line - 1))       # ttg
      [[ $end_line ]] || end_line=$(sed -n '/x264 [info]/=' "$source_full"|tail -1)


    elif [[ "$source_site_URL" = "${post_site[mt]}" ]]; then
      extra_subt="$(grep -A2 '^<h1' "$source_full"|grep 'class="rowhead"'| \
        sed -E 's/.*">//;s%</.*>%%g')"
      start_line=$(sed -n '/codetop/=' "$source_full"|head -1)
      end_line=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -1) # 第一个

    elif [[ "$source_site_URL" = "${post_site[cmct]}" ]]; then
      extra_subt="$(grep -E "download.php\?id=[0-9]+\">\[CMCT\]" "$source_full"| \
        sed -E 's/.*">//;s%</.*>%%g;s/\[//g;s/\]//g')"
      start_line=$(sed -n '/资料参数/=;/参数信息/=;/General Information/=' "$source_full"|head -1)
      end_line=$(sed -n '/下载信息/=;/郑重声明/=' "$source_full"|head -1) # 第一个

    else
      extra_subt="$(grep -E "副标题" "$source_full"|sed -E 's/.*">//;s%</.*>%%g;s/\[//g;s/\]//g')"
      _ep="$(grep -Eiom1 '[^a-z]Ep?[0-9]{1,2}(-Ep?[0-9]{1,2})?' "$source_full")"
      [[ "$_ep" && "$extra_subt" ]] && {
        _ep="${_ep/$'\n'*/}"  # 取第一行， 替代 head -1
        shopt -s extglob
        extra_subt="${extra_subt} | 集数: ${_ep/?([^a-zA-Z0-9])}"
        shopt -u extglob; }
      # tjupt origin info
      [[ "$source_site_URL" = "${post_site[tjupt]}" ]] && {
      start_line="$(sed -n  '\%<div class="codetop">代码</div>%=' "$source_full")"
      end_line="$(sed -n  '\%</div></td></tr>$%=' "$source_full")"; }

    fi
    # 裁剪简介获取 iNFO 以及 screens
    start_line=${start_line/$'\n'*}; end_line=${end_line/$'\n'*}  # 替代 head -1
    if [[ $start_line && $end_line && $start_line -lt $end_line ]]; then
      sed -n "${start_line},${end_line}p" "$source_full" > "$source_desc"
    else
      debug_func "detail_p:start-l-[$start_line]end-l-[$end_line]"  #----debug---
    fi
    unset start_line end_line middle_line
    #----------------desc----------------start
    if [ -s "$source_desc" ]; then
    #---filter html code---#
    sed -i "s/.*id='kdescr'>//g;s/onclick=\"Previewurl([^)]*)[;]*\"//g;
    s/onload=\"Scale([^)]*)[;]*\"//g;s/onmouseover=\"[^\"]*;\"//g" "$source_desc"
    sed -i "s#onclick=\"Previewurl.*/><br />#/><br />#g" "$source_desc"
    sed -i "/本资源仅限/d;/法律责任/d" "$source_desc"
    sed -Ei "s@\"[^\"]*attachments([^\"]+)@\"${source_site_URL}/attachments\1@ig;
    s#src=\"attachments#src=\"${source_site_URL}/attachments#ig" "$source_desc"
    sed -i "s#onmouseover=\"[^\"]*[;]*\"##ig" "$source_desc"
    sed -i "s#onload=\"[^\"]*[;]*\"##ig" "$source_desc"
    sed -i "s#onclick=\"[^\"]*[;)]*\"##ig" "$source_desc"
    sed -i "1 s/代码//" "$source_desc"
    #---hdsky scripts---#
    sed -Ei "s#<script src=[^>]+></script>##ig" "$source_desc"
    #---ttg,table---#
    sed -Ei "/^x264.*<\/table>/ s!</table>.*!</table>\n!ig" "$source_desc"
 
    #---copy as a duplication for byrbt---#
    [ "$enable_byrbt" = 'yes' ] && { \cp -f "$source_desc" "$source_html"
    sed -Ei 's/fieldset>|legend>/span>/ig;s/ ?引用 ?//g' "$source_html"; }

    #---html2bbcode---#
    source "$ROOT_PATH/get_desc/html2bbcode.sh"
    [[ $forbid = yes ]] && echo -e "\n&禁止转载&\n" >> "$source_desc"
    #----------------desc----------------
    else
      debug_func 'get_desc:failed-to-get-source-page!'  #----debug---
    fi
    #----------------desc----------------end
    
    \rm -f "$source_full"
    unset source_full forbid
  fi
  #---desc-full--end
  fi
}

#-------------------------------------#

