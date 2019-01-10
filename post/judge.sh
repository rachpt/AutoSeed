#!/bin/bash
# FileName: post/judge.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2019-01-10
#
#----------------------------------------#
judge_torrent_func() {
  local base url result is_pad quality year _source pre_url
  local count_720p count_1080p count_720p_pad count_1080p_pad

  year="$(echo "$dot_name"|grep -Eo '[12][098][0-9]{2}')"

  quality="$(echo "$dot_name"|grep -Eio '1080[pi]|720p|4k|2160p')"

  is_pad="$(echo "$dot_name"|grep -Eio 'ipad|chdpad|ihd|mpad')"

  _source="$(echo "$dot_name"|grep -Eio 'hdtv|blu-?ray|web-?dl|bdrip|dvdrip|webrip')"

  base="$(echo "$dot_name"|grep -Eo '.*[12][098][0-9]{2}')"
  base="$(echo "$base"|sed -E 's/(1080[pi]|720p|4k|2160p).*//i')"
  base="$(echo "$base"|sed -E 's/(hdtv|blu-?ray|web-?dl|bdrip|dvdrip|webrip).*//i')"
  
  pre_url="${postUrl%/*}/torrents.php?search="
  url="${pre_url}${base}+${quality}+${is_pad}+${_source}+${year}"

  result="$(http -b --verify=no --ignore-stdin GET "$url" "$cookie" "$user_agent")"

  if [ "$(echo "$result"|grep -E '搜索结果|Search results for')" ]; then
    if [ "$(echo "$result"|grep -E '没有种子。请用准确的关键字重试|没有种子|找到0条结果')" ]; then
        up_status='yes'  # upload
    else
      count_720p=$(echo "$result"|grep 'torrentname'|grep -i '720p'|grep -i 'x264'|wc -l)
      count_1080p=$(echo "$result"|grep 'torrentname'|grep -i '1080p'|grep -i 'x264'|wc -l)
      count_720p_pad=$(echo "$result"|grep 'torrentname'|grep -i 'ipad'|grep -i '720p'|wc -l)
      count_1080p_pad=$(echo "$result"|grep 'torrentname'|grep -i 'ipad'|grep -i '1080p'|wc -l)

      debug_func "dupe:[720$count_720p][720-pad$count_720p_pad][1080$count_1080p][1080-pad$count_1080p_pad]"  #----debug---
      #---nanyangpt dupe judge---#
      if [ "$postUrl" = "${post_site[nanyangpt]}/takeupload.php" ]; then
          if (( count_720p - count_720p_pad > 1 )); then
              up_status='yes'  # upload
          elif (( count_1080p - count_1080p_pad > 1 )); then
              up_status='yes'  # upload
          else
              up_status='no'   # give up upload
              echo "Dupe! [${postUrl%/*}]" >> "$log_Path"
          fi
      #---normal dupe judge---#
      else
       if [ ! "$(echo "$result"|grep -E 'torrent-title|torrentname'|grep -i "$(echo "$dot_name" |grep -Eo '.*[12][098][0-9]{2}.*0p')")" ]; then
           up_status='yes'  # upload
       else
           up_status='no'   # give up upload
           echo "Dupe! [${postUrl%/*}]" >> "$log_Path"
       fi
      fi  # nanyang
    fi    # no result
  fi
}
#
#----------------------------------------#
my_dupe_rules() {
  local i _name _one_name _d lists _url _site _line
  lists="$ROOT_PATH/tmp/dupe-rules.txt"
  # 过滤后的数据
  _d="$(cat "$lists"|sed -E 's/[#＃].*//g;s/[ 　]+//g;/^$/d;s/[A-Z]/\l&/g')"
  if [[ -f $lists && $(echo "$_d"|wc -l) -ge 1 ]]; then
    for ((i=1;i<=$(echo "$_d"|wc -l);i++)); do
      _name="$(echo "$dot_name"|sed 'y/。，？；：‘“、（）｀～！＠＃％＊ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ/.,?;:\"\",()`~!@#%*abcdefghijklmnopqrstuvwxyz/')"
      _name="$(echo "$_name"|sed 's/[\. 　]//g;s/[A-Z]/\l&/g')"
      _line="$(echo "$_d"|sed -n "${i}{s/[\. 　]//g;p;q}")"
      _one_name="$(echo "$_line"|awk -F '+' '{print $NF}'|sed  "s/[\. 　]//g")"
      _one_name="$(echo "$_one_name"|sed 'y/。，？；：‘“、（）｀～！＠＃％＊ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ/.,?;:\"\",()`~!@#%*abcdefghijklmnopqrstuvwxyz/')"
      [[ $_name =~ .*$_one_name.* ]] && {
        _site="$(echo "$_line"|awk -F '+' '{print NF}')" 
        ((_site>2)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $1}') =~ 1|yes ]] && enable_hudbt='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $1}') =~ 0|no ]] && enable_hudbt='no'
        }
        ((_site>3)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $2}') =~ 1|yes ]] && enable_whu='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $2}') =~ 0|no ]] && enable_whu='no'
        }
        ((_site>4)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $3}') =~ 1|yes ]] && enable_npupt='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $3}') =~ 0|no ]] && enable_npupt='no'
        }
        ((_site>5)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $4}') =~ 1|yes ]] && enable_nanyangpt='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $4}') =~ 0|no ]] && enable_nanyangpt='no'
        }
        ((_site>7)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $5}') =~ 1|yes ]] && enable_byrbt='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $5}') =~ 0|no ]] && enable_byrbt='no'
        }
        ((_site>7)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $6}') =~ 1|yes ]] && enable_cmct='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $6}') =~ 0|no ]] && enable_cmct='no'
        }
        ((_site>8)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $7}') =~ 1|yes ]] && enable_tjupt='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $7}') =~ 0|no ]] && enable_tjupt='no'
        }
        source "$ROOT_PATH/static.sh"  # update trackers post_site
        break  # jump out
      } 
    done
  else
    debug_func ':dupe:no-rules!'  #----debug---
  fi
}
#----------------------------------------#

