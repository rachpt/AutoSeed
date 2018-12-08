#!/bin/bash
# FileName: get_desc/detail_page.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-08
#
#-------------------------------------#
# 通过搜索原种站点(依据torrent文件中的tracker信息)，
# 只有预定义的站点才有效。
# 获得的原种简介仅筛选 iNFO 以及 screens 保留到临时文件
# source_desc[html 用于 byrbt]，
# 后续合并通过豆瓣生成的简介。
#-------------------------------------#

get_source_site() {
    local tracker_info="$($tr_show "$torrent_Path"|grep -A5 'TRACKERS')"
    # 获取种子原站点
    if [ "$(echo $tracker_info|grep -i 'hdsky')" ]; then
        source_site_URL='https://hdsky.me'
        cookie_source_site="$cookie_hds"
        echo "got source_site: hdsky" >> "$log_Path"
    elif [ "$(echo $tracker_info|grep -i 'totheglory')" ]; then
        source_site_URL='https://totheglory.im'
        cookie_source_site="$cookie_ttg"
        echo "got source_site: ttg" >> "$log_Path"
    elif [ "$(echo $tracker_info|grep -i 'hdchina')" ]; then
        source_site_URL='https://hdchina.org'
        cookie_source_site="$cookie_hdc"
        echo "got source_site: hdchina" >> "$log_Path"
    elif [ "$(echo $tracker_info|grep -i 'tp.m-team.cc')" ]; then
        source_site_URL='https://tp.m-team.cc'
        cookie_source_site="$cookie_mt"
        echo "got source_site :mteam" >> "$log_Path"
    elif [ "$(echo $tracker_info|grep -i 'hdcmct.org')" ]; then
        source_site_URL='https://hdcmct.org'
        cookie_source_site="$cookie_cmct"
        echo "got source_site: hdcmct" >> "$log_Path"
        #elif [ "$(echo $tracker_info|grep -i 'new')" ]; then
    #    source_site_URL='https://new.tracker.org'
    else
        unknown_site="$(echo "$tracker_info"|grep -Eo 'https?://[^/]*'| \
            head -1|sed 's/tracker\.//')"
    fi
}
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
    # 构造原种搜索链接，以获取原种ID
    if [ "$source_site_URL" = "https://totheglory.im" ]; then
        local s_search_URL="${source_site_URL}/browse.php?c=M&search_field=${dot_name}"
    else
        # sed 用于过滤文件后缀
        local s_search_URL="${source_site_URL}/torrents.php?search=${dot_name}"
    fi

    source_t_id="$(http --verify=no -b --ignore-stdin --timeout=25 GET \
        "$s_search_URL" "$cookie_source_site" "$user_agent"| \
        grep -Eo "id=[0-9]+[^\"]*hit=1"|head -1|grep -Eo '[0-9]{4,}')"

    #---deal with wrong year---#
    if [ ! "$source_t_id" ]; then
        local source_site_search_URL="$(echo "$source_site_search_URL"| \
            sed "s/[12][0789][0-9][0-9]//g")"
        source_t_id="$(http --verify=no -b --ignore-stdin --timeout=25 GET \
            "$s_search_URL" "$cookie_source_site" "$user_agent"| \
            grep -Eo "id=[0-9]+[^\"]*hit=1"|head -1|grep -Eo '[0-9]{4,}')"
    fi
else
    # 用于简介
    source_site_URL="$unknown_site"
    unset unknown_site
fi
}

#-------------------------------------#
form_source_site_get_Desc() {
  form_source_site_get_tID
  # source_t_id will be unset in generate.sh
  if [ "$source_t_id" ]; then
    #---define temp file name---#
    source_full="${ROOT_PATH}/tmp/${org_tr_name}_full.txt"
    http -b --verify=no --ignore-stdin --timeout=25 GET \
        "${source_site_URL}/details.php?id=${source_t_id}" \
        "$cookie_source_site" "$user_agent"> "$source_full"
  #---desc-full--
  if [ -s "$source_full" ]; then
    # imdb 和豆瓣链接,用于生成简介
    imdb_url="$(grep -Eo 'tt[0-9]{7}' "$source_full"|head -1)"
    douban_url="$(grep -Eo 'https?://(movie\.)?douban\.com/subject/[0-9]{7,8}/?' "$source_full"|head -1)"
    [ "$(grep -E '禁止转载|禁转资源|谢绝转发|独占资源|禁转资源|No forward anywhere' "$source_full")" ] && local forbid='yes'

    # 匹配官方组 简介中的 info 以及 screens 所在行号
    if [ "$source_site_URL" = "https://hdsky.me" ]; then
      local start_line=$(sed -n '/影片参数/=' "$source_full"|head -1)
      local end_line=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -1) # 第一个

    elif [ "$source_site_URL" = "https://hdchina.org" ]; then
      local start_line=$(sed -n '/<fieldset><legend>/=' "$source_full"|tail -1)
      local end_line=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -2|tail -1) # 第二个

    elif [ "$source_site_URL" = "https://totheglory.im" ]; then
      local start_line=$(sed -n '/.[cC]omparisons/=' "$source_full"|head -1)
      local middle_line=$(sed -n '/.x264.[iI]nfo/=' "$source_full"|head -1)
      local end_line=$(sed -n "$middle_line,$(expr $middle_line + 10)p" \
          "$source_full"|sed -n '/<\/table>/='|head -1) # ttg
      local end_line=$(expr $middle_line + $end_line - 1) # ttg

    elif [ "$source_site_URL" = "https://tp.m-team.cc" ]; then
      local start_line=$(sed -n '/codetop/=' "$source_full"|head -1)
      local end_line=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -1) # 第一个

    elif [ "$source_site_URL" = "https://hdcmct.org" ]; then
      local start_line=$(sed -n '/资料参数/=;/参数信息/=;/General Information/=' "$source_full"|head -1)
      local end_line=$(sed -n '/下载信息/=;/郑重声明/=' "$source_full"|head -1) # 第一个

    fi
    # 裁剪简介获取 iNFO 以及 screens
    if [[ $start_line && $end_line && $start_line -lt $end_line ]]; then
      sed -n "${start_line},${end_line}p" "$source_full" > "$source_desc"
    else
      echo -e "start line: $start_line\nend line: $end_line" >> "$debug_Log"
    fi
    unset start_line end_line middle_line
    #----------------desc----------------
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
    [ "$enable_byrbt" = 'yes' ] && cp -f "$source_desc" "$source_html"

    #---html2bbcode---#
    source "$ROOT_PATH/get_desc/html2bbcode.sh"
    [[ $forbid = yes ]] && echo -e "\n&禁止转载&\n"     >> "$source_desc"
    #----------------desc----------------
    else
      echo 'failed to gen desc from source'             >> "$debug_Log"
    fi
    #----------------desc----------------
    
    #sleep 99999999999
    unset forbid
    rm -f "$source_full"
    unset source_full
  fi
  #---desc-full--
  fi
}

#-------------------------------------#

