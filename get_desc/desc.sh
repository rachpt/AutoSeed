#!/bin/bash
# FileName: get_desc/desc.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-10-22
#
#-------------------------------------#
# 调函数，生成简介
#-------------------------------------#

source_detail_desc="${AUTO_ROOT_PATH}/tmp/${dot_name}_desc.txt"
# byrbt
[ "$enable_byrbt" = 'yes' ] && source_detail_html="${AUTO_ROOT_PATH}/tmp/${dot_name}_html.txt"
# import functions
source "$AUTO_ROOT_PATH/get_desc/detail_page.sh"
# 图片上传 API
upload_poster_api='https://sm.ms/api/upload'
upload_poster_api_byrbt='https://bt.byr.cn/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Images'

#---to log and edit.sh---#
if [ -z "$source_site_URL" ]; then
    get_source_site          # get_desc/detail_page.sh
else
    set_source_site_cookie   # get_desc/detail_page.sh
fi

#---if not exist desc file---#
if [ ! -s "$source_detail_desc" ]; then
    # 尝试搜索原种简介，以获取 iNFO 以及 screens
    detail_main_func         # get_desc/detail_page.sh
    
    if [ ! -s "$source_detail_desc" ]; then
        # import functions
        source "$AUTO_ROOT_PATH/get_desc/info.sh"
        read_info_file       # get_desc/info.sh
    fi
    # import functions generate desc
    source "$AUTO_ROOT_PATH/get_desc/generate.sh"
    generate_main_func       # get_desc/generate.sh

fi

#---screens---#
if [ "$enable_byrbt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/get_desc/screens.sh"
    deal_with_byrbt_images   # get_desc/screens.sh
fi

