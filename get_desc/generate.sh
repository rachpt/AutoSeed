#!/bin/bash
# FileName: get_desc/generate.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-11
#
#-------------------------------------#
# 本文件通过豆瓣或者IMDB链接(如果都没有则使用资源0day名)，
# 首先通过 @Rhilip 提供的API获得简介，失败则通过 python
# 本地生成豆瓣简介(需要设置允许)。
#-------------------------------------#

# 通过 豆瓣 API 搜索资源豆瓣ID，用于后续简介获取
get_douban_url_by_keywords() {
  # 普通电影
  if [ "$(echo "$dot_name"|grep -Eo '[12][0198][0-9]{2}')" ]; then
    local search_name="$(echo "$dot_name"|grep -Eo '.*[12][0198][0-9]{2}')"
  # 剧集单集
  elif [ "$(echo "$dot_name"|sed -r 's/.*\.(S[0-9]+)?([-]?Ep?[0-9]+)?\..*/\1/i')" ]; then
    local search_name="$(echo "$dot_name"|sed -r 's/(.*)\.(S[0-9]+)?([-]?Ep?[0-9]+)?\..*/\1/i')"
  # 剧集单集,可能误判
  elif [ "$(echo "$dot_name"|sed -r 's/.*\.([-sEp0-9]+)\..*/\1/i')" ]; then
    local search_name="$(echo "$dot_name"|sed -r 's/(.*)\.([-sEp0-9]+)\..*/\1/i')"
  # 剧集合集
  elif [ "$(echo "$dot_name"|sed -r 's/(.*)\.Complete\..*/\1/i')" ]; then
    local search_name="$(echo "$dot_name"|sed -r 's/(.*)\.Complete\..*/\1/i')"
  else
    local search_name="$(echo "$dot_name"| \
     sed -r 's/(.*)\.BluRay\..*/\1/i;s/(.*)\.hdtv\..*/\1/i;s/(.*)\.web-?dl\..*/\1/i;')"
  fi

  local get_douban_url="$(http -b --verify=no --pretty=format --ignore-stdin \
   --timeout=15 GET "https://api.douban.com/v2/movie/search?q=${search_name}" \
   "$user_agent"|grep -E '(movie.)?douban.com/subject/'|head -1|awk -F '"' '{print $4}')"
  # 写入日志
  if [ "$get_douban_url" ]; then
      search_url="$get_douban_url"
      echo "搜索得到豆瓣链接：$get_douban_url"        >> "$log_Path"
  else
      echo '未搜索到豆瓣链接！！！'                   >> "$log_Path"
  fi
}

#-------------------------------------#
from_douban_get_desc() {
    # 获取搜索链接
    if [ "$imdb_url" ]; then
        search_url="http://www.imdb.com/title/$imdb_url"
    elif [ "$douban_url" ]; then
        search_url="$douban_url"
    else
        get_douban_url_by_keywords
    fi
    # 使用 API 或者 python 本地解析豆瓣简介
    if [ "$search_url" ]; then
        desc_json_info="$(http --pretty=format --ignore-stdin --timeout=26 GET \
            "https://api.rhilip.info/tool/movieinfo/gen?url=${search_url}")"
        success_get_json_info="$(echo "$desc_json_info"|grep '"success": true')"
        if [ ! "$success_get_json_info" ] && [ "$Use_Local_Gen" = 'yes' ]; then
            desc_json_info="$("$python3" -c  \
"import sys;sys.path.append(\"${ROOT_PATH}/get_desc/\"); \
from gen import Gen;import json;gen=Gen(\"${search_url}\").gen(_debug=True); \
print(json.dumps(gen,sort_keys=True,indent=2,separators=(',',':'),ensure_ascii=False))")"
        fi

        gen_desc_bbcode="$(echo "$desc_json_info"|grep 'format'| \
            awk -F '"' '{print $4}'|sed 's#\\n#\n#g')"

        douban_poster_url="$(echo "$desc_json_info"|grep '"poster":'| \
            head -1|awk -F '"' '{print $4}')"
        # 中文名
        chs_name_douban="$(echo "$desc_json_info"|grep 'chinese_title'| \
            head -1|awk -F '"' '{print $4}')"
        # 英文名
        eng_name_douban="$(echo "$desc_json_info"|grep 'foreign_title'| \
            head -1|awk -F '"' '{print $4}')"

        [[ $enable_byrbt = yes ]] && gen_desc_html="$(echo "$gen_desc_bbcode"| \
            sed "1c <img src=\"$douban_poster_url\" />"|sed 's#$#&<br />#g')" # byrbt

        unset search_url
    fi
}

#-------------------------------------#
# 拼接简介
generate_main_func() {
    from_douban_get_desc

    # bbcode
source_desc_tmp="${gen_desc_bbcode}

[quote][font=monospace]
$(cat "$source_desc")
[/font][/quote]
$(if [ $source_t_id ]; then
    echo -e "\n[quote][b]本种来自：[/b] ${source_site_URL}/details.php?id=${source_t_id}[/quote]"
else
    echo -e "\n[quote][b]本种来自：[/b] ${source_site_URL}[/quote]"
fi )
&shc_name_douban&${chs_name_douban}
&eng_name_douban&${eng_name_douban}
"

    # byrbt 所需要的 html 简介
[[ $enable_byrbt = yes ]] && source_html_tmp="${gen_desc_html}<br /><br />
<fieldset><br /> $(cat "$source_html") </fieldset><br />
$(echo -e "\n<br /><br /><br /><fieldset><br />\n")
$(if [ $source_t_id ]; then
    echo '<span style="font-size:20px;">本种来自： '${source_site_URL}/details.php?id=${source_t_id}'</span>'
else
    echo '<span style="font-size:20px;">本种来自： '${source_site_URL}'</span>'
fi
echo -e "\n<br /></fieldset><br /><br />\n")"

    # 简介覆盖保存至文件 
    echo "$source_desc_tmp" > "$source_desc"
    echo "$source_html_tmp" > "$source_html"
    # 清空变量，防止不同种子简介互串
    unset source_desc_tmp  source_html_tmp  source_t_id
    unset chs_name_douban  eng_name_douban  douban_poster_url
}

#-------------------------------------#

