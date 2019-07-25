#!/bin/bash
# FileName: post/cmct.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2018-12-08
#
#-------------settings---------------#
cookie="$cookie_cmct"
passkey="$passkey_cmct"
anonymous="$anonymous_cmct"
ratio_set=$ratio_cmct
to_client="$client_cmct"
#---static---#
postUrl="${post_site[cmct]}/takeupload.php"
editUrl="${post_site[cmct]}/takeedit.php"
downloadUrl="${post_site[cmct]}/download.php?id="
#-------------------------------------#
gen_cmct_parameter() {

if [ -s "$source_desc" ]; then
    cmct_des="${descrCom_simple//&ratio_in_desc&/$ratio_cmct}
$(sed '/&shc_name_douban&/d;/&eng_name_douban&/d' "$source_desc")"
else
    cmct_des="${descrCom_simple//&ratio_in_desc&/$ratio_cmct}
$failed_to_get_des"
fi

#-------------------------------------#
    # 判断类型，纪录片、电影、剧集
    if [ "$documentary" = 'yes' ]; then
        cmct_type='503'
    else
        if [ "$serials" = 'yes' ]; then
            # 剧集分类
            cmct_type='502'
        else
            # 电影类别
            cmct_type='501'
        fi
    fi
#-------------------------------------#
    # 封装格式
    if [ "$file_type" = 'MKV']; then
        cmct_medium=6
    elif [ "$file_type" = 'MP4']; then
        cmct_medium=7
    elif [ "$file_type" = 'TS']; then
        [ "$is_bd" ] && cmct_medium=4
        [ "$is_hdtv" ] && cmct_medium=5
    else
        cmct_medium=0
    fi
    # 视频编码
    if [ "$is_264" = 'yes' ]; then
        cmct_codec=2
    elif [ "$is_265" = 'yes' ]; then
        cmct_codec=1
    else
        cmct_codec=0
    fi

    # 音频编码
    if [ "$is_dts" = 'yes' ]; then
        cmct_audio=3
    elif [ "$is_ac3" = 'yes' ]; then
        cmct_audio=4
    elif [ "$is_aac" = 'yes' ]; then
        cmct_audio=5
    elif [ "$is_flac" = 'yes' ]; then
        cmct_audio=7
    else
        cmct_audio=0
    fi

    # 分辨率
    if [ "$is_4k" = 'yes' ]; then
        cmct_standard='1'
    elif [ "$is_1080p" = 'yes' ]; then
        cmct_standard='2'
    elif [ "$is_1080i" = 'yes' ]; then
        cmct_standard='3'
    elif [ "$is_720p" = 'yes' ]; then
        cmct_standard='4'
    else
        cmct_standard='0'
    fi

# 地区
case "$region" in
  *中国大陆*)
      cmct_source='1' ;;
  *香港*|*台湾*|*澳门*)
      cmct_source='2' ;;
  *日本*|*韩国*)
      cmct_source='10' ;;
  *美国*|*英国*|*德国*|*法国*|*墨西哥*|*俄罗斯*|*西班牙*|*加拿大*|*澳大利亚*)
      cmct_source='9' ;;
  *)
      cmct_source='3' ;;
esac

    cmct_small_descr="$chinese_title $chs_included"
}
#-------------------------------------#

#---类型---#
# 0    请选择
# 501  Movies(电影)
# 502  TV Series(剧集)
# 503  Docs(纪录)
# 504  Animations(动画)
# 505  TV Shows(综艺)
# 506  Sports(体育)
# 507  MV(音乐视频)
# 508  Music(音乐)
# 509  Others(其他)
#
#---格式---#
# 0  请选择
# 1  Blu-ray(原盘)
# 2  MiniBD
# 3  DVD(原盘)
# 4  TS/REMUX
# 5  TS/HDTV
# 6  Matroska
# 7  MP4
# 
#---视频---#
# 0  请选择
# 1  HEVC
# 2  H.264
# 3  VC-1
# 4  MPEG-2
# 
#---音频---#
# 0  请选择
# 1  DTS-HD
# 2  TrueHD
# 6  LPCM
# 3  DTS
# 4  AC-3
# 5  AAC
# 7  FLAC
# 8  APE
# 9  WAV
# 
#---分辨率---#
# 0  请选择
# 1  UHD
# 2  1080p
# 3  1080i
# 4  720p
# 5  SD
# 
#---地区---#
# 0  请选择
# 1  China(大陆)
# 2  HK&amp;TW(港台)
# 9  EU&amp;US(欧美)
# 10 JP&amp;KR(日韩)
# 3  Other(其他)
# 
# pack="yes"  合集

#-------------------------------------#
cmct_post_func() {
  gen_cmct_parameter
  #---post data---#
id="$(http --verify=no --ignore-stdin -f --print=h POST "$postUrl"\
  'name'="$dot_name"\
  'small_descr'="$cmct_small_descr"\
  'url'="$imdb_url"\
  'descr'="$cmct_des"\
  'type'="$cmct_type"\
  'medium_sel'="$cmct_medium"\
  'codec_sel'="$cmct_codec"\
  'audiocodec_sel'="$cmct_audio"\
  'standard_sel'="$cmct_standard"\
  'source_sel'="$cmct_source"\
  'pack'="$is_package"\
  'uplver'="$anonymous_cmct"\
  file@"${torrent_Path}"\
  "$cookie_cmct"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

  if [[ -z "$t_id" ]]; then
    # 辅种
    reseed_torrent
  fi
}

#-------------------------------------#
