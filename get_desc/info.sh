#!/bin/bash
# FileName: get_desc/info.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2020-01-07
#
#-------------------------------------#
# 复制 nfo 文件内容至简介，如果没有 nfo 文件，
# 则采用 mediainfo 生成主文件的编码信息至临时文件。
# 自动判断 是否有 nfo 文件，以及 nfo 文件是否下载完成。
#-------------------------------------#
#
# 使用 ffmpeg 生成视频缩略图
gen_thumbnail_with_ffmpeg() {
  local step total file size ratio row column
  screen_file="${ROOT_PATH}/tmp/autoseed-$(date '+%s%N').jpg"
  file="$max_size_file"
  size=512  # 单个缩略图宽 512 pix，最好16的倍数
  row=4     # 行数
  column=3  # 列数
  ratio="$($mediainfo "$file" --Output="Video;%FrameRate%")"
  total="$($mediainfo "$file" --Output="Video;%FrameCount%")"
  # 首末去掉 1500 帧，等分
  step=$(bc <<< "($total - 3000)/(($row * $column) * $ratio)")
  for ((i=1;i<=(row * column);i++)); do
    # 多线程
    ( $ffmpeg -ss "$(bc <<< "(1500/$ratio)+($step * $i)")" -i "$file" -vframes 1 \
    -vf "scale=$size:-1" "${ROOT_PATH}/tmp/thumbnail-$(printf "%03d" $i).jpg" -y 2>/dev/null ) &
  done
  wait # 等待所有 截图完成
  $ffmpeg -i "${ROOT_PATH}/tmp/thumbnail-%03d.jpg" -filter_complex \
    "tile=3x4:nb_frames=0:padding=5:margin=5:color=random" "$screen_file" -y 2>/dev/null
  [[ $? -ne 0 ]] && debug_func "info:ffmpeg-have-failed!!!"  #----debug---
  \rm -f "${ROOT_PATH}/tmp"/thumbnail-[0-9]*.jpg # 通配符，不能使用引号包裹
}
# 使用 mtn 生成视频缩略图，http://moviethumbnail.sourceforge.net/
gen_thumbnail_with_mtn() {
  local _file _font _inf
  # 处理可能意外遗留的缩略图
  [[ "$(ls "${ROOT_PATH}/tmp/"*-autoseed.jpg 2> /dev/null)" ]] && {
    [[ -d "${ROOT_PATH}/tmp/old" ]] || mkdir -p "${ROOT_PATH}/tmp/old"
    \mv -f "${ROOT_PATH}/tmp/"*-autoseed.jpg "${ROOT_PATH}/tmp/old"; }

  _file="$max_size_file" # 截图文件，可以是路径
  _font="${ROOT_PATH}/get_desc/font/cyberbit.ttf" # 字体文件，兼顾中英文
  _inf="Powered by rachpt/Autoseed (https://github.com/rachpt/AutoSeed)"
  # 参数说明： -g 8小图间隔8pix，--shadow=3阴影3pix，-H文件大小友好显示
  #   -B 180 跳过开头3min，-D 12 边缘检测，-b 0.8 全黑最大80%
  #   -T 自定义文字，-w 图片宽度，-c column -r row -k 背景色 -L info和时间位置
  #   -F info和时间戳字体和大小等，-o 后缀名 -f info字体 -O 输出路径dir
  # 详细：http://moviethumbnail.sourceforge.net/usage.en.html
  $mtn -g 8 --shadow=3 -H -B 180 -D 12 -b 0.8 -T "$_inf" -w 1568 -c 3 -r 4 -k 000000 -L 4:2 \
    -F FFFF00:18:"$_font":ff0000:000000:24 -o '-autoseed.jpg' -f "$_font" \
    "$_file" -O "${ROOT_PATH}/tmp"
  [[ $? -eq 0 ]] && {
    screen_file="$(Listf "${ROOT_PATH}/tmp" '-autoseed.jpg')"
    [[ "$(count "${ROOT_PATH}/tmp/"*-autoseed.jpg)" -gt 1 ]] && \
      debug_func "info-mtn-生成了多张!!但是只会使用一张"
    screen_file="${screen_file/$'\n'*}" # 取第一张
    # 文件名包含特殊字符
    [[ $screen_file =~ ^[-/0-9a-zA-Z\._]+$ ]] || {
      local screen_file_old="$screen_file" # 临时旧文件名
      screen_file="${ROOT_PATH}/tmp/autoseed-$(date '+%s%N').jpg"
      \mv -f "$screen_file_old" "$screen_file"; }
  } || { debug_func "info:mtn-have-failed!!!"; }
}
#-------------------------------------#
# 读取主文件以获得info，提前生成简介将失效
generate_info_local() {
  local main_file_dir _file_l max_size_file info_gen_desc info_gen_html
  local _ext_desc _ext_html
  # ; } || { , the semicolon is essential!
  [[ $No_Headers != yes ]] && {
  _ext_desc="[b]以下是[url=https://github.com/rachpt/AutoSeed] [img]\
https://s2.ax1x.com/2019/05/04/Ea3qbQ.png[/img] [/url]自动完成的截图，不喜勿看。[/b]"
  _ext_html="<br /><br /><stong>以下是 <a \
href=\"https://github.com/rachpt/AutoSeed\"><img alt=\"AutoSeed\" \
src=\"https://bt.byr.cn/ckfinder/userfiles/images/autoseed.png\" \
style=\"width: 64px; height: 22px;\" /></a> \
自动完成的截图，不喜勿看。</strong><br />"; } || {
  _ext_desc="[b]以下是 [img]\
https://s2.ax1x.com/2019/05/04/Ea3qbQ.png[/img] 自动完成的截图，不喜勿看。[/b]"
  _ext_html="<br /><br /><stong>以下是 <img alt=\"AutoSeed\" \
src=\"https://bt.byr.cn/ckfinder/userfiles/images/autoseed.png\" \
style=\"width: 64px; height: 22px;\" /> 自动完成的截图，不喜勿看。</strong><br />"; }

  # 种子文件绝对路径
  main_file_dir="${one_TR_Dir}/${one_TR_Name}"
  debug_func "info:folder-dir[$main_file_dir]"  #----debug---
  #---使用 mediainfo 生成种子中体积最大文件的 iNFO---#
  _file_l="$(find "$main_file_dir" -type f -exec stat -c "%Y-%s %n" {} \;)"
  # 43200s 12小时，在修改时间12小时中找体积最大的文件
  max_size_file="$(echo "$_file_l"|awk -F - -v t=`date +%s` '{if ($1>(t-43200)) print}' \
    |sed -E 's/^[0-9]+-//'|sort -nr|sed -E 's/^[0-9 ]+//;q')"
  # 如果没有符合要求的文件，则选一个体积最大的文件
  [[ "$max_size_file" ]] || \
  max_size_file="$(echo "$_file_l"|sed -E 's/^[0-9]+-//'|sort -nr|sed -E 's/^[0-9 ]+//;q')"
  debug_func "info:max-file-path[$max_size_file]"  #----debug---
  #---本地简介大小为零，-s 大小不为零，! 取反---#
  if [[ ! -s "$source_desc" ]]; then
    info_gen_desc="$($mediainfo "$max_size_file"|sed "s%${one_TR_Dir}/%%"|sed \
      '/Unique/d;/Encoding settings/d;/Writing library/d;/Writing application/d')"
    [[ $enable_byrbt == yes ]] && \
    info_gen_html="$($mediainfo --Output=HTML "$max_size_file"|sed \
    "s%${one_TR_Dir}/%%"|sed '/html>/d;/body>/d;/head>/d;/<META/d')"
  else
    info_gen_desc="$(< "$source_desc")"
    [[ $enable_byrbt == yes ]] && \
    info_gen_html="$(echo "$info_gen_desc"|sed 's/ /\&nbsp; /g;s!$!&<br />!g')"
  fi
  # 缩略图
  unset img_url_com img_url_byr screen_file # clean
  local screen_file
  if command -v $mtn &> /dev/null; then
      gen_thumbnail_with_mtn # 使用 mtn 生成缩略图
  fi
  [[ -s "$screen_file" ]] || gen_thumbnail_with_ffmpeg # 使用 ffmpeg 生成缩略图
  # 图片上传 img_url_com  img_url_byr
  [[ -s "$screen_file" ]] && {
    upload_image_com "$screen_file"  # static.sh
    [[ $enable_byrbt == yes ]] && upload_image_byrbt "$screen_file"
    # delete image if upload successed
    [[ "$img_url_com" || "$img_url_byr" ]] && \rm -f "$screen_file"
    } || debug_func "info:生成缩略图失败!!!"  #----debug---

  # 存档
  [[ "$img_url_com" ]] && \
    printf '%s\n\n%s\n%s\n%s\n' "${info_gen_desc}" "${_ext_desc}" \
      "${max_size_file##*/}" "[img]$img_url_com[/img]" > "$source_desc"
  # byrbt desc to html
  [[ $enable_byrbt == yes ]] && { \
    [[ "$info_gen_html" ]] && {
    printf '%s\n\n%s\n%s\n%s\n' "${info_gen_html}" "${_ext_html}" \
    "<br />${max_size_file##*/}<br />" \
    "<img src=\"$img_url_byr\" style=\"width: 900px;\" /><br />" > "$source_html" 
    } || { printf '%s\n' "$info_gen_html" > "$source_html"; }; }
  unset img_url_com img_url_byr screen_file # clean
}

#---------------main------------------#
# 首先判断是否有 nfo 文件，以及nfo是否下载完成
read_info_file() {
  [[ "$org_tr_name" == "$tr_name_hand" ]] && one_TR_Dir="$tr_path_hand"
  debug_func "info:one_TR_Dir.0[$one_TR_Dir]"  #----debug---
  if [[ ! "$one_TR_Dir" ]]; then
      one_TR_Dir="$(find "$default_FILE_PATH" -name \
          "$one_TR_Name" 2> /dev/null|head -1)"
      one_TR_Dir="${one_TR_Dir%/*}"
      debug_func "info:one_TR_Dir.1[$one_TR_Dir]"  #----debug---
  fi

  if [[ "$one_TR_Dir" ]]; then
    local nfo_count
    [[ $one_TR_Dir =~ .*/$ ]] && one_TR_Dir=${one_TR_Dir%/} # move slash end
    nfo_count=$("$tr_show" "$torrent_Path"|grep -Eic '\.nfo \([0-9\. ]+[kb]+\)')
    if [[ $nfo_count -eq 1 ]]; then
      local nfo_file_size nfo_file_path nfo_file_downloaded
      nfo_file_size=$("$tr_show" "$torrent_Path"| \
        grep -Eio '\.nfo \([0-9\. ]+[kb]+\)'|grep -Eo '[0-9]+\.?[0-9]*')
      if [[ $nfo_file_size ]]; then
        nfo_file_path="$(find "${one_TR_Dir}/${one_TR_Name}" -iname '*.nfo'|head -1)"
        nfo_file_downloaded=$(stat --format=%s "$nfo_file_path")
        if [[ $nfo_file_downloaded ]]; then
          local judge_download_nfo judge_nfo_file charset
          judge_download_nfo=$((nfo_file_downloaded/100)) # $(())中变量可以不要$
          judge_nfo_file=$(bc <<< "$nfo_file_size * 10"|awk -F '.' '{print $1}')
          [[ "$judge_download_nfo" -eq  "$judge_nfo_file" ]] && {
            charset="$(file -i "$nfo_file_path"|sed 's/.*charset=//')"
            [[ $charset ]] || charset='iso-8859-1'
            [[ $charset == 'binary' ]] && charset='IBM866'
            iconv -f "$charset" -t UTF-8 -c "$nfo_file_path" > "$source_desc"
            debug_func 'info:[one nfo file]use-nfo-file'; }  #----debug---
        fi
      else
        # 有一个nfo并且nfo未下载完成，使用主文件生成nfo信息
        debug_func 'info:[one nfo file]use-main-file-gen!'  #----debug---
        # gen from main file and gen screens
        [[ $only_tlfbits = 'yes' ]] || generate_info_local
      fi
    elif [[ $nfo_count -ge 2 ]]; then
      # 对于有多个nfo的种子，使用文件列表代替 nfo
      "$tr_show" "$torrent_Path"|sed '1,/FILES/d;/^ *$/d;\#https?://#d' > "$source_desc"
      debug_func 'info:[mult nfo file]use-file-lists'  #----debug---
    else
      # 对于没有 nfo 文件的种子
      # gen from main file and gen screens
      debug_func 'info:[no nfo file]use-main-file-gen'  #----debug---
      [[ $only_tlfbits = 'yes' ]] || generate_info_local
    fi
  fi
  debug_func 'info:exit'  #----debug---
}

#-------------------------------------#

