#!/bin/bash
# FileName: get_desc/detail_page.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-10-20
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

    source_t_id="$(http --verify=no -b --ignore-stdin --timeout=10 GET \
        "$s_search_URL" "$cookie_source_site"| \
        grep -Eo 'id=[0-9]+.*hit=1'|head -1|grep -Eo '[0-9]{4,}')"

    #---deal with wrong year---#
    if [ ! "$source_t_id" ]; then
        local source_site_search_URL="$(echo "$source_site_search_URL"| \
            sed "s/[12][0789][0-9][0-9]//g")"
        source_t_id="$(http --verify=no -b --ignore-stdin --timeout=10 GET \
            "$s_search_URL" "$cookie_source_site"| \
            grep -Eo 'id=[0-9]+.*hit=1'|head -1|grep -Eo '[0-9]{4,}')"
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
        http -b --verify=no --ignore-stdin --timeout=10 GET \
            "${source_site_URL}/details.php?id=${source_t_id}" \
            "$cookie_source_site" > "$source_full"
    #---
    if [ -s "$source_full" ]; then
        # imdb 和豆瓣链接
        imdb_url="$(grep -Eo 'tt[0-9]{7}' "$source_full"|head -1)"
        douban_url="$(grep -Eo 'https?://movie\.douban\.com/subject/[0-9]{8}/?' "$source_full"|head -1)"
        [ "$(grep -E '禁止转载|禁转资源|谢绝转发|独占资源' "$source_desc")" ] && local prohibit_upload=1

        # 匹配官方组 简介中的 info 以及 screens 所在行号
        if [ "$source_site_URL" = "https://hdsky.me" ]; then
            local source_start_line_html=$(sed -n '/影片参数/=' "$source_full"|head -1|)
            local source_end_line_html=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -1) # 第一个

        elif [ "$source_site_URL" = "https://hdchina.org" ]; then
            local source_start_line_html=$(sed -n '<fieldset><legend>' "$source_full"|tail -1|)
            local source_end_line_html=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -2|tail -1) # 第二个

        elif [ "$source_site_URL" = "https://totheglory.im" ] || [ "$source_site_URL" = "https://tp.m-team.cc" ]; then
            local source_start_line_html=$(sed -n '/.[cC]omparisons/=' "$source_full"|head -1|)
            local source_temp_line=$(sed -n '/.x264.[iI]nfo/=' "$source_full"|head -1|)
            local source_end_line_html=$(sed -n "$source_tmp_line,$(expr $source_end_line_html + 10)p" "$source_full|"sed -n '<\/table><br><br \/>/='|head -1) # ttg

        elif [ "$source_site_URL" = "https://tp.m-team.cc" ]; then
            local source_start_line_html=$(sed -n 'codetop' "$source_full"|head -1|)
            local source_end_line_html=$(sed -n '/<\/div><\/td><\/tr>$/=' "$source_full"|head -1) # 第一个

        elif [ "$source_site_URL" = "https://hdcmct.org" ]; then
            local source_start_line_html=$(sed -n '/参数信息/=' "$source_full"|head -1|)
            local source_end_line_html=$(sed -n '/下载信息/=' "$source_full"|head -1) # 第一个

        fi
        # 裁剪简介获取 iNFO 以及 screens
        if [ "$source_start_line_html" ] && [[ $source_start_line_html -lt $source_end_line_html ]]; then
            sed -n "${source_start_line_html},${source_end_line_html}p" "$source_full" > "$source_desc"
        fi
        unset source_start_line_html source_end_line_html
        #---filter html code---#
        sed -i "s/.*id='kdescr'>//g;s/onclick=\"Previewurl([^)]*)[;]*\"//g;s/onload=\"Scale([^)]*)[;]*\"//g;s/onmouseover=\"[^\"]*;\"//g" "$source_desc"
        sed -i "s#onclick=\"Previewurl.*/><br />#/><br />#g" "$source_desc"
        sed -i "/本资源仅限会员测试带宽之用，严禁用于商业用途！/d; /对用于商业用途所产生的法律责任，由使用者自负！/d" "$source_desc"
        sed -Ei "s@\"[^\"]*attachments([^\"]+)@\"${source_site_URL}/attachments\1@ig;s#src=\"attachments#src=\"${source_site_URL}/attachments#ig" "$source_desc"
        sed -i "s#onmouseover=\"[^\"]*[;]*\"##ig" "$source_desc"
        sed -i "s#onload=\"[^\"]*[;]*\"##ig" "$source_desc"
        sed -i "s#onclick=\"[^\"]*[;)]*\"##ig" "$source_desc"
        
        #---copy as a duplication for byrbt---#
        [ "$enable_byrbt" = 'yes' ] && cp -f "$source_desc" "$source_html"

        #---html2bbcode---#
	      source "$ROOT_PATH/get_desc/html2bbcode.sh"
        [ "$prohibit_upload" -eq 1 ] && echo -e "\n&禁止转载&\n" >> "$source_desc"
        unset prohibit_upload
        rm -f "$source_full"
        unset source_full
    fi
    #---
    fi
}

#-------------------------------------#

