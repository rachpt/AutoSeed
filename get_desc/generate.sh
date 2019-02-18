#!/bin/bash
# FileName: get_desc/generate.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-02-18
#
#-------------------------------------#
# 本文件通过豆瓣或者IMDB链接(如果都没有则使用资源0day名)，
# 首先通过 @Rhilip 提供的API获得简介，失败则通过 python
# 本地生成豆瓣简介(需要设置允许)。
#-------------------------------------#

# 通过 豆瓣 API 搜索资源豆瓣ID，用于后续简介获取
get_douban_url_by_keywords() {
  local get_douban_url
  search_doubanurl() {
  local name season year
  # 剧集季数
  season="$(echo "$1"|sed -E 's/.*[ \.]s([012]?[1-9])(ep?[0-9]+)?[ \.].*/.Season.\1./i;s/[ \.]0([1-9])[ \.]/.\1/')"
  # 年份
  year="$(echo "$1"|grep -Eo '[12][098][0-9]{2}')"
  # 分辨率
  name="$(echo "$1"|sed -E 's/(1080[pi]|720p|4k|2160p).*//i')"
  # 介质
  name="$(echo "$name"|sed -E 's/(hdtv|blu-?ray|web-?dl|bdrip|dvdrip|webrip).*//i')"
  # 删除季数
  name="$(echo "$name"|sed -E 's/[ \.]s([012]?[1-9])(ep?[0-9]+)?[ \.].*//i')"
  name="$(echo "$name"|sed -E 's/[ \.]ep?[0-9]{1,2}(-e?p?[0-9]{1,2})?[ \.].*//i')"
  # 删除合集
  name="$(echo "$name"|sed -E 's/[ \.]Complete[\. ].*//i')"
  # 搜索
  get_douban_url="$(http -b --verify=no --pretty=format --ignore-stdin \
   --timeout=25 GET 'https://api.douban.com/v2/movie/search' q=="${name}${season}.${year}" \
   "$user_agent"|grep -E '(movie.)?douban.com/subject/'|head -1|awk -F '"' '{print $4}')"
  # 去掉可能不准确的年份
  [[ ! $get_douban_url ]] && \
   get_douban_url="$(http -b --verify=no --pretty=format --ignore-stdin \
   --timeout=25 GET 'https://api.douban.com/v2/movie/search' q=="${name}${season}" \
   "$user_agent"|grep -E '(movie.)?douban.com/subject/'|head -1|awk -F '"' '{print $4}')"
  debug_func "generate:[${name}${season}.${year}]"  #----debug---
  }

  search_doubanurl "$org_tr_name"
  [[ ! $get_douban_url ]] && sleep 2 && search_doubanurl "$dot_name"
  # 写入日志
  if [ "$get_douban_url" ]; then
      search_url="$get_douban_url"
      echo "搜索得到豆瓣链接：$get_douban_url"        >> "$log_Path"
  else
      echo '未搜索到豆瓣链接！！！'                   >> "$log_Path"
      unset search_url
  fi
  unset -f search_doubanurl
}

#-------------------------------------#
from_douban_get_desc() {
    # 获取搜索链接
    if [ "$douban_url" ]; then
        search_url="$douban_url"
    elif [ "$imdb_url" ]; then
        if [[ $dot_name =~ .*\.[Ss](0?[2-9]|[1-9]?[0-9])\..*WiKi ]]; then
          get_douban_url_by_keywords  # WiKi series
        else
          search_url="http://www.imdb.com/title/$imdb_url"
        fi
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
            sed "1c <img src=\"$douban_poster_url\" />"|sed 's!$!&<br />!g')" # byrbt

        unset search_url
    fi
}

#-------------------------------------#
# 拼接简介
generate_main_func() {
    from_douban_get_desc

    # bbcode
source_desc_tmp="${gen_desc_bbcode}

[quote=iNFO][font=monospace]
$([[ -s $source_desc ]] && cat "$source_desc" || echo 'Failed to get mediainfo!')
[/font][/quote]
$(if [ $source_t_id ]; then
    echo -e "\n[quote=转载来源][b]本种来自：[/b] ${source_site_URL}/details.php?id=${source_t_id}[/quote]"
else
    echo -e "\n[quote=转载来源][b]本种来自：[/b] ${source_site_URL}[/quote]"
fi )
&shc_name_douban&${chs_name_douban}
&eng_name_douban&${eng_name_douban}
"

    # byrbt 所需要的 html 简介
[[ $enable_byrbt = yes ]] && source_html_tmp="${gen_desc_html}<br /><br />
<br /><fieldset><font face=\"Courier New\"><legend>
<span style=\"color:#ffffff;background-color:#000000;\">iNFO</span></legend>
$([[ -s $source_desc ]] && cat "$source_html" || echo 'Failed to get mediainfo!')
</font></fieldset><br /><br /><br /><br /><br /><fieldset><legend>
<span style=\"color:#ffffff;background-color:#000000;\">转载来源</span></legend>
$(if [ $source_t_id ]; then
    echo '<span style="font-size:20px;">本种来自： '${source_site_URL}/details.php?id=${source_t_id}'</span>'
else
    echo '<span style="font-size:20px;">本种来自： '${source_site_URL}'</span>'
fi)
<br /></fieldset><br />"

    # 简介覆盖保存至文件 
    echo "$source_desc_tmp" > "$source_desc"
    echo "$source_html_tmp" > "$source_html"
    # 清空变量，防止不同种子简介互串
    unset source_desc_tmp  source_html_tmp  source_t_id
    unset chs_name_douban  eng_name_douban  douban_poster_url
}

#-------------------------------------#

