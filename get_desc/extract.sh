#!/bin/bash
# FileName: get_desc/extract.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-08-22
#
#-------------------------------------#
# 提取rar分卷压缩种子，并制作种子文件。
# unrar 需要在环境变量中。
#-------------------------------------#

extract_rar_files() {
if [[ "$(find "${Tr_Path%/}/${Torrent_Name}" -type f -iname "*.r[a01][r0-9]"|wc -l)" -gt 5 ]]; then
  unrar e -o- -inul "${Tr_Path%/}/${Torrent_Name}/*.rar" "${Tr_Path%/}/${Torrent_Name}" 
  if [[ $? -eq 0 || $? -eq 10 ]]; then
    # make dot torrent file, 10 means the files to extract already exist 
    \rm -f "${flexget_path%/}/${Torrent_Name}.torrent"
    $dottorrent -t "https://iptorrents.com" -s 4M -p -x '*.rar' -x '*.r[0-9]*' -x '*.sfv' \
      -x '.*' -c "Powered by rachpt/AutoSeed. https://github.com/rachpt/AutoSeed" \
      "${Tr_Path%/}/${Torrent_Name}" "${flexget_path%/}/${Torrent_Name}.torrent"
    [[ $? -ne 0 ]] && debug_func 'extract: failed to make .torrent file!'
  else
    debug_func 'extract: failed to unrar!'
  fi
fi
}

