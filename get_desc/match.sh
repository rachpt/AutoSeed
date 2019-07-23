#!/bin/bash
# FileName: get_desc/match.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-07-22
#
#-------------------------------------#
# 本文件匹配指定文件中的imdb或者豆瓣链接，用于生成简介以及post，
# 支持中文名、英文名，和 # 号注释，
# 调用第一个参数，$dot_name 或者 $org_tr_name，
# 调用第二个参数，series 或则 无，
# series 匹配文件路径 $ROOT_PATH/tmp/series-imdb.txt，
# 其他 匹配文件路径 $ROOT_PATH/tmp/match-lists.txt。
#-------------------------------------#

# 匹配已知英文名，指定豆瓣或者imdb链接，用于剧集以及动漫
match_douban_imdb() {
  local match_list _d i j _name _one_name _url
  if [[ $2 = series ]]; then
      match_list="$ROOT_PATH/tmp/series-imdb.txt"
  else
      match_list="$ROOT_PATH/tmp/match-lists.txt"
  fi
  # 过滤后的数据
  _d="$(sed -E 's/[#＃].*//g;s/[ 　]+//g;/^$/d;s/[A-Z]/\l&/g' "$match_list")"
  if [[ -f $match_list && $(echo "$_d"|wc -l) -ge 2 ]]; then
    for ((i=1;i<=$(echo "$_d"|wc -l);i+=2)); do
      let j=i+1
      _name="$(echo "$1"|sed 'y/。，？；：‘“、（）｀～！＠＃％＊ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ/.,?;:\"\",()`~!@#%*abcdefghijklmnopqrstuvwxyz/')"
      _name="$(echo "$_name"|sed 's/[\. 　]//g;s/[A-Z]/\l&/g')"
      _one_name="$(echo "$_d"|sed -n "${i}{s/[\. 　]//g;p;q}")"
      _one_name="$(echo "$_one_name"|sed 'y/。，？；：‘“、（）｀～！＠＃％＊ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ/.,?;:\"\",()`~!@#%*abcdefghijklmnopqrstuvwxyz/')"
      [[ $_name =~ .*$_one_name.* ]] && {
        _url="$(echo "$_d"|sed -n "${j}{p;q}")"
        _url="$(echo "$_url"|sed 's![^\.a-z0-9/:]!!g')" # 清洗
        debug_func "match:get-url[$_url]"  #----debug---
        [[ $_url =~ .*imdb.*tt.* ]] && \
        imdb_url="$(echo "$_url"|grep -E 'tt[0-9]{7,8}')" && break
        [[ $_url =~ .*douban.* ]] && douban_url="$(echo "$_url"| \
        grep -Eo '(https?://)?(movie\.)?douban\.com/subject/[0-9]{7,8}')" && \
        douban_url="https://movie.douban.com/subject/${douban_url##*/}" && break
      } 
    done
  else
    debug_func 'match:no-match-lists-file!'  #----debug---
  fi
}

#-------------------------------------#
# 使用预先编辑好的豆瓣简介信息，
# 在 tmp/db 目录下使用 种子英文名+txt后缀命名，
# 使用 .[dot] 分割。样例见 sample.txt
#-------------------------------------#
match_douban_desc() {
  local m_dir i db_name
  m_dir="$ROOT_PATH/tmp/db"
  for i in `cd "$m_dir" 2>/dev/null && \ls -1`; do
    if [[ $dot_name =~ ${i%.txt}.* ]]; then
      \cp -f "${m_dir%/}/$i" "$source_desc"
      # html 格式
      [[ $enable_byrbt = yes ]] && {
        sed "s%\[img\] *%<img src=\"%g;s%\[/img\]%\"/>%g;s%\$%&<br />%g;/&[_a-z]*&/d" "$source_desc" > "$source_html"
        printf '\n%s\n' "<br /><fieldset><legend> <span style=\"color:#ffffff;background-color:#000000;\">转载来源</span></legend>
    <span style=\"font-size:20px;\">本种来自： ${source_site_URL}</span> <br /></fieldset><br />" >> "$source_html"
      }
      printf '\n%s\n' "[quote=转载来源][b]本种来自：[/b] ${source_site_URL}[/quote]" >> "$source_desc"
      # 副标题额外信息
      [[ $extra_subt ]] && {
        db_name="$(grep '&shc_name_douban&' "$source_desc")"
        db_name="${db_name//&shc_name_douban&/}"
        extra_subt="$(echo "${extra_subt/$db_name/}"|sed -E \
          "s%^[ /]+%%;s/ +/ /g;s/&quot;//g;s/\[ *\]//g")"
        sed -i "1c &extra_comment&${extra_subt}" "$source_desc"
      }
      unset source_t_id extra_subt source_site_URL s_site_uid
      unset imdb_url douban_url
      unset source_desc_tmp  source_html_tmp
      unset chs_name_douban  eng_name_douban  douban_poster_url
      debug_func 'match:use-info-existed!'  #----debug---
      break;
    fi
  done
}

