#!/bin/bash
# FileName: get_desc/screens.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2019-01-24
#
#-------------------------------------#
# 本文件用于处理所有图片问题
#-------------------------------------#
#
#-------------------------------------#
# 豆瓣海报上传至图床
#-------------------------------------#
delete_screenshots_img() {
  debug_func 'screens:delete-screenshots'  #----debug---
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
  debug_func 'screens:in'  #----debug---
  # delete small images
  [[ $enable_byrbt = yes && $just_poster_byrbt = yes ]] && \
    delete_screenshots_img "$source_html"
  # tjupt
  if [ "$enable_tjupt" = 'yes' ]; then
    \cp -f "$source_desc" "$source_desc2tjupt"
    [ "$just_poster_tjupt" = "yes" ] && delete_screenshots_img "$source_desc2tjupt"
  fi
  
  # 遍历 html 简介中的非法图片
  local img_url img_file byr_url sm_url
  local _counter=0
  while true; do
    if [ "$enable_byrbt" = 'yes' ]; then
      # 获取不包含 byrbt 域名的图片链接
      img_url="$(grep -Eo "src=[\"\']http[^\'\"]+" "$source_html"| \
          sed "/bt\.byr\.cn/d"|head -1|sed "s/src=[\"\']//g")"
      debug_func "screens:desc-url-byr[$img_url]"  #----debug---
    elif [ "$enable_tjupt" = 'yes' ]; then
      img_url="$(grep -Eio "[img]http.*[/img]" "$source_desc2tjupt"| \
          sed "/i\.loli\.net/d"|head -1|sed -E "s!\[/?img\]!!ig")"
      debug_func "screens:desc-url-tju[$img_url]"  #----debug---
    fi
    debug_func "screens-loop[$_counter]"  #----debug---
    # 跳出循环条件
    if [ ! "$img_url" ]; then
        debug_func 'screens-out:no-img'  #----debug---
        break # jump out
    elif [ $_counter -gt 24 ]; then
        debug_func 'screens-out:>24'     #----debug---
        break # jump out
    fi
    # 临时图片路径，使用时间作为文件名的一部分
    img_file="$ROOT_PATH/tmp/autoseed-pic-$(date '+%s%N')$(echo "${img_url##*/}"| \
        sed -r 's/.*(\.[jpgb][pnim]e?[gfp]).*/\1/i')"
    http --verify=no --timeout=25 --ignore-stdin -dco "$img_file" "$img_url" "$user_agent"
    sleep 2 && [[ ! -s $img_file ]] && \
    http --verify=no --timeout=25 --ignore-stdin -dco "$img_file" "$img_url" "$user_agent"
    [[ ! -s $img_file ]] && debug_func 'screens_img:downloaded' || \
      debug_func 'screens_img:failed-to-dl'  #----debug---
    # byrbt
    [ "$enable_byrbt" = 'yes' ] && byr_url="$(http --verify=no --ignore-stdin \
      --timeout=25 -bf POST "$upload_poster_api_byrbt" upload@"$img_file" "$user_agent" \
      "$cookie_byrbt"|grep -Eio "https?://[^\'\"]+"|sed "s/http:/https:/g")" && \
      sed -i "s!$img_url!$byr_url!g" "$source_html" && \
      debug_func "screens-byr[$byr_url]" && unset byr_url
    # tjupt
    [ "$enable_tjupt" = 'yes' ] && [ ! "$(echo "$img_url"| \
      grep "i\.loli\.net")" ] && sm_url="$(http --verify=no --timeout=25 \
      --ignore-stdin -f POST "$upload_poster_api" smfile@"$img_file"| \
      grep -Eo "\"url\":\"[^\"]+\""|awk -F "\"" '{print $4}'|sed 's/\\//g')" && \
      if [[ ! $sm_url ]]; then sm_url="$(http --pretty=format --verify=no -bf \
      --timeout=25 --ignore-stdin POST "$upload_poster_api_2" image@"$screen_file" \
      "$user_agent"|grep -Eo "\"link\":\"[^\"]+\""|awk -F "\"" '{print $4}'| \
      sed 's/\\//g')";fi && sed -i "s!$img_url!$sm_url!g" "$source_desc2tjupt" && \
      debug_func "screens-byr[$sm_url]" && unset sm_url

    \rm -f "$img_file"
    unset img_url img_file
    ((_counter++)) # C 形式的增1
  done
  # tjupt images
  [ "$enable_tjupt" = 'yes' ] && sed -i \
    '/jpg\|png\|jpeg\|gif\|webp/ {/i\.loli\.net/!d}' "$source_desc2tjupt"
  debug_func 'screens:exit'  #----debug---
}

#-------------------------------------#

