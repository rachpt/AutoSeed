#!/bin/bash
# FileName: get_desc/generate.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-03-14
#
#-------------------------------------#
# 本文件通过豆瓣或者IMDB链接(如果都没有则使用资源0day名)，
# 首先通过 @Rhilip 提供的API获得简介，失败则通过 python
# 本地生成豆瓣简介(需要设置允许)。
#-------------------------------------#

# 通过 豆瓣 API 搜索资源豆瓣ID，用于后续简介获取
get_douban_url_by_keywords() {
  # function
  search_doubanurl() {
  local name season year num
  # 剧集季数
  season="$(echo "$1"|grep -Eio '[ \.]s0?(10|20|[1-9]+).?(ep?[0-9]+)?[ \.]')"
  [[ $season ]] && season="$(echo "$season"|sed -E \
    's/s0?(10|20|[1-9]+).?(ep?[0-9]+)?[ \.]/Season.\1/i')"
  # 年份
  year="$(echo "$1"|grep -Eo '[12][098][0-9]{2}'|tail -1)"
  num="$(echo "$1"|grep -Eo '[12][098][0-9]{2}'|wc -l)" # 统计year个数
  # 删除分辨率
  name="$(echo "$1"|sed -E 's/(1080[pi]|720p|4k|2160p).*//i')"
  # 删除介质
  name="$(echo "$name"|sed -E 's/(hdtv|blu-?ray|web-?dl|bdrip|dvdrip|webrip).*//i')"
  # 删除季数
  name="$(echo "$name"|sed -E 's/[ \.]s0?(10|20|[1-9]+).?(ep?[0-9]+)?[ \.].*//i')"
  name="$(echo "$name"|sed -E 's/[ \.]ep?[0-9]{1,2}(-e?p?[0-9]{1,2})?[ \.].*//i')"
  # 删除合集
  name="$(echo "$name"|sed -E 's/[ \.]Complete[\. ].*//i')"
  # 删除年份
  [[ $num -ge 1 ]] && name="$(echo "$name"|sed -E 's/[ \.][12][098][0-9]{2}[ \.]/./g')"
  # 删除连续点和空格
  name="$(echo "$name"|sed -E 's/[ \.]+/./g')"
  # 搜索
  search_url="$(http --verify=no --pretty=format --ignore-stdin --timeout=25 \
    -b GET 'https://api.douban.com/v2/movie/search' q=="${name}${season}.${year}" \
   "$user_agent"|grep -E '(movie.)?douban.com/subject/'|head -1|awk -F '"' '{print $4}')"
  # 去掉可能不准确的年份再试
  [[ "$search_url" ]] || \
   search_url="$(http --verify=no --pretty=format --ignore-stdin --timeout=25 \
   -b GET 'https://api.douban.com/v2/movie/search' q=="${name}${season}" \
   "$user_agent"|grep -E '(movie.)?douban.com/subject/'|head -1|awk -F '"' '{print $4}')"
  debug_func "豆瓣关键词:[${name}|${season}|.${year}]"  #----debug---
  }
  # the first time try
  search_doubanurl "$org_tr_name"
  [[  $search_url ]] || sleep 3 && search_doubanurl "$dot_name" # try again
  # 写入日志
  [[ "$search_url" ]] && echo "搜索得到豆瓣链接：$search_url" >> "$log_Path" || \
    echo '未搜索到豆瓣链接！！！'   >> "$log_Path"
  unset -f search_doubanurl
}

poster_to_bbcode() {
  # 参数，海报列表
  local _one_url _the_rest _line
  local _url_lists="$1"
  _line=$(expr $RANDOM % $(echo "$_url_lists"|wc -l) + 1)  # 随机海报
  [[ $_line ]] || _line=1   # default
  _one_url="$(echo "$_url_lists"|sed -n "$_line p")"
  gen_desc_bbcode="$(echo "$gen_desc_bbcode"|sed "s%$douban_poster_url%$_one_url%")"
  _the_rest="$(echo "$_url_lists"|sed "/$_one_url/d")"
  [[ $_the_rest ]] && {
   _the_rest="$(echo "$_the_rest"|sed "1i 其他海报:")"
   _the_rest="$(echo $_the_rest|sed "s/ /\\n/g")"  # 转化为\n分割的一行
   gen_desc_bbcode="$(echo "$gen_desc_bbcode"|sed "/\[img\]/a $_the_rest")"
  }
  debug_func "gen-other-poster-url:[$_one_url]"    #----debug---
}

mtime_poster() {
  # 获取时光网海报
  local mtime_id mtime_lists mt_url_one _the_rest
  mtime_id="$(http --ignore-stdin --timeout=26 GET \
    'http://service-channel.mtime.com/Search.api' Ajax_CallBack==true \
    Ajax_CallBackType=='Mtime.Channel.Services' Ajax_CallBackMethod==GetSuggestObjs \
    Ajax_CallBackArgument0=="$chs_name_douban"|sed -E 's/(,|:\[\{)/\n/g'|grep -B3 \
    "\"$chs_name_douban\""|grep -E 'id.*[0-9]+'|grep -Eo '[0-9]+'|head -1)"
  if [[ $mtime_id ]]; then
    mtime_lists="$(http --ignore-stdin --timeout=26 GET \
      "http://movie.mtime.com/$mtime_id/posters_and_images/posters/hot.html"|grep '海报'| \
      grep -Eo "http://img[0-9]+\.mtime\.cn/pi/u/[/0-9\._]+X[0-9]+\.(jpg|jpeg|png|gif)")"
    if [[ $mtime_lists ]]; then
      poster_to_bbcode "$mtime_lists"
    else
      debug_func 'gen-mtime-poster-url:[failed!]'    #----debug---
    fi
  else
    debug_func 'gen-mtime:[failed-to-find-id!]'      #----debug---
  fi
}

m1905_poster() {
  # 获取m1905 网海报
  local m1905_lists m_url_one the_rest
  m1905_lists="$(http --pretty=format --ignore-stdin --timeout=26 GET \
    "http://www.1905.com/search/?q=$chs_name_douban"|grep "alt=.$chs_name_douban"| \
    grep -E -o "http://image[0-9]+.m1905.com[^\"\']+\.(jpg|jpeg|png|gif)"| \
    sed -E 's/thumb_[0-9]_[0-9]{2,3}_[0-9]{2,3}_//')"
  if [[ $m1905_lists ]]; then
    poster_to_bbcode "$m1905_lists"
  else
    debug_func 'gen-m1905-poster-url:[failed!] || trying-mtime...'  #----debug---
    mtime_poster
  fi
}
#-------------------------------------#
from_douban_get_desc() {
    # 获取搜索链接
    [[ $douban_url ]] || douban_url="$(grep -Eio \
      'https?://(www\.|movie\.)?douban\.com/subject/[0-9]{7,8}/?' "$source_desc"|head -1)"
    [[ $imdb_url ]] || imdb_url="$(grep -Eio 'tt[0-9]{7}' "$source_desc"|head -1)"
    if [[ "$douban_url" ]]; then
        search_url="$douban_url"
    elif [[ "$imdb_url" ]]; then
        if [[ $dot_name =~ .*\.[Ss](0?[2-9]|[1-9]?[0-9])\..*WiKi ]]; then
          debug_func 'gen-wiki-series!...'  #----debug---
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
            head -1|awk -F '"' '{print $4}'|sed 's/img3/img1/')"
        # 中文名
        chs_name_douban="$(echo "$desc_json_info"|grep 'chinese_title'| \
            head -1|awk -F '"' '{print $4}')"
        # 英文名
        eng_name_douban="$(echo "$desc_json_info"|grep 'foreign_title'| \
            head -1|awk -F '"' '{print $4}')"
        m1905_poster

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
source_desc_tmp="&my_extra_comment&
&shc_name_douban&${chs_name_douban}
&eng_name_douban&${eng_name_douban}
${gen_desc_bbcode}

[quote=iNFO][font=monospace]
$([[ -s $source_desc ]] && cat "$source_desc" || echo 'Failed to get mediainfo!')
[/font][/quote]
$(if [ $source_t_id ]; then
    echo -e "\n[quote=转载来源][b]本种来自：[/b] ${source_site_URL}/details.php?id=${source_t_id}[/quote]"
else
    echo -e "\n[quote=转载来源][b]本种来自：[/b] ${source_site_URL}[/quote]"
fi )
"

    # byrbt 所需要的 html 简介
[[ $enable_byrbt = yes ]] && source_html_tmp="${gen_desc_html}<br /><br /><br />
<fieldset><legend><span style=\"color:#ffffff;background-color:#000000;\">iNFO</span></legend><font face=\"Courier New\">
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
    [[ $enable_byrbt = yes ]] && echo "$source_html_tmp" > "$source_html"
    # 清空变量，防止不同种子简介互串
    unset source_desc_tmp  source_html_tmp  source_t_id
    unset chs_name_douban  eng_name_douban  douban_poster_url
}

#-------------------------------------#

