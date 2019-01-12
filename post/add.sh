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
      http --verify=no --timeout=25 --ignore-stdin -dco "${ROOT_PATH}/tmp/${t_id}.torrent" \
          "$torrent2add" "$user_agent" "$cookie" && sleep 2
      $tr_edit -r 'http://' 'https://' "${ROOT_PATH}/tmp/${t_id}.torrent"

      if [ "$to_client" = 'qbittorrent' ]; then
          qb_add_torrent_file
      elif [ "$to_client" = 'transmission' ]; then
          tr_add_torrent_file
      else
          echo 'Client Selete Error! [whu]'          >> "$debug_Log"
      fi

      \rm -f "${ROOT_PATH}/tmp/${t_id}.torrent"
  else
      if [ "$to_client" = 'qbittorrent' ]; then
          qb_add_torrent_url
      elif [ "$to_client" = 'transmission' ]; then
          tr_add_torrent_url
      else
          echo -e "[$(date '+%Y-%m-%d %H:%M:%S')]\c" >> "$debug_Log"
          echo  "Client Selete Error in add.sh!"     >> "$debug_Log"
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

