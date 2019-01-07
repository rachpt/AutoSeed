#!/bin/bash
# FileName: get_desc/match.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2019-01-07
#
#-------------------------------------#
# 本文件匹配指定文件中的imdb或者豆瓣链接，用于生成简介，
# 匹配文件路径 $ROOT_PATH/tmp/match-lists.txt，
# 支持中文名、英文名，和 # 号注释。
# 调用需要一个参数，$dot_name 或者 $org_tr_name。
#-------------------------------------#

# 匹配已知英文名，指定豆瓣或者imdb链接，用于剧集以及动漫
match_douban_imdb() {
  local i j _name _one_name _d match_list _url
  match_list="$ROOT_PATH/tmp/match-lists.txt"
  # 过滤后的数据
  _d="$(cat "$match_list"|sed -E 's/[#＃].*//g;s/[ 　]+//g;/^$/d;s/[A-Z]/\l&/g')"
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
        debug_func "match:_url[$_url]"  #----debug---
        [[ $_url =~ .*imdb.* ]] && \
        imdb_url="$(echo "$_url"|grep -E 'tt[0-9]{7}')" && break
        [[ $_url =~ .*douban.* ]] && douban_url="$(echo "$_url"| \
        grep -Eo '(https?://)?(movie\.)?douban\.com/subject/[0-9]{7,8}')" && break
      } 
      [[ $douban_url ]] && douban_url="https://movie.douban.com/subject/${douban_url##*/}"
    done
  else
    debug_func 'match:no-match-lists!'  #----debug---
  fi
}
