#!/bin/bash
# FileName: get_desc/desc.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-08
#
#-------------------------------------#
# 调函数，生成简介
# 提前生成简介，post，重编辑会用到该文件
#-------------------------------------#
# 最后发布前会再次重命名为简单的名字减少莫名其妙的bug。
# dot_name即点分隔名，用作 0day 名，以及构成保存简介文件名。
if [ "$(echo "$org_tr_name"|sed 's/[a-z0-9 ]*[[:punct:]]*//ig')" ]; then
    #---special for non-standard 0day-name---#
    dot_name="$("$tr_show" "$torrent_Path"|grep -A10 'FILES'|grep -Ei '[\.0-9]+[ ]*(GB|MB)'|grep -Eio "[-\.\'a-z0-9\!@_ ]+"|tail -2|head -1|sed -r 's/^[\. ]+//;s/\.[a-z4 ]{2,5}$//i'|sed -r 's/\.sample//i;s/[ ]+/./g')"
else
    # remove suffix name
    dot_name="$(echo "$org_tr_name"|sed -Ee "s/[ ]+/./g;s/\.[a-z4]{2,3}$//i")"
fi

source_desc="${ROOT_PATH}/tmp/${org_tr_name}_desc.txt"
# byrbt, html format
[ "$enable_byrbt" = 'yes' ] && \
    source_html="${ROOT_PATH}/tmp/${org_tr_name}_html.txt"

#---to log and edit.sh---#
if [ -z "$source_site_URL" ]; then
    get_source_site            # get_desc/detail_page.sh
else
    set_source_site_cookie     # get_desc/detail_page.sh
fi

#---if not exist desc file---#
if [ ! -s "$source_desc" ]; then
    # 尝试搜索原种简介，以获取 iNFO 以及 screens
    form_source_site_get_Desc  # get_desc/detail_page.sh
    # generate info? 
    if [ ! -s "$source_desc" ]; then
        # import functions
        source "$ROOT_PATH/get_desc/info.sh"
        read_info_file         # get_desc/info.sh
    fi
    # import functions to generate desc
    source "$ROOT_PATH/get_desc/generate.sh"
    generate_main_func         # get_desc/generate.sh
    #---screens---#
    if [ "$enable_byrbt" = 'yes' ]; then
        source "$ROOT_PATH/get_desc/screens.sh"
        deal_with_byrbt_images     # get_desc/screens.sh
    fi

fi
#-------------------------------------#

