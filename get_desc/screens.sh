#!/bin/bash
# FileName: get_desc/screens.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2019-01-02
#
#-------------------------------------#
# 本文件用于处理所有图片问题
#-------------------------------------#
#
# 图片上传 API
upload_poster_api='https://sm.ms/api/upload'
upload_poster_api_byrbt='https://bt.byr.cn/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Images'
#
#-------------------------------------#
# 豆瓣海报上传至图床
#-------------------------------------#
delete_screenshots_img() {
  debug_func 'screens_1:delet'  #----debug---
  local desc_delete_screens="$1"
  sed -i '/\[url=http.*\]\[img\]http.*\[\/img\]\[\/url\]/d' "$desc_delete_screens"
  # hdsky tjupt
  sed -i '/20141003100205b81803ac0903724ad88de90649c5a36e\.jpg/d' "$desc_delete_screens"
  sed -i '/http:\/\/www.stonestudio2015.com/d' "$desc_delete_screens"
  sed -i "/<a.*><img.*>.*<\/a>/d" "$desc_delete_screens" # small img
  sed -i "/截图赏析/d; /alt=\"screens.jpg\"/d; /www.stonestudio2015.com\/stonestudio\/created.png/d; /hds_logo.png/d" "$desc_delete_screens" # hds
  sed -i "/.More.Screens/d;/.Comparisons/d;/Source.*WiKi/d;/WiKi.*Source/d" "$desc_delete_screens" # ttg

  sed -i "/[Hh][Dd][Cc]hina.*vs.*[Ss]ource/d;/[Ss]ource.*vs.*[Hh][Dd][Cc]hina/d" "$desc_delete_screens" # hdc
  #---imdb and douban
  sed -i "s!<a.*href=\"http://www.imdb.com/title/.*\"><a.*href=\"http://www.imdb.com/title/.*\">\(http://www.imdb.com/title/tt[0-9]\{7\}6386132[/]\)</a></a>!\1!g" "$desc_delete_screens"
  sed -i "s!<a.*href=\"http[s]*://movie.douban.com/subject/.*\"><a.*href=\"http[s]*://movie.douban.com/subject/.*\">\(http[s]*://movie.douban.com/subject/.*\)</a></a>!\1!g" "$desc_delete_screens"
  sed -i "s!<a.*href=\"http://www.imdb.com/title/.*\">\(http://www.imdb.com/title/tt[0-9]\{7\}6386132[/]\)</a>!\1!g" "$desc_delete_screens"
  sed -i "s!<a.*href=\"http[s]*://movie.douban.com/subject/.*\">\(http[s]*://movie.douban.com/subject/.*\)</a>!\1!g" "$desc_delete_screens"
}

#-------------------------------------#
deal_with_images() {
  debug_func 'screens_2:in'  #----debug---
  # delete small images
  [[ $enable_byrbt = yes && $just_poster_byrbt = yes ]] && \
    delete_screenshots_img "$source_html"
  # tjupt
  if [ "$enable_tjupt" = 'yes' ]; then
    \cp -f "$source_desc" "$source_desc2tjupt"
    [ "$just_poster_tjupt" = "yes" ] && delete_screenshots_img "$source_desc2tjupt"
  fi
  
  # 遍历 html 简介中的非法图片
  local img_counter_reupload=0
  while true; do
    debug_func 'screens_3:loop'  #----debug---
    if [ "$enable_byrbt" = 'yes' ]; then
      # 获取不包含 byrbt 域名的图片链接
      local img_in_desc_url="$(grep -Eo "src=[\"\']http[^\'\"]+" "$source_html"| \
          sed "/bt\.byr\.cn/d"|head -1|sed "s/src=[\"\']//g")"
      debug_func 'screens_4b:url'  #----debug---
    elif [ "$enable_tjupt" = 'yes' ]; then
      local img_in_desc_url="$(grep -Eio "[img]http.*[/img]" "$source_desc2tjupt"| \
          sed "/i\.loli\.net/d"|head -1|sed -E "s!\[/?img\]!!ig")"
      debug_func 'screens_5t:url'  #----debug---
    fi
    debug_func 'screens_6'  #----debug---
    # 跳出循环条件
    if [ ! "$img_in_desc_url" ]; then
        debug_func 'screens_out:1b'  #----debug---
        break # jump out
    elif [ $img_counter_reupload -gt 24 ]; then
        debug_func 'screens_out:2t'  #----debug---
        break # jump out
    fi
    # 临时图片路径，使用时间作为文件名的一部分
    local tmp_desc_img_file="$ROOT_PATH/tmp/autoseed-pic-$(date '+%s%N')$(echo "${img_in_desc_url##*/}"| \
        sed -r 's/.*(\.[jpgb][pnim]e?[gfp]).*/\1/i')"
    http --verify=no --timeout=25 --ignore-stdin -dco "$tmp_desc_img_file" "$img_in_desc_url" "$user_agent"
    debug_func 'screens_img:dl'  #----debug---
    sleep 1 # 图片下载完成
    # byrbt
    [ "$enable_byrbt" = 'yes' ] && byr_upload_img_url="$(http --verify=no --ignore-stdin \
      --timeout=25 -f POST "$upload_poster_api_byrbt" upload@"$tmp_desc_img_file" "$user_agent" \
      "$cookie_byrbt"|grep -Eo "http[-a-zA-Z0-9./:()]+images[-a-zA-Z0-9./:(_ )]+[^\',\"]*"| \
      sed "s/http:/https:/g")" && sed -i \
      "s!$img_in_desc_url!$byr_upload_img_url!g" "$source_html" && \
      unset byr_upload_img_url && \
      debug_func 'screens_7:byr'  #----debug---
    # tjupt
    [ "$enable_tjupt" = 'yes' ] && [ ! "$(echo "$img_in_desc_url"| \
      grep "i\.loli\.net")" ] && new_poster_url_sm="$(http --verify=no --timeout=25 \
      --ignore-stdin -f POST "$upload_poster_api" smfile@"$tmp_desc_img_file"| \
      grep -Eo "\"url\":\"[^\"]+\""|awk -F "\"" '{print $4}'|sed 's/\\//g')" && \
      sed -i "s!$img_in_desc_url!$new_poster_url_sm!g" "$source_desc2tjupt" && \
      unset new_poster_url_sm && \
      debug_func 'screens_8:tjupt'  #----debug---

    rm -f "$tmp_desc_img_file"
    unset img_in_desc_url  tmp_desc_img_file
    ((img_counter_reupload++)) # C 形式的增1
  done
  # tjupt images
  [ "$enable_tjupt" = 'yes' ] && sed -i \
    '/jpg\|png\|jpeg\|gif\|webp/ {/i\.loli\.net/!d}' "$source_desc2tjupt"
  debug_func 'screens_9:exit'  #----debug---
}

#-------------------------------------#

