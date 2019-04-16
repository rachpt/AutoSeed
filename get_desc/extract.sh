#!/bin/bash
# FileName: get_desc/extract.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-04-16
#
#-------------------------------------#
# 提取rar分卷压缩种子，并制作种子文件。
# unrar 需要在环境变量中。
#-------------------------------------#

extract_rar_files() {
if [[ "$(find "${Tr_Path}/${Torrent_Name}" -type f -iname "*.rar")" ]]; then
  hold_on # main.sh, sleep some time
  unrar e "${Tr_Path}/${Torrent_Name}/*.rar" "${Tr_Path}/${Torrent_Name}" 
  if [[ $? -eq 0 ]]; then
    # make dot torrent file
    \rm -f "${flexget_path}/${Torrent_Name}.torrent"
    dottorrent -t "https://iptorrents.com" -s 4M -p -x '*.rar' -x '*.r[0-9]*' -x '*.sfv' \
      -c "Powered by rachpt/AutoSeed. https://github.com/rachpt/AutoSeed" \
      "${Tr_Path}/${Torrent_Name}" "${flexget_path}/${Torrent_Name}.torrent"
    [[ $? -ne 0 ]] && debug_func 'extract: failed to make .torrent file!'
  else
    debug_func 'extract: failed to unrar!'
  fi
fi
}

