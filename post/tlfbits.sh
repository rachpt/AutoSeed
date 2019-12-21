#!/bin/bash
# FileName: post/tlfbits.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-12-21
#
#-------------settings---------------#
cookie="$cookie_tlfbits"
passkey="$passkey_tlfbits"
anonymous="$anonymous_tlfbits"
ratio_set=$ratio_tlfbits
to_client="$client_tlfbits"
#---static---#
postUrl="${post_site[tlfbits]}/takeupload.php"
editUrl="${post_site[tlfbits]}/takeedit.php"
downloadUrl="${post_site[tlfbits]}/download.php?id="
#-------------------------------------#
gen_tlfbits_parameter() {
# 简介
if [ -s "$source_desc" ]; then
    tlfbits_des="${descrCom_simple//&ratio_in_desc&/$ratio_tlfbits}
$(sed '/&shc_name_douban&/d;/&eng_name_douban&/d' "$source_desc")"
else
    tlfbits_des="${descrCom_simple//&ratio_in_desc&/$ratio_tlfbits}
$failed_to_get_des"
fi
#-------------------------------------#
  # 0day分类
  tlfbits_type='423'
#-------------------------------------#
  # 类型
  tlfbits_source='14'
  # 分辨率
  tlfbits_standard='0'
  # 副标题
  tlfbits_small_descr="$chinese_title $chs_included"
}
#-------------------------------------#

#---类型---#
# 0 请选择
# 426 TLF-MiniSD
# 432 TLF-Fayea
# 436 TLF-iNT
# 411 Movie/XviD
# 430 Movie/X264
# 415 TV/XviD
# 413 TV/DVDRip
# 414 TV/x264
# 416 Game/PC 
# 417 Game/PS2
# 418 Game/PS3 
# 419 Game/PSP
# 420 Game/WII
# 421 Game/Xbox360
# 429 Game/Archive
# 422 APPS
# 423 0day
# 428 0DAY/Archive 
# 424 MP3
# 425 MVID 
# 435 Lossless
# 427 MISC
# 437 Unknown#
#---质量 类型---#
# name="source_sel"
# 0 请选择
# 1 剧情文艺
# 3 喜剧爱情
# 4 动画魔幻
# 5 科幻探险
# 7 动作战争
# 8 罪案悬疑
# 9 恐怖灾难
# 10 纪录
# 11 剧集
# 12 音乐
# 13 游戏
# 15 软件
# 14 其他# 
#---分辨率---#
# name="standard_sel">
# 0 请选择
# 1 1080p
# 2 1080i
# 3 720p
# 4 SD
# 5 Blu-ray/HD DVD# 
# 
#-------------------------------------#
tlfbits_post_func() {
  gen_tlfbits_parameter
  #---post data---#
t_id="$(http --verify=no --ignore-stdin -f --print=h POST "$postUrl"\
  'name'="$dot_name"\
  'small_descr'="$tlfbits_small_descr"\
  'descr'="$tlfbits_des"\
  'type'="$tlfbits_type"\
  'source_sel'="$tlfbits_source"\
  'standard_sel'="$tlfbits_standard"\
  'uplver'="$anonymous_tlfbits"\
  file@"${torrent_Path}"\
  "$cookie_tlfbits"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

  if [[ -z "$t_id" ]]; then
    # 辅种
    reseed_torrent
  fi
}

#-------------------------------------#
