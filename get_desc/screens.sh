#!/bin/bash
# FileName: get_desc/screens.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-02-28
#
#-------------------------------------#
# 本文件用于处理原种中所有screen图片问题
#-------------------------------------#
# 包括 bytbt 以及 tjupt
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
  sed -Ei "s!<a.*href=\"http://www.imdb.com/title/.*\"><a.*href=\"http://www.imdb.com/title/.*\">(http://www.imdb.com/title/tt[0-9]{7,8}/)</a></a>!\1!g" "$desc_delete_screens"
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
  local img_url img_url_d img_file img_url_byr img_url_com _ext
  local _counter=0
  while true; do
    if [ "$enable_byrbt" = 'yes' ]; then
      # 获取不包含 byrbt 域名的图片链接
      img_url="$(grep -Eo "src=[\"\']http[^\'\"]+" "$source_html"| \
          sed "/bt\.byr\.cn/d"|head -1|sed "s/src=[\"\']//g")"
      debug_func "screens:desc-url-byr[$img_url]"  #----debug---
    #elif [ "$enable_tjupt" = 'yes' ]; then
      #img_url="$(grep -Eio "[img]http.*[/img]" "$source_desc2tjupt"| \
          #sed "/i\.loli\.net/d"|head -1|sed -E "s!\[/?img\]!!ig")"
      #debug_func "screens:desc-url-tju[$img_url]"  #----debug---
    fi
    # ttg img use https url
    [[ $img_url =~ .*tu\.totheglory\.im.* ]] && \
      img_url_d="${img_url/http:/https:/}" || img_url_d="$img_url"
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
    _ext="${img_url//"${img_url%.*}"}"
    img_file="${ROOT_PATH}/tmp/autoseed-pic-$(date '+%s%N')${_ext%%[%&=@]*}"
    http --verify=no --timeout=25 --ignore-stdin -o "$img_file" -d "$img_url_d" "$user_agent"
    [[ ! -s $img_file ]] && {
        curl -k -o "$img_file" "$img_url_d"
        debug_func 'screens_img:use-curl-download'; }
    [[ -s $img_file ]] && debug_func 'screens_img:downloaded' || \
      debug_func 'screens_img:failed-to-dl'  #----debug---

    # byrbt image
    [[ $enable_byrbt = yes ]] && upload_image_byrbt "$img_file" && \
      [[ $img_url_byr ]] && sed -i "s!$img_url!$img_url_byr!g" "$source_html" && \
      debug_func "screens-byr[$img_url_byr]"
    # tjupt image
    [[ $enable_tjupt = yes ]] && [[ ! "$img_url" =~ *i.loli.net* ]] && \
      upload_image_com "$img_file" && [[ $img_url_com ]] && \
      sed -i "s!$img_url!$img_url_com!g" "$source_desc2tjupt" && \
      debug_func "screens-byr[$img_url_com]"

    [[ $enable_byrbt = yes && $img_url_byr ]] && \rm -f "$img_file"
    #[[ $enable_tjupt = yes && $img_url_com ]] && \rm -f "$img_file"
    unset img_url img_url_d img_file img_url_byr img_url_com
    ((_counter++)) # C 形式的增1
  done
  # tjupt images
  #[ "$enable_tjupt" = 'yes' ] && sed -i \
    #'/jpg\|png\|jpeg\|gif\|webp/ {/i\.loli\.net/!d}' "$source_desc2tjupt"
  debug_func 'screens:exit'  #----debug---
}

#-------------------------------------#

