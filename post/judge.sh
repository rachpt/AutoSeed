#!/bin/bash
# FileName: post/judge.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-07-16
#
#----------------------------------------#
judge_torrent_func() {
  local year quality is_pad _source base pre_url url result
  local count_720p count_1080p count_720p_pad count_1080p_pad this_t
  # 年份
  year="$(echo "$dot_name"|grep -Eo '[12][098][0-9]{2}')"
  # 分辨率
  quality="$(echo "$dot_name"|grep -Eio '1080[pi]|720p|4k|2160p')"
  # ipad？
  is_pad="$(echo "$dot_name"|grep -Eio 'ipad|chdpad|ihd|mpad')"
  # 介质
  _source="$(echo "$dot_name"|grep -Eio 'hdtv|blu-?ray|web-?dl|bdrip|dvdrip|webrip')"
  # 名字
  base="$(echo "$dot_name"|grep -Eo '.*[12][098][0-9]{2}')"
  base="$(echo "$base"|sed -E 's/(1080[pi]|720p|4k|2160p).*//i')"
  base="$(echo "$base"|sed -E 's/(hdtv|blu-?ray|web-?dl|bdrip|dvdrip|webrip).*//i')"
  # 搜索链接
  pre_url="${postUrl%/*}/torrents.php?search="
  url="${pre_url}${base}+${quality}+${is_pad}+${_source}+${year}"
  # 结果页面
  result="$(http -b --verify=no --ignore-stdin GET "$url" "$cookie" "$user_agent")"

  if [ "$(echo "$result"|grep -E '搜索结果|Search results for')" ]; then
    if [ "$(echo "$result"|grep -E '没有种子。请用准确的关键字重试|没有种子|找到0条结果')" ]; then
      up_status='yes'  # upload
    else
      count_720p=$(echo "$result"|grep 'torrentname'|grep -i '720p'|grep -i 'x264'|wc -l)
      count_1080p=$(echo "$result"|grep 'torrentname'|grep -i '1080p'|grep -i 'x264'|wc -l)
      count_720p_pad=$(echo "$result"|grep 'torrentname'|grep -i 'ipad'|grep -i '720p'|wc -l)
      count_1080p_pad=$(echo "$result"|grep 'torrentname'|grep -i 'ipad'|grep -i '1080p'|wc -l)
      this_t="$(echo "$result"|grep -io "$dot_name")"   # 辅种
      [[ $this_t ]] && up_status='yes' || {
      #----debug---
      debug_func "dupe:[720.$count_720p][720-pad.$count_720p_pad][1080.$count_1080p][1080-pad.$count_1080p_pad]"
      #---nanyangpt dupe judge---#
      if [ "$postUrl" = "${post_site[nanyangpt]}/takeupload.php" ]; then
          if (( count_720p - count_720p_pad > 1 )); then
              up_status='yes'  # upload
          elif (( count_1080p - count_1080p_pad > 1 )); then
              up_status='yes'  # upload
          else
              up_status='no'   # give up upload
              echo "Dupe! [${postUrl%/*}]" >> "${log_Path}-$index"
          fi
      #---normal dupe judge---#
      else
       if [ ! "$(echo "$result"|grep -E 'torrent-title|torrentname'|grep -i "$(echo "$dot_name" |grep -Eo '.*[12][098][0-9]{2}.*0p')")" ]; then
           up_status='yes'  # upload
       else
           up_status='no'   # give up upload
           echo "Dupe! [${postUrl%/*}]" >> "${log_Path}-$index"
       fi
      fi  # nanyang
      }   # 辅种
    fi    # no result
  fi
}
#
#----------------------------------------#

