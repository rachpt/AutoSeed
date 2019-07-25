#!/bin/bash
# FileName: post/whu.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-02-21
#
#-------------settings---------------#
cookie="$cookie_whu"
passkey="$passkey_whu"
anonymous="$anonymous_whu"
ratio_set=$ratio_whu
to_client="$client_whu"
#---static---#
postUrl="${post_site[whu]}/takeupload.php"
editUrl="${post_site[whu]}/takeedit.php"
downloadUrl="${post_site[whu]}/download.php?id="
#-------------------------------------#
gen_whu_parameter() {

if [[ -s "$source_desc" ]]; then
    whu_des="${descrCom_complex//&ratio_in_desc&/$ratio_whu}
$(sed '/&shc_name_douban&/d;/&eng_name_douban&/d' "$source_desc")"
else
    whu_des="${descrCom_complex//&ratio_in_desc&/$ratio_whu}
$failed_to_get_des"
fi

#-------------------------------------#
# 判断类型，纪录片、电影、剧集、动漫
if [[ $documentary = yes ]]; then
    # 纪录片
    whu_type='404'
elif [[ $theater = yes ]]; then
    # 动漫 剧场版
    whu_type='428' #剧场版
elif [[ $serials = yes ]]; then
    # 剧集
    case "$region" in
      *中国大陆*)
          whu_type='402' ;;
      *香港*|*台湾*|*澳门*)
          whu_type='417' ;;
      *日本*|*韩国*|*印度*|*新加坡*|*泰国*|*菲律宾*)
          whu_type='416' ;;
      *美国*|*英国*|*德国*|*法国*|*墨西哥*|*俄罗斯*|*西班牙*|*加拿大*|*澳大利亚*|*瑞典*|*芬兰*|*爱尔兰*|*阿联酋*|*土耳其*|*意大利*)
          whu_type='418' ;;
      *)
          whu_type='409' ;;
    esac
    [[ $animation = yes ]] && whu_type='427' #连载动画
else
    # 电影
    case "$region" in
      *中国大陆*)
          whu_type='401' ;;
      *香港*|*台湾*|*澳门*)
          whu_type='413' ;;
      *日本*|*韩国*|*印度*|*新加坡*|*泰国*|*菲律宾*)
          whu_type='414' ;;
      *美国*|*英国*|*德国*|*法国*|*墨西哥*|*俄罗斯*|*西班牙*|*加拿大*|*澳大利亚*|*瑞典*|*芬兰*|*爱尔兰*|*阿联酋*|*土耳其*|*意大利*)
          whu_type='415' ;;
      *)
          whu_type='409' ;;
    esac
fi

#-------------------------------------#
    # 设置分辨率
    if [ "$is_ipad" = 'yes' ]; then
        # 移动视频
        whu_stardand='9'
    else
        if [ "$is_4k" = 'yes' ]; then
            whu_stardand='10'
        elif [ "$is_1080p" = 'yes' ]; then
            whu_stardand='1'
        elif [ "$is_1080i" = 'yes' ]; then
            whu_stardand='2'
        elif [ "$is_720p" = 'yes' ]; then
            whu_stardand='3'
        else
            whu_stardand='0'
        fi
    fi
#-------------------------------------#
    # 副标题
    whu_small_descr="$chinese_title $chs_included"
}

#-------------------------------------#
# file -> 种子文件(*)，dl-url -> 网盘下载
# type -> 类型(*) ，name  -> 主标题(0day 不要点*)
# small_descr -> 副标题
# url  -> imdb链接，url_douban -> 豆瓣链接(没有 imdb 才使用)
# nfo  -> nfo 文件，descr -> 简介(*)
# standard_sel -> 分辨率，uplver -> 匿名上传('yes')
# noshoutbox -> 通知('yes')
#---类型---#
# 401  大陆电影
# 413  港台电影
# 414  亚洲电影
# 415  欧美电影
# 402  大陆剧集
# 417  港台剧集
# 416  亚洲剧集
# 418  欧美剧集
# 404  纪录片
# 407  体育
# 403  大陆综艺
# 419  港台综艺
# 420  亚洲综艺
# 421  欧美综艺
# 408  华语音乐
# 422  日韩音乐
# 423  欧美音乐
# 424  古典音乐
# 425  原声音乐
# 406  音乐MV
# 405  完结动漫
# 427  连载动漫
# 428  剧场OVA
# 429  动漫周边
# 410  游戏
# 411  软件
# 412  学习
# 430  武汉大学
# 409  其他
#---分辨率---#
# 0  请选择
# 10 4K
# 1  1080p
# 2  1080i
# 3  720p
# 9  移动视频
# 4  标清
# 5  无损音乐
# 6  有损音乐

#-------------------------------------#
whu_post_func() {
  gen_whu_parameter
  #---post data---#
t_id="$(http --verify=no --ignore-stdin -f --print=h --timeout=10 POST "$postUrl"\
  'name'="$noDot_name"\
  'small_descr'="$whu_small_descr"\
  'url'="$imdb_url"\
  'url_douban'="$( [ ! "$imdb_url" ] && echo "$douban_url" || echo '11')"\
  'descr'="$whu_des"\
  'type'="$whu_type"\
  'standard_sel'="$whu_stardand"\
  'uplver'="$anonymous_whu"\
  file@"${torrent_Path}"\
  "$cookie_whu"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

if [[ -z "$t_id" ]]; then
  # 辅种
t_id="$(http --verify=no --ignore-stdin -f -b --timeout=10 POST "$postUrl"\
   name="$noDot_name"\
   small_descr="$whu_small_descr"\
   url="$imdb_url"\
   url_douban="$( [ ! "$imdb_url" ] && echo "$douban_url")"\
   descr="$whu_des"\
   type="$whu_type"\
   standard_sel="$whu_stardand"\
   uplver="$anonymous_whu"\
   file@"${torrent_Path}"\
   "$cookie_whu"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"
fi
}

#-------------------------------------#

