#!/bin/bash
# FileName: get_desc/generate_desc.sh
#
# Author: rachpt@126.com
# Version: 2.4v
# Date: 2018-10-18
#
#-------------------------------------#
#
search_keyword_get_douban_url()
{
    base_movie_name_search="$(echo "$dot_name" |egrep -o '.*[12][098][0-9]{2}')"
    search_get_douban_url="$(http --pretty=format --ignore-stdin GET "https://api.douban.com/v2/movie/search?q=${base_movie_name_search}"|grep 'movie.douban.com/subject'|head -n 1|awk -F '"' '{print $4}')"

    if [ "$search_get_douban_url" ]; then
        search_desc_url="$search_get_douban_url"
        echo "搜索得到豆瓣链接：$search_get_douban_url" >> "$log_Path"
    else
        echo '未搜索到豆瓣链接！' >> "$log_Path"
    fi
}

from_douban_get_desc()
{
    if [ "$imdbUrl" ]; then
        search_desc_url="http://www.imdb.com/title/$imdbUrl"
    elif [ "$doubanUrl" ]; then
        search_desc_url="$doubabUrl"
    else
        search_keyword_get_douban_url
    fi

    if [ "$USE_Local_Gen" = 'yes' ]; then
        desc_json_info="$("$python3" -c "import sys;sys.path.append(\"${AUTO_ROOT_PATH}/get_desc/\");from gen import Gen;import json;gen=Gen(\"${search_desc_url}\").gen(_debug=True);print(json.dumps(gen,sort_keys=True,indent=2,separators=(',',':'),ensure_ascii=False))")"
    else
        desc_json_info="$(http --pretty=format --ignore-stdin GET "https://api.rhilip.info/tool/movieinfo/gen?url=${search_desc_url}")"
    fi

    gen_desc_bbcode="$(echo "$desc_json_info"|grep 'format'|awk -F '"' '{print $4}'|sed 's#\\n#\n#g'|sed '/img/d')"

    douban_poster_url="$(echo "$desc_json_info"|grep '"poster":'|head -n 1|awk -F '"' '{print $4}')"
    if [ ! "$doubanUrl" ]; then
        doubanUrl="$(echo "$desc_json_info"|grep 'douban_link'|head -n 1|awk -F '"' '{print $4}')"
    fi
    chs_name_douban="$(echo "$desc_json_info"|grep 'chinese_title'|head -n 1|awk -F '"' '{print $4}')"

    gen_desc_html="$(echo "$gen_desc_bbcode"|sed 's#$#&<br />#g')"
}

poster_up_to_sm_and_byr()
{
    tmp_poster_file="$AUTO_ROOT_PATH/tmp/$(echo $RANDOM)-$(echo $RANDOM)-${douban_poster_url##*/}"
    http --ignore-stdin -dco "$tmp_poster_file" "$douban_poster_url" 
    new_poster_url="$(http --ignore-stdin -f POST 'https://sm.ms/api/upload' smfile@"$tmp_poster_file"|egrep -o "\"url\":\"[^\"]+\""|awk -F "\"" '{print $4}'|sed 's/\\//g')"
    new_poster_url_byrbt="$(http --ignore-stdin -f POST 'https://bt.byr.cn/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Images' upload@"$tmp_poster_file" "$cookie_byrbt"|egrep -o "http[-a-zA-Z0-9./:()]+images[-a-zA-Z0-9./:(_ )]+[^''\"]*"|sed 's/http:/https:/g')"  # byrbt

    rm -f "$tmp_poster_file"
    tmp_poster_file=''
    douban_poster_url=''
}

generate_main_func()
{
    from_douban_get_desc

    poster_up_to_sm_and_byr

    source_detail_desc_tmp="$(echo -e "[img]${new_poster_url}[/img]\n${gen_desc_bbcode}\n")
    $(cat "$source_detail_desc")
    $(if [ $source_t_id ]; then
        echo -e "\n[quote][b]本种来自：[/b] ${source_site_URL}/details.php?id=${source_t_id}[/quote]"
    else
        echo -e "\n[quote][b]本种来自：[/b] ${source_site_URL}[/quote]"
    fi
    )"

    source_detail_html_tmp="$(echo -e "<img src=\"${new_poster_url_byrbt}\" /><br />\n${gen_desc_html}<br />\n\n")
    $(cat "$source_detail_html")
    $(echo -e "\n<br /><br /><br /><fieldset><br />\n")
    $(if [ $source_t_id ]; then
        echo '<span style="font-size:20px;">本种来自： '${source_site_URL}/details.php?id=${source_t_id}'</span>'
    else
        echo '<span style="font-size:20px;">本种来自： '${source_site_URL}'</span>'
    fi
    )$(echo -e "\n<br /></fieldset><br /><br />\n")"
    
    echo "$source_detail_desc_tmp" > "$source_detail_desc"
    echo "$source_detail_html_tmp" > "$source_detail_html"
    source_detail_desc_tmp=''
    source_detail_html_tmp=''
}

#-------------------------------------#

