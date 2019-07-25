#!/bin/bash
# FileName: post/hudbt.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-02-21
#
#-------------settings---------------#
cookie="$cookie_hudbt"
passkey="$passkey_hudbt"
anonymous="$anonymous_hudbt"
ratio_set=$ratio_hudbt
to_client="$client_hudbt"
#---static---#
postUrl="${post_site[hudbt]}/takeupload.php"
editUrl="${post_site[hudbt]}/takeedit.php"
downloadUrl="${post_site[hudbt]}/download.php?id="
#-------------------------------------#
gen_hudbt_parameter() {

if [ -s "$source_desc" ]; then
    hudbt_des="${descrCom_complex//&ratio_in_desc&/$ratio_hudbt}
$(sed '/&shc_name_douban&/d;/&eng_name_douban&/d;s/  /　/g' "$source_desc")"
else
    hudbt_des="${descrCom_complex//&ratio_in_desc&/$ratio_hudbt}
$failed_to_get_des"
fi

#-------------------------------------#
# 判断类型，纪录片、电影、剧集、动漫
if [[ $documentary = yes ]]; then
    hudbt_type='404'
elif [[ $theater = yes ]]; then
    # 动漫 剧场版
    hudbt_type='428' #剧场版
elif [[ $is_ipad = yes ]]; then
    # 移动视频
    hudbt_type='430'
elif [[ $serials = yes ]]; then
  # 剧集分类
  case "$region" in
    *中国大陆*)
        hudbt_type='402' ;;
    *香港*|*台湾*|*澳门*)
        hudbt_type='417' ;;
    *日本*|*韩国*|*印度*|*新加坡*|*泰国*|*菲律宾*)
        hudbt_type='416' ;;
      *美国*|*英国*|*德国*|*法国*|*墨西哥*|*俄罗斯*|*西班牙*|*加拿大*|*澳大利亚*|*瑞典*|*芬兰*|*爱尔兰*|*阿联酋*|*土耳其*|*意大利*)
        hudbt_type='418' ;;
    *)
        hudbt_type='409' ;;
  esac
  [[ $animation = yes ]] && hudbt_type='427' #连载动画
else
  # 电影类别
  case "$region" in
    *中国大陆*)
        hudbt_type='401' ;;
    *香港*|*台湾*|*澳门*)
        hudbt_type='413' ;;
    *日本*|*韩国*|*印度*|*新加坡*|*泰国*|*菲律宾*)
        hudbt_type='414' ;;
      *美国*|*英国*|*德国*|*法国*|*墨西哥*|*俄罗斯*|*西班牙*|*加拿大*|*澳大利亚*|*瑞典*|*芬兰*|*爱尔兰*|*阿联酋*|*土耳其*|*意大利*)
        hudbt_type='415' ;;
    *)
        hudbt_type='409' ;;
  esac
fi

#-------------------------------------#
    # 设置分辨率
    if [ "$is_4k" = 'yes' ]; then
        hudbt_stardand='0'
    elif [ "$is_1080p" = 'yes' ]; then
        hudbt_stardand='1'
    elif [ "$is_1080i" = 'yes' ]; then
        hudbt_stardand='2'
    elif [ "$is_720p" = 'yes' ]; then
        hudbt_stardand='3'
    else
        hudbt_stardand='0'
    fi

#-------------------------------------#
    # 副标题
    hudbt_small_descr="$chinese_title $chs_included"
}
#-------------------------------------#
# file -> 种子文件(*)，dl-url -> 网盘下载
# name -> 主标题(0day 不要点*)，url -> imdb链接
# nfo  -> nfo 文件，descr -> 简介(*)，type -> 类型(*) 
# standard_sel -> 分辨率，uplver -> 匿名上传('yes')
#---类型---#
# 401  大陆电影
# 413  港台电影
# 414  亚洲电影
# 415  欧美电影
# 430  iPad
# 433  抢先视频
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
# 409  其他
# 432  电子书
# 405  完结动漫
# 427  连载动漫
# 428  剧场OVA
# 429  动漫周边
# 410  游戏
# 431  游戏视频
# 411  软件
# 412  学习
# 426  MAC
# 1037 HUST
#---分辨率---#
# 0  请选择
# 1  1080p
# 2  1080i
# 3  720p
# 4  SD
# 6  Lossy
# 5  Lossless

#-------------------------------------#
hudbt_post_func() {
  gen_hudbt_parameter
t_id="$(http --verify=no --ignore-stdin -f --print=h --timeout=10 POST "$postUrl"\
  'name'="$noDot_name"\
  'small_descr'="$hudbt_small_descr"\
  'url'="$imdb_url"\
  'descr'="$hudbt_des"\
  'type'="$hudbt_type"\
  'standard_sel'="$hudbt_stardand"\
  'uplver'="$anonymous_hudbt"\
  file@"${torrent_Path}"\
  "$cookie_hudbt"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

if [[ -z "$t_id" ]]; then
  # 辅种
  t_id="$(http --verify=no --ignore-stdin -f --timeout=10 POST "$postUrl"\
    name="$noDot_name"\
    small_descr="$hudbt_small_descr"\
    url="$imdb_url"\
    descr="$hudbt_des"\
    type="$hudbt_type"\
    standard_sel="$hudbt_stardand"\
    uplver="$anonymous_hudbt"\
    file@"${torrent_Path}"\
    "$cookie_hudbt"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"
fi
}

#-------------------------------------#
