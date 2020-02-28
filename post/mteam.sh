#!/bin/bash
# FileName: post/mteam.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-08-15
#
#-------------settings---------------#
cookie="$cookie_mt"
passkey="$passkey_mt"
anonymous="$anonymous_mt"
ratio_set=$ratio_mt
to_client="$client_mt"
#---static---#
postUrl="${post_site[mt]}/takeupload.php"
editUrl="${post_site[mt]}/takeedit.php"
downloadUrl="${post_site[mt]}/download.php?id="
#-------------------------------------#
gen_mt_parameter() {

if [[ -s "$source_desc" ]]; then
  [[ $header_mt = yes ]] && {
    mt_des="${descrCom_simple//&ratio_in_desc&/$ratio_mt}
$(sed '/&shc_name_douban&/d;/&eng_name_douban&/d' "$source_desc")"
    } || {
    mt_des="$(sed '/&shc_name_douban&/d;/&eng_name_douban&/d' "$source_desc")"
    }
else
    mt_des="${descrCom_simple//&ratio_in_desc&/$ratio_mt}
$failed_to_get_des"
fi

#-------------------------------------#
    # 判断类型，纪录片、电影、剧集
    if [ "$documentary" = 'yes' ]; then
        mt_type='404'
    else
        if [ "$serials" = 'yes' ]; then
            # 剧集分类
            mt_type='402'
        else
            # 电影类别
            mt_type='419'
        fi
    fi
#-------------------------------------#
    # 视频编码
    if [ "$is_264" = 'yes' ]; then
        mt_codec=1
    elif [ "$is_265" = 'yes' ]; then
        mt_codec=16
    else
        mt_codec=0
    fi

    # 分辨率
    if [ "$is_4k" = 'yes' ]; then
        mt_standard='6'
    elif [ "$is_1080p" = 'yes' ]; then
        mt_standard='1'
    elif [ "$is_1080i" = 'yes' ]; then
        mt_standard='2'
    elif [ "$is_720p" = 'yes' ]; then
        mt_standard='3'
    else
        mt_standard='0'
    fi

# 地区
case "$region" in
  *中国大陆*)
      mt_source='1' ;;
  *香港*|*台湾*|*澳门*)
      mt_source='3' ;;
  *日本*)
      mt_source='4' ;;
  *韩国*)
      mt_source='5' ;;
  *美国*|*英国*|*德国*|*法国*|*墨西哥*|*俄罗斯*|*西班牙*|*加拿大*|*澳大利亚*)
      mt_source='2' ;;
  *)
      mt_source='6' ;;
esac
    [[ $is_package = yes ]] && mt_team=8 || mt_team=0
    mt_small_descr="$chinese_title $chs_included"
    # mt_chs 定义在parameter.sh里面    
}
#-------------------------------------#

#---类型---# type
#419  Movie(電影)/HD
#420  Movie(電影)/DVDiSo
#421  Movie(電影)/Blu-Ray
#439  Movie(電影)/Remux
#403  TV Series(影劇/綜藝)/SD
#402  TV Series(影劇/綜藝)/HD
#435  TV Series(影劇/綜藝)/DVDiSo
#438  TV Series(影劇/綜藝)/BD
#404  紀錄教育
#405  Anime(動畫)
#406  MV(演唱)
#408  Music(AAC/ALAC)
#434  Music(無損)
#407  Sports(運動)
#422  Software(軟體)
#423  PCGame(PC遊戲)
#427  eBook(電子書)
#410  AV(有碼)/HD Censored
#429  AV(無碼)/HD Uncensored
#424  AV(有碼)/SD Censored
#430  AV(無碼)/SD Uncensored
#426  AV(無碼)/DVDiSo Uncensored
#437  AV(有碼)/DVDiSo Censored
#431  AV(有碼)/Blu-Ray Censored
#432  AV(無碼)/Blu-Ray Uncensored
#436  AV(網站)/0Day
#425  IV(寫真影集)/Video Collection
#433  IV(寫真圖集)/Picture Collection
#411  H-Game(遊戲)
#412  H-Anime(動畫)
#413  H-Comic(漫畫)
#409  Misc(其他)
#---编码---# codec_sel
# 0   請選擇
# 1   H.264
# 2   VC-1
# 3   Xvid
# 4   MPEG-2
# 5   FLAC
# 10  APE
# 11  DTS
# 12  AC-3
# 13  WAV
# 14  MP3
# 15  MPEG-4
# 16  H.265
# 17  ALAC
# 18  AAC
# 
#---解析度---# standard_sel
# 0  請選擇
# 1  1080p
# 2  1080i
# 3  720p
# 5  SD
# 6  4K
# 
#---地区---# processing_sel
# 0  請選擇
# 1  CN
# 2  US/EU
# 3  HK/TW
# 4  JP
# 5  KR
# 6  OT
#---制作组---# team_sel
# 0   請選擇  !
# 6   BMDru
# 7   KiSHD
# 8   Pack   !
# 9   MTeam
# 10  MPAD
# 23  TnP
# 17  MTeamTV
# 18  OneHD
# 19  CNHK
# 20  StBOX
# 21  R2HD
# 22  LowPower-Raws

# uplver 匿名 yes
#-------------------------------------#
mt_post_func() {
  gen_mt_parameter
  #---post data---#
id="$(http --verify=no --ignore-stdin -f --print=h POST "$postUrl"\
  'name'="$noDot_name"\
  'small_descr'="$mt_small_descr"\
  'url'="$imdb_url"\
  'descr'="$mt_des"\
  'type'="$mt_type"\
  'codec_sel'="$mt_codec"\
  'standard_sel'="$mt_standard"\
  'processing_sel'="$mt_source"\
  'l_sub'=${mt_chs:-0}\
  'team_sel'=${mt_team:-0}\
  'uplver'="$anonymous_mt"\
  file@"${torrent_Path}"\
  "$user_agent"\
  "Referer: ${post_site[mt]}/upload.php"\
  "$cookie_mt"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

  if [[ -z "$t_id" ]]; then
    # 辅种
    reseed_torrent
  fi
}

#-------------------------------------#
