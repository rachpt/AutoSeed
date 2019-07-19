#!/bin/bash
# FileName: get_desc/desc.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-07-14
#
#-------------------------------------#
# 调函数，生成简介
# 提前生成简介，post，重编辑会用到该文件
#-------------------------------------#
# 最后发布前会再次重命名为简单的名字减少莫名其妙的bug。
# dot_name即点分隔名，用作 0day 名，以及构成保存简介文件名。
dot_name="$(echo "$org_tr_name"|sed 's/[^ -z]//g')"    # 删除所有汉字
debug_func "desc:dot-name.0[$dot_name]"     #----debug---
# name 包含10个以上英文字符，则使用其作为0day名，否则使用部分主文件名
if [[ $(echo "$dot_name"|sed 's/[\. 0-9]//g'|awk '{print length($0)}') -lt 10 ]]; then
  #---special for non-standard 0day-name---#
  dot_name="$("$tr_show" "$torrent_Path"|grep -A10 'FILES'| \
    grep -Ei '[\.0-9]+[ ]*(GB|MB)'|grep -Eio "[-\.\'a-z0-9\!@_ ]+"|tail -2| \
    head -1|sed -r 's/^[\. ]+//;s/\.[a-z4 ]{2,5}$//i'| \
    sed -r 's/\.sample//i;s/[ ]+/./g')" && \
    debug_func "desc:dot-name.2[$dot_name]"  #----debug---
else
  # remove suffix name
  dot_name="$(echo "$dot_name"|sed -E 's/[ ]+/./g;s/\.{2,}/./g;s/\.[a-z4]{2,4}$//i;;s/^\.//')"
  debug_func "desc:dot-name.1[$dot_name]"    #----debug---
fi

# 导入自定义规则
my_dupe_rules                 # get_desc/customize.sh
source_desc="${ROOT_PATH}/tmp/${org_tr_name}_desc.txt"
# byrbt, html format
[ "$enable_byrbt" = 'yes' ] && \
  source_html="${ROOT_PATH}/tmp/${org_tr_name}_html.txt"
# tjupt, deal with images
[ "$enable_tjupt" = 'yes' ] && \
  source_desc2tjupt="${ROOT_PATH}/tmp/${org_tr_name}_desc2tjupt.txt"

#---to log and edit.sh---#
if [[ -z "$source_site_URL" ]]; then
  get_source_site                   # get_desc/detail_page.sh
  debug_func "desc:get-site[$source_site_URL][$s_site_uid]"  #----debug---
else
  set_source_site_cookie            # get_desc/detail_page.sh
  debug_func 'desc:get-site-cookie'             #----debug---
fi
# 使用预先编辑报的简介，将不会再尝试生成info
[[ ! -s "$source_desc" ]] && \
  match_douban_desc                   # get_desc/match.sh
#---if not exist desc file---#
if [ ! -s "$source_desc" ]; then
    debug_func 'desc:no-source-info'  #----debug---
    # 尝试搜索原种简介，以获取 iNFO 以及 screens
    form_source_site_get_Desc         # get_desc/detail_page.sh
    # generate info? 
    if [ ! -s "$source_desc" ]; then
        [[ $completion -ge 92 ]] && {
        # import functions
        debug_func 'desc:info'        #----debug---
        [[ `type -t read_info_file` != "function" ]] && \
          source "$ROOT_PATH/get_desc/info.sh"
        read_info_file; }             # get_desc/info.sh
    fi
    if [ -s "$source_desc" ]; then
        # set source site torrent's ratio, only once
        [[ $fg_client = qbittorrent && $s_site_uid ]] && \
        echo -e "${org_tr_name}\n${trackers[$s_site_uid]}\n`eval echo \
          '$'ratio_$s_site_uid`" >> "$qb_rt_queue"
        # import functions to generate desc
        #------------match imdb/douban url----------#
        debug_func 'desc:match'       #----debug---
        match_douban_imdb "$dot_name"  # get_desc/match.sh
        match_douban_imdb "$org_tr_name"  # get_desc/match.sh
        #-----------use python/api gen desc---------#
        debug_func 'desc:generate'    #----debug---
        [[ `type -t generate_main_func` != "function" ]] && \
          source "$ROOT_PATH/get_desc/generate.sh"
        generate_main_func            # get_desc/generate.sh
        #-----------------screens-------------------#
        if [[ $enable_byrbt = yes || $enable_tjupt = yes ]]; then
          debug_func 'desc:screens'   #----debug---
          [[ `type -t deal_with_images` != "function" ]] && \
            source "$ROOT_PATH/get_desc/screens.sh"
          deal_with_images            # get_desc/screens.sh
          debug_func 'desc:out'       #----debug---
        fi
    fi
else
    # 保险起见，检查已经生成的简介
    if [[ $enable_byrbt = yes && $(grep -Eo "src=[\"\']http[^\'\"]+" \
      "$source_html"|sed "/bt\.byr\.cn/d") ]]; then
        [[ `type -t deal_with_images` != "function" ]] && \
          source "$ROOT_PATH/get_desc/screens.sh"
        deal_with_images              # get_desc/screens.sh
        debug_func 'desc-byr-pic-pass2'  #----debug---
    fi
fi
#-------------------------------------#

