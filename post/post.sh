#!/bin/bash
# FileName: post/post.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-10-23
#
#---get desc---#
source "$AUTO_ROOT_PATH/get_desc/desc.sh"
source "$AUTO_ROOT_PATH/post/parameter.sh"

#-------------------------------------#
judge_before_upload() {
    up_status=1    # judge code
    #---judge to get away from dupe---#
    [ "$postUrl" = "https://whu.pt/takeupload.php" ] && source "$AUTO_ROOT_PATH/post/judge.sh"
    [ "$postUrl" = "https://nanyangpt.com/takeupload.php" ] && source "$AUTO_ROOT_PATH/post/judge.sh"
    #---necessary judge---# 
    if [ "$(egrep '禁止转载|禁转|情色' "$source_detail_desc")" ]; then
        up_status=0  # give up upload
        echo "禁转禁发资源" >> "$log_Path"
    fi
    t_id=''        # set t_id to none
    #---post---#
    if [ "$up_status" = "1" ]; then
        #---log---#
        echo "+++++++++++[post data]+++++++++++" >> "$log_Path"
        echo -e "name=${dot_name}\
            \nsmall_descr=${smallDescr}\
            \nimdburl=${imdbUrl}\
            \nuplver=${anonymous}\
            \n${postUrl%/*}\
            \n${source_site_URL}" >> "$log_Path"
    fi
}

add_t_id_2_transmission() {        
    #---if get t_id then add it to tr---#
    if [ -z "$t_id" ]; then
        echo "++++++[failed to get tID]++++++++" >> "$log_Path"
    else
        echo t_id: [$t_id] >> "$log_Path"
        #---add torrent---#
        download_url="${site_download_url}${t_id}"
        source "$AUTO_ROOT_PATH/post/add.sh"
    fi
    unset t_id
}
#-------------------------------------#
unset_tempfiles() {
    rm -f "$source_detail_desc" "$source_detail_html" "$source_detail_desc2tjupt"
    unset source_detail_desc source_detail_html source_detail_desc2tjupt
    echo "++++++++++[deleted tmp]++++++++++" >> "$log_Path"
}

#----------call function--------------#
judge_before_upload

if [ "$enable_hudbt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/hudbt.sh"
    add_t_id_2_transmission
fi

if [ "$enable_whu" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/whu.sh"
    add_t_id_2_transmission
fi

if [ "$enable_npupt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/npupt.sh"
    add_t_id_2_transmission
fi

if [ "$enable_nanyangpt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/nanyangpt.sh"
    add_t_id_2_transmission
fi

if [ "$enable_byrbt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/byrbt.sh"
    add_t_id_2_transmission
fi

if [ "$enable_cmct" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/cmct.sh"
    add_t_id_2_transmission
fi

if [ "$enable_tjupt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/tjupt.sh"
    add_t_id_2_transmission
fi
#-------------unset-------------------#

unset_tempfiles

