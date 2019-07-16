#!/bin/bash
# FileName: post/add.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-07-16
#
#---------------------------------------#
# 将发布后的种子添加到客户端做种
#-------------call function-------------#
if [ "$one_TR_Dir" ]; then
  if [ "$postUrl" = "${post_site[whu]}/takeupload.php" ]; then
      whu_tr="${ROOT_PATH}/tmp/${t_id}.torrent"
      dl_whu_tr() {
      http --verify=no --timeout=25 --ignore-stdin -o "$whu_tr" -d \
          "${downloadUrl}${t_id}" "$user_agent" "$cookie" && sleep 3
      [[ ! -s $whu_tr ]] && curl -b "`echo "$cookie"|sed -E 's/^Cookie:[ ]?//i'`" \
          -A "`echo "$user_agent"|sed -E 's/^User-Agent:[ ]?//i'`" -k \
          -o "$whu_tr" "${downloadUrl}${t_id}" && debug_func "add:whu-curl-dl"
      }
      #$tr_edit -r 'http://' 'https://' "${ROOT_PATH}/tmp/${t_id}.torrent"
      for ((a=1;a<5;a++)); do [[ ! -s $whu_tr ]] && dl_whu_tr || break; done
      debug_func "add:whu-tr-size:[`stat -c "%s" "$whu_tr"`]"  #----debug---
      [ ! "`stat -c "%s" "$whu_tr"`" ] && debug_func \
        "add:whu-prarm:[${downloadUrl}${t_id}][$user_agent][$cookie]"  #----debug---
      if [ "$to_client" = 'qbittorrent' ]; then
          qb_add_torrent_file  # transmission.sh
      elif [ "$to_client" = 'transmission' ]; then
          tr_add_torrent_file  # transmission.sh
      else
          debug_func "add:Client-Error!-[whu]"  #----debug---
      fi
      [[ $test_func_probe ]] || \rm -f "$whu_tr" 
      unset whu_tr a && unset -f dl_whu_tr
  else
      if [ "$to_client" = 'qbittorrent' ]; then
          qb_add_torrent_url  # qbittorrent.sh
      elif [ "$to_client" = 'transmission' ]; then
          tr_add_torrent_url  # qbittorrent.sh
      else
          debug_func "add:Client-Error!"  #----debug---
      fi
  fi
  echo "-------------[added]-------------"           >> "${log_Path}-$index"
  # 更新豆瓣外部信息
  if http --verify=no --ignore-stdin --timeout=16 GET "${postUrl%/*}/retriver.php" \
    id=="$t_id" type==2 siteid==2 "$cookie" "$user_agent" &> /dev/null; then
    debug_func 'add:更新外部信息成功！'  #----debug---
  else
    case $? in
      2) debug_func 'add:Request timed out!' ;;
      3) debug_func 'add:Unexpected HTTP 3xx Redirection!' ;;
      4) debug_func 'add:HTTP 4xx Client Error!' ;;
      5) debug_func 'add:HTTP 5xx Server Error!' ;;
      6) debug_func 'add:Exceeded --max-redirects=<n> redirects!' ;;
      *) debug_func 'add:Other Error!' ;;
    esac
    sleep 1
    # 备用更新方法
    curl -k -b "`echo "$cookie"|sed -E 's/^cookie:[ ]?//i'`"  \
      -A "`echo "$user_agent"|sed -E 's/^User-Agent:[ ]?//i'`"  \
      "${postUrl%/*}/retriver.php?id=$t_id&type=2&siteid=2" && \
      debug_func 'add:used-curl-update'
  fi

else
  echo "没有找到本地文件！"                          >> "${log_Path}-$index"
fi
#---------------------------------------#

