#!/bin/bash
# FileName: get_desc/generate.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-10-23
#
#-------------------------------------#
# 本文件通过豆瓣或者IMDB链接(如果都没有则使用资源0day名)，
# 首先通过 @Rhilip 提供的API获得简介，失败则通过 python
# 本地生成豆瓣简介(需要设置允许)。
#-------------------------------------#

# 通过 豆瓣 API 搜索资源豆瓣ID，用于后续简介获取
search_keyword_get_douban_url() {
    if [ "$dot_name" != "$(echo "$dot_name"|egrep -o '.*[12][098][0-9]{2}')" ]; then
        base_movie_name_search="$(echo "$dot_name"|egrep -o '.*[12][098][0-9]{2}')"
    elif [ "$dot_name" != "$(echo "$dot_name"|sed -r 's/(.*)\.(S[0-9]+)?([-]?Ep?[0-9]+)?\..*/\1/i')" ]; then
        # 剧集单集
        base_movie_name_search="$(echo "$dot_name"|sed -r 's/(.*)\.(S[0-9]+)?([-]?Ep?[0-9]+)?\..*/\1/i')"
    elif [ "$dot_name" != "$(echo "$dot_name"|sed -r 's/(.*)\.([-sEp0-9]+)\..*/\1/i')" ]; then
        # 剧集单集,可能误判
        base_movie_name_search="$(echo "$dot_name"|sed -r 's/(.*)\.([-sEp0-9]+)\..*/\1/i')"
    elif [ "$dot_name" != "$(echo "$dot_name"|sed -r 's/(.*)\.Complete\..*/\1/i')" ]; then
        # 剧集合集
        base_movie_name_search="$(echo "$dot_name"|sed -r 's/(.*)\.Complete\..*/\1/i')"
    else
        base_movie_name_search="$(echo "$dot_name"|sed -r 's/(.*)\.BluRay\..*/\1/i;s/(.*)\.hdtv\..*/\1/i;s/(.*)\.web-?dl\..*/\1/i;')"
    fi

    search_get_douban_url="$(http -b --pretty=format --ignore-stdin GET "https://api.douban.com/v2/movie/search?q=${base_movie_name_search}"|grep 'movie.douban.com/subject'|head -1|awk -F '"' '{print $4}')"
    # 写入日志
    if [ "$search_get_douban_url" ]; then
        search_desc_url="$search_get_douban_url"
        echo "搜索得到豆瓣链接：$search_get_douban_url" >> "$log_Path"
    else
        echo '未搜索到豆瓣链接！！！' >> "$log_Path"
    fi
}

from_douban_get_desc() {
    # 获取搜索链接
    if [ "$imdb_url" ]; then
        search_desc_url="http://www.imdb.com/title/$imdb_url"
    elif [ "$douban_url" ]; then
        search_desc_url="$douban_url"
    else
        search_keyword_get_douban_url
    fi
    # 使用 API 或者 python 本地解析豆瓣简介
    if [ "$search_desc_url" ]; then
        desc_json_info="$(http --pretty=format --ignore-stdin GET "https://api.rhilip.info/tool/movieinfo/gen?url=${search_desc_url}")"
        success_get_json_info="$(echo "$desc_json_info"|grep '"success": true')"
        if [ ! "$success_get_json_info" ] && [ "$Use_Local_Gen" = 'yes' ]; then
            desc_json_info="$("$python3" -c "import sys;sys.path.append(\"${AUTO_ROOT_PATH}/get_desc/\");from gen import Gen;import json;gen=Gen(\"${search_desc_url}\").gen(_debug=True);print(json.dumps(gen,sort_keys=True,indent=2,separators=(',',':'),ensure_ascii=False))")"
        fi

        gen_desc_bbcode="$(echo "$desc_json_info"|grep 'format'|awk -F '"' '{print $4}'|sed 's#\\n#\n#g'|sed '/img/d')"

        douban_poster_url="$(echo "$desc_json_info"|grep '"poster":'|head -1|awk -F '"' '{print $4}')"
        # 中文名
        chs_name_douban="$(echo "$desc_json_info"|grep 'chinese_title'|head -1|awk -F '"' '{print $4}')"
        # 英文名
        eng_name_douban="$(echo "$desc_json_info"|grep 'foreign_title'|head -1|awk -F '"' '{print $4}')"

        [ "$enable_byrbt" = 'yes' ] && gen_desc_html="$(echo "$gen_desc_bbcode"|sed 's#$#&<br />#g')" # byrbt
    fi
}

# 豆瓣海报上传至图床
poster_up_to_sm_and_byr() {
    if [ "$douban_poster_url" ]; then
        local tmp_poster_file="$AUTO_ROOT_PATH/tmp/autoseed-$(echo $RANDOM)-$(echo $RANDOM)-${douban_poster_url##*/}"
        http --ignore-stdin -dco "$tmp_poster_file" "$douban_poster_url" # download poster
        new_poster_url="$(http --ignore-stdin -f POST "$upload_poster_api" smfile@"$tmp_poster_file"|egrep -o "\"url\":\"[^\"]+\""|awk -F "\"" '{print $4}'|sed 's/\\//g')" # sm.ms
        [ "$enable_byrbt" = 'yes' ] && new_poster_url_byrbt="$(http -b --ignore-stdin -f POST "$upload_poster_api_byrbt" upload@"$tmp_poster_file" "$cookie_byrbt"|awk -F ',' '{print $2}'|sed -r "s#.*https?://#https://#;s/'[ ]*$//")"  # byrbt

        rm -f "$tmp_poster_file"
    fi
}

# 拼接简介
generate_main_func() {
    from_douban_get_desc

    poster_up_to_sm_and_byr
    # bbcode
    source_detail_desc_tmp="$(echo -e "[img]${new_poster_url}[/img]\n${gen_desc_bbcode}\n")
    $(cat "$source_detail_desc")
    $(if [ $source_t_id ]; then
        echo -e "\n[quote][b]本种来自：[/b] ${source_site_URL}/details.php?id=${source_t_id}[/quote]"
    else
        echo -e "\n[quote][b]本种来自：[/b] ${source_site_URL}[/quote]"
    fi
    )$(echo -e "\n&chs_name_douban&${chs_name_douban}\n&eng_name_douban&${eng_name_douban}\n")"

    # byrbt 所需要的 html 简介
    [ "$enable_byrbt" = 'yes' ] && source_detail_html_tmp="$(echo -e "<img src=\"${new_poster_url_byrbt}\" /><br />\n${gen_desc_html}<br />\n\n")
    $(cat "$source_detail_html")
    $(echo -e "\n<br /><br /><br /><fieldset><br />\n")
    $(if [ $source_t_id ]; then
        echo '<span style="font-size:20px;">本种来自： '${source_site_URL}/details.php?id=${source_t_id}'</span>'
    else
        echo '<span style="font-size:20px;">本种来自： '${source_site_URL}'</span>'
    fi
    )$(echo -e "\n<br /></fieldset><br /><br />\n")"
    # 简介保存至文件 
    echo "$source_detail_desc_tmp" > "$source_detail_desc"
    echo "$source_detail_html_tmp" > "$source_detail_html"
    # 清空变量，防止不同种子简介互串
    unset source_detail_desc_tmp  source_detail_html_tmp  source_t_id
    unset chs_name_douban  eng_name_douban  douban_poster_url
}

#-------------------------------------#

