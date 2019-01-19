#!/bin/bash
# FileName: post/add.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2019-01-12
#
#---------------------------------------#
# 将发布后的种子添加到客户端做种
#-------------call function-------------#
if [ "$one_TR_Dir" ]; then
  if [ "$postUrl" = "${post_site[whu]}/takeupload.php" ]; then
      whu_tr="${ROOT_PATH}/tmp/${t_id}.torrent"
      dl_whu_tr() {
      http --verify=no --timeout=25 --ignore-stdin -dco "$whu_tr" \
          "${downloadUrl}${t_id}" "$user_agent" "$cookie" && sleep 3
      }
      #$tr_edit -r 'http://' 'https://' "${ROOT_PATH}/tmp/${t_id}.torrent"
      for ((a=1;a<5;a++)); do [[ ! -s $whu_tr ]] && dl_whu_tr || break; done
      if [ "$to_client" = 'qbittorrent' ]; then
          qb_add_torrent_file
      elif [ "$to_client" = 'transmission' ]; then
          tr_add_torrent_file
      else
          debug_func "add:Client-Error!-[whu]"  #----debug---
      fi
      [ ! "$test_func_probe" ] && \
      \rm -f "$whu_tr" 
      unset whu_tr a && unset -f dl_whu_tr
  else
      if [ "$to_client" = 'qbittorrent' ]; then
          qb_add_torrent_url
      elif [ "$to_client" = 'transmission' ]; then
          tr_add_torrent_url
      else
          debug_func "add:Client-Error!"  #----debug---
      fi
  fi
  echo "-------------[added]-------------"           >> "$log_Path"
  # 更新豆瓣外部信息
  http --verify=no --ignore-stdin --timeout=16 GET \
   "${postUrl%/*}/retriver.php?id=${t_id}&type=2&siteid=2" "$cookie" "$user_agent"
else
  echo "没有找到本地文件！"                          >> "$log_Path"
fi
#---------------------------------------#

