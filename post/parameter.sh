#!/bin/bash
# FileName: post/parameter.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-09-02
#
#-------------------------------------#
# 通过之前生成的 desc 简介文档，提取其中的各种参数。
# 一次获取，多站重复使用。
# 对参数有特殊要求的站点，其规则会写到其对应的 post 文件中。
#-------------------------------------#
unset_all_parameter() {
  unset noDot_name region serials season normal documentary genre language
  unset chs_included chinese_title foreign_title imdb_url douban_url is_ipad
  unset is_bd is_hdtv is_webdl is_4k is_1080p is_720p is_other file_type mt_chs
  unset is_package is_264 is_265 is_dts is_ac3 is_aac is_flac animation theater
}
#-------------------------------------#
# 处理不规范的打包(伪complete)
complete_episode() {
  local _f_data _total _real _ep
  _real="$(grep -E '^.集　　数　.*$' "$source_desc"|grep -Eo '[0-9]+')"
  _f_data="$($tr_show "$torrent_Path"|sed '1,/FILES/d;/^ *$/d'|grep -Eo \
    'E[0-9]{1,2}'|sed 's/E0*//')" # 超过一百集的电视剧应该木有吧？
  _total="$(echo "$_f_data"|wc -l)"
  # 初略判断，如果获取失败，使用默认值 10,6
  if [[ ${_real:-10} -gt ${_total:-6} ]]; then
    _ep="$(echo "$_f_data"|awk '{if (NR==1) min=max=$1; else
    {min=min<$1?min:$1; max=max>$1?max:$1} }END{
    if (min!= max) printf("E%02d-E%02d",min,max); else printf("E%02d", min)}')"
    [[ $_ep ]] && { season="$_ep" && \
      dot_name="$(echo "$dot_name"|sed "s/Complete/$_ep/i")"; } || \
      debug_func "parameter:episode-[$_real]-[$_total]-[$_ep]"  #----debug---
      # noDot_name 后面有处理
    is_package='no' # 不是合集
  fi
  unset _f_data _total _real _ep
}
#---------------main------------------#
from_desc_get_param() {
  unset_all_parameter
  # httpie 对文件名有要求，如包含特殊字符，可能 POST 失败，只改torrent文件名。
  local pl_name_tmp="autoseed.$(date +%s%N).torrent"
  mv "$torrent_Path" "${flexget_path}/${pl_name_tmp}"
  torrent_Path="${flexget_path}/${pl_name_tmp}"
  # -e 直接修改该文件，-n 不改变hash，-c 改 comment。
  [[ $No_Headers != yes && -f "$ROOT_PATH/post/xseed" ]] && "$ROOT_PATH/post/xseed" -enc \
  'Powered by rachpt/AutoSeed. https://github.com/rachpt/AutoSeed' "$torrent_Path" 
  [[ $? -ne 0 ]] && debug_func "para:xseed[bencode unstall]!!" #----debug---

  #----------操作 desc 简介文件--------
  # 获取国家，取第一个
  region="$(grep -E '^.产　　地　.*$' "$source_desc"| \
      sed -r 's/.[产][　 ]*[地][　 ]*//'|sed -r 's![ ]*([^/ ]+).*!\1!')"
  # 剧集或者普通类别
  if [ "$(grep -E '^.集　　数　.*$' "$source_desc")" ]; then
      serials='yes'
      # 剧集季度
      season="$(echo "$dot_name"|grep -Eio '[ \.]s0?(10|20|[1-9]+).?(ep?[0-9]+)?[ \.]'| \
          sed 's/[a-z]/\u&/g;s/\.//g')"
      [[ $season ]] || \
      season="$(echo "$dot_name"|grep -Eio '[ \.]ep?[0-9]{1,3}-?(e?p?[0-9]{1,3})?[\. ]'| \
          sed 's/[a-z]/\u&/g;s/\.//g')"
      # 文件名没有集数信息，使用原简介中的集数信息
      [[ $season ]] || {
        season="$(grep -Eiom1 'Ep?[0-9]{1,2}(-Ep?[0-9]{1,2})?' "$source_desc")"
        season="${season/$'\n'*/}"
        # 对于没有 Complete 标记的补上 集数 信息
        [[ $season && ! $dot_name =~ .*[cC][oO][mM][pP][lL][eE][tT][eE].* ]] && {
           dot_name="${dot_name/2160/$season.2160}"
           dot_name="${dot_name/1080/$season.1080}"
           dot_name="${dot_name/720/$season.720}"
           dot_name="${dot_name/4[kK]/$season.4K}"; }
      }
  else
      normal='yes'
  fi
  genre="$(grep -E '^.类　　别　.*$' "$source_desc"| \
        sed -r 's/.类　　别　//;s/ //g')"
  # 是否为纪录片
  if [[ $genre =~ .*纪录片.* ]]; then
      # 纪录片
      documentary='yes'
  elif [[ $genre =~ .*动画.* ]]; then
      # 国创动漫
      animation='yes'
  else
      normal='yes'
  fi
  # 是否为剧场版
  [[ $(grep -E '^.标　　签　.*$' "$source_desc"|grep -o '剧场版') ]] && \
      theater='yes' || theater='no'
  # 语言
  language="$(grep -E '^.语　　言　.*$' "$source_desc"| \
      sed -r 's/.语　　言　//'|sed -r 's#[ ]+##g')"

  imdb_url="$(grep -Eo 'tt[0-9]{7,8}' "$source_desc"|head -1)"
  douban_url="$(grep -Eo 'https?://movie\.douban\.com/subject/[0-9]{7,8}/?' \
      "$source_desc"|head -1)"

  #----------操作 0day 名--------
  # 识别 iPad 以及视频分辨率，以及介质(BD、hdtv、web-dl)
  case "$dot_name" in
      *[IiMm][Pp][Aa][Dd]*|*iHD*)
          is_ipad='yes'
          ;;
      *)
          is_ipad='no'
          ;;
  esac
  # 介质
  case "$dot_name" in
      *[Bb][Ll][Uu][Rr][Aa][Yy]*|*[Bb][Ll][Uu]-[Rr][Aa][Yy]*|*[Bb][Dd][Rr][Ii][Pp]*)
          is_bd='yes'
          ;;
      *[Hh][Dd][Tt][Vv]*)
          is_hdtv='yes'
          ;;
      *[Ww][Ee][Bb]-[Dd][Ll]*)
          is_webdl='yes'
          ;;
      *)
          is_bd='no'
          ;;
  esac
  # 1080p or 720p ...
  case "$dot_name" in
      *2160[Pp]*|*4[Kk]*)
          is_4k='yes'
          ;;
      *1080[Pp]*)
          is_1080p='yes'
          ;;
      *1080[Ii]*)
          is_1080i='yes'
          ;;
      *720[Pp]*)
          is_720p='yes'
          ;;
      *)
          is_other='yes'
          ;;
  esac
  # 是否为合集(package|complete)
  case "$dot_name" in
      *[Cc][Oo][Mm][Pp][Ll][Ee][Tt][Ee]*)
          is_package='yes'
          complete_episode  # 处理伪合集
          ;;
      *)
          if [[ $season =~ [sS][0-9]+(-[sS][0-9]+)? ]]; then
              is_package='yes'
          else
              is_package='no'
          fi
          ;;
  esac

  # 文件格式
  if [ "$("$tr_show" "$torrent_Path"|grep -A10 'FILES'|grep -i '\.mkv')" ]; then
      file_type='MKV'
  elif [ "$("$tr_show" "$torrent_Path"|grep -A10 'FILES'|grep -i '\.mp4')" ]; then
      file_type='MP4'
  elif [ "$("$tr_show" "$torrent_Path"|grep -A10 'FILES'|grep -i '\.ts')" ]; then
      file_type='TS'
  elif [ "$("$tr_show" "$torrent_Path"|grep -A10 'FILES'|grep -i '\.avi')" ]; then
      file_type='AVI'
  else 
      file_type='其他'
  fi

  # 音频编码格式
  case "$dot_name" in
      *[Dd][Tt][Ss]*)
          is_dts='yes'
          ;;
      *[Aa][Cc]-3*)
          is_ac3='yes'
          ;;
      *[Aa][Aa][Cc]*)
          is_aac='yes'
          ;;
      *[Ff][Ll][Aa][Cc]*)
          is_flac='yes'
          ;;
  esac
  # 视频编码格式
  case "$dot_name" in
      *264*)
          is_264='yes'
          ;;
      *265*)
          is_265='yes'
          ;;
  esac

  #-------------------------------------------------------------#
  #---name for post---#
  noDot_name="$(echo "$dot_name"|sed -E \
    's/\./ /g;s/ DD2 0/ DD2.0/i;s/ H 26/ H.26/i;s/([^0-9]5) 1/\1.1/;s/([^0-9]7) 1/\1.1/')"

  # 添加额外信息  ---1
  chs_included="$(grep '&extra_comment&' "$source_desc"|sed 's/&extra_comment&//')"
  # 中文字幕  ---2
  [[ "$(grep -i "CH[ST]" "$source_desc")" ]] && {
      chs_included="${chs_included:-中文字幕}"
      mt_chs=1; }
  # 剧集集数信息  ---3
  [[ ! $chs_included && $serials = yes ]] && chs_included="$season"
  # 删除
  sed -i '/&extra_comment&/d' "$source_desc"

  # 中文名
  chinese_title="$(grep '&shc_name_douban&' "$source_desc"| \
      sed 's/&shc_name_douban&//')"

  # 英文名
  foreign_title="$(grep '&eng_name_douban&' "$source_desc"| \
      sed 's/&eng_name_douban&//')"

  # 删除 简介中的中英文名
  #sed -i '/&shc_name_douban&/d;/&eng_name_douban&/d' "$source_desc"
}

#-------------------------------#

