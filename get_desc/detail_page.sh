#!/bin/bash
# FileName: get_desc/detail_page.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-03-15
#
#-------------------------------------#
# 通过搜索原种站点(依据torrent文件中的tracker信息)，
# 只有预定义的站点才有效。
# 获得的原种简介仅筛选 iNFO 以及 screens 保留到临时文件
# source_desc[html 用于 byrbt]，
# 后续合并通过豆瓣生成的简介。
#-------------------------------------#

# 自定义发布规则
source "$ROOT_PATH/get_desc/customize.sh"
#-------------------------------------#
get_source_site() {
    # s_site_uid 用于qbittorrent 设置原种 ratio. qbittorrent.sh
    unset source_site_URL cookie_source_site unknown_site source_t_id s_site_uid
    local tracker_info="$($tr_show "$torrent_Path"|grep -A5 'TRACKERS')"
    # 获取种子原站点
    if [ "$(echo $tracker_info|grep -i 'hdsky')" ]; then
        source_site_URL='https://hdsky.me'
        cookie_source_site="$cookie_hds"
        s_site_uid='hds'
    elif [ "$(echo $tracker_info|grep -i 'totheglory')" ]; then
        source_site_URL='https://totheglory.im'
        cookie_source_site="$cookie_ttg"
        s_site_uid='ttg'
    elif [ "$(echo $tracker_info|grep -i 'hdchina')" ]; then
        source_site_URL='https://hdchina.org'
        cookie_source_site="$cookie_hdc"
        s_site_uid='hdc'
    elif [ "$(echo $tracker_info|grep -i 'tp.m-team.cc')" ]; then
        source_site_URL='https://tp.m-team.cc'
        cookie_source_site="$cookie_mt"
        s_site_uid='mt'
    elif [ "$(echo $tracker_info|grep -i 'hdcmct.org')" ]; then
        source_site_URL='https://hdcmct.org'
        cookie_source_site="$cookie_cmct"
        s_site_uid='cmct'
    #elif [ "$(echo $tracker_info|grep -i 'new')" ]; then
    #    source_site_URL='https://new.tracker.org'
    else
        unknown_site="$(echo "$tracker_info"|grep -Eo 'https?://[^/]*'| \
          head -1|sed 's/tracker\.//')"
    fi
}

#-------------------------------------#
no_source_2_source() {
   # 来自 byr
   if [[ $source_site_URL =~ https?://byr\.cn ]]; then
       source_site_URL='https://bt.byr.cn'
       enable_byrbt='no'
   # 来自 cmct
   elif [[ $source_site_URL =~ https?://hdcmct\.org ]]; then
       enable_cmct='no'
   # 来自 nanyangpt
   elif [[ $source_site_URL =~ https?://nanyangpt\.com ]]; then
       enable_nanyangpt='no'
   # 来自 npupt
   elif [[ $source_site_URL =~ https?://.*npupt\.com ]]; then
       source_site_URL='https://npupt.com'
       enable_npupt='no'
   # 来自 tjupt
   elif [[ $source_site_URL =~ https?://.*tjupt\.org ]]; then
       source_site_URL='https://tjupt.org'
       enable_tjupt='no'
   fi
}

#-------------------------------------#
set_source_site_cookie() {
    #i 供二次编辑简介使用
    if [ "$source_site_URL" = "https://hdsky.me" ]; then
        cookie_source_site="$cookie_hds"
    elif [ "$source_site_URL" = "https://totheglory.im" ]; then
        cookie_source_site="$cookie_ttg"
    elif [ "$source_site_URL" = "https://hdchina.org" ]; then
        cookie_source_site="$cookie_hdc"
    elif [ "$source_site_URL" = "https://tp.m-team.cc" ]; then
        cookie_source_site="$cookie_mt"
    elif [ "$source_site_URL" = "https://hdcmct.org" ]; then
        cookie_source_site="$cookie_cmct"
    fi
}

#-------------------------------------#
form_source_site_get_tID() {
if [ "$source_site_URL" ]; then
    _get_s_id() {
    ## TODO 搜索原种ID
    if [ "$source_site_URL" = "https://totheglory.im" ]; then
        # TTG
        local s_search_URL="${source_site_URL}/browse.php"

        source_t_id="$(http --verify=no --ignore-stdin --timeout=25 -b GET \
        "$s_search_URL" c==M search_field=="$_search_w" "$cookie_source_site" "$user_agent"| \
        grep -Eo "id=[0-9]+[^\"]*hit=1"|head -1|grep -Eo '[0-9]{4,}')"
    else
        # 一般形式
        local s_search_URL="${source_site_URL}/torrents.php"

        source_t_id="$(http --verify=no --ignore-stdin --timeout=25 -b GET \
        "$s_search_URL" search=="$_search_w" "$cookie_source_site" "$user_agent"| \
        grep -Eo "id=[0-9]+[^\"]*hit=1"|head -1|grep -Eo '[0-9]{4,}')"
    fi
    }
    local _search_w="$dot_name"
    _get_s_id

    #---deal with wrong year---#
    if [ ! "$source_t_id" ]; then
        _search_w="$(echo "$dot_name"|sed "s/[12][089][0-9][0-9]//g")"
        _get_s_id
    fi
    # 判断cookie是否有效，写入debug
    [[ $source_t_id ]] && debug_func "get_desc:source-t_id[$source_t_id]" || {
      [[ "$(http --verify=no --ignore-stdin -b "$source_site_URL" \
      "$cookie_source_site" "$user_agent"|grep 'name="username"')" ]] && \
      echo "[$source_site_URL]invalid cookie!!!" >> "$log_Path"
      debug_func "get_desc:[$source_site_URL]invalid cookie!!!" # 无效 cookie
    }
    unset _search_w
    unset -f _get_s_id
else
    # 用于简介
    source_site_URL="$unknown_site"
    unset unknown_site
fi
no_source_2_source # 减少不必要的过程
}

#--------------main-func--------------#
form_source_site_get_Desc() {
  echo "got source_site: [$s_site_uid]" >> "$log_Path"
  unset imdb_url douban_url extra_subt # 防止上次结果影响到下一次
  form_source_site_get_tID
  # source_t_id will be unset in generate.sh
  if [ "$source_t_id" ]; then
    #---define temp file name---#
    source_full="${ROOT_PATH}/tmp/${org_tr_name}_full.txt"
    http --verify=no --ignore-stdin --timeout=25 -b GET \
        "${source_site_URL}/details.php?id=${source_t_id}" \
        "$cookie_source_site" "$user_agent" > "$source_full"
  #---desc-full--start
  if [ -s "$source_full" ]; then
    # imdb 和豆瓣链接,用于生成简介
    imdb_url="$(grep -Eo 'tt[0-9]{7}' "$source_full"|head -1)"
    douban_url="$(grep -Eo 'douban\.com/subject/[0-9]{7,8}' "$source_full"|head -1)"
    [[ $douban_url ]] && douban_url="https://movie.douban.com/subject/${douban_url##*/}"
    [ "$(grep -E '禁止转载|禁转资源|谢绝转发|独占资源|禁转资源|No forward anywhere' "$source_full")" ] && local forbid='yes'

    # 匹配官方组 简介中的 info 以及 screens 所在行号
    local start_line end_line middle_line # extra_subt 原种副标题，非局域变量
    if [ "$source_site_URL" = "https://hdsky.me" ]; then
      extra_subt="$(grep -A1 '&passkey=' "$source_full"|sed -E 's/.*">//;s%</.*>%%g')"
      start_line=$(sed -n '/影片参数/=' "$source_full"|head -1)
      end_line=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -1) # 第一个

    elif [ "$source_site_URL" = "https://hdchina.org" ]; then
      extra_subt="$(grep -A1 '<h2' "$source_full"|grep '<h3>'|sed -E \
        "s/[[:space:]]+/ /;s%</?h3>%%g")"
      start_line=$(sed -n '/<fieldset><legend>/=' "$source_full"|tail -1)
      end_line=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -2|tail -1) # 第二个

    elif [ "$source_site_URL" = "https://totheglory.im" ]; then
      extra_subt="$(grep '<h1>' "$source_full"|sed -E "s/[^\[]+\[//;s/\]//;s%</?h1>%%g")"
      sed -E -i "s%<br[ ]?/>%<br />\n%ig" "$source_full" # 2019-02-19 update
      # 使用 sed -n '/匹配内容/=' 获取行号
      start_line=$(sed -n '/\.[cC]omparisons/=;/\.[sS]elected\.[sS]creens/=;/\.[mM]ore\.[sS]creens/=;/\.[pP]lot/=' "$source_full"|head -1)
      middle_line=$(sed -n '/.x264.[iI]nfo/=' "$source_full"|head -1)
      end_line=$(sed -n "$middle_line,$(($middle_line + 10))p" \
        "$source_full"|sed -n '/<\/table>/='|head -1)  # ttg
      end_line=$(($middle_line + $end_line - 1))       # ttg
      [[ $end_line ]] || end_line=$(sed -n '/x264 [info]/=' "$source_full"|tail -1)


    elif [ "$source_site_URL" = "https://tp.m-team.cc" ]; then
      extra_subt="$(grep -A2 '^<h1' "$source_full"|grep 'class="rowhead"'| \
        sed -E 's/.*">//;s%</.*>%%g')"
      start_line=$(sed -n '/codetop/=' "$source_full"|head -1)
      end_line=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -1) # 第一个

    elif [ "$source_site_URL" = "https://hdcmct.org" ]; then
      extra_subt="$(grep -E "download.php\?id=[0-9]+\">\[CMCT\]" "$source_full"| \
        sed -E 's/.*">//;s%</.*>%%g;s/\[//g;s/\]//g')"
      start_line=$(sed -n '/资料参数/=;/参数信息/=;/General Information/=' "$source_full"|head -1)
      end_line=$(sed -n '/下载信息/=;/郑重声明/=' "$source_full"|head -1) # 第一个

    fi
    # 裁剪简介获取 iNFO 以及 screens
    if [[ $start_line && $end_line && $start_line -lt $end_line ]]; then
      sed -n "${start_line},${end_line}p" "$source_full" > "$source_desc"
    else
      debug_func "get_desc:start-l-[$start_line]end-l-[$end_line]"  #----debug---
    fi
    unset start_line end_line middle_line
    #----------------desc----------------start
    if [ -s "$source_desc" ]; then
    #---filter html code---#
    sed -i "s/.*id='kdescr'>//g;s/onclick=\"Previewurl([^)]*)[;]*\"//g;s/onload=\"Scale([^)]*)[;]*\"//g;s/onmouseover=\"[^\"]*;\"//g" "$source_desc"
    sed -i "s#onclick=\"Previewurl.*/><br />#/><br />#g" "$source_desc"
    sed -i "/本资源仅限/d;/法律责任/d" "$source_desc"
    sed -Ei "s@\"[^\"]*attachments([^\"]+)@\"${source_site_URL}/attachments\1@ig;s#src=\"attachments#src=\"${source_site_URL}/attachments#ig" "$source_desc"
    sed -i "s#onmouseover=\"[^\"]*[;]*\"##ig" "$source_desc"
    sed -i "s#onload=\"[^\"]*[;]*\"##ig" "$source_desc"
    sed -i "s#onclick=\"[^\"]*[;)]*\"##ig" "$source_desc"
    #---ttg,table---#
    sed -Ei "/^x264.*<\/table>/ s!</table>.*!</table>\n!ig" "$source_desc"
 
    #---copy as a duplication for byrbt---#
    [ "$enable_byrbt" = 'yes' ] && \cp -f "$source_desc" "$source_html"
    sed -Ei 's/fieldset>|legend>/span>/ig;s/ ?引用 ?//g' "$source_html"

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

