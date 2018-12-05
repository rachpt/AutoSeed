#!/bin/bash
# FileName: post/post.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-05
#
#---------------------------------------#
# 将简介以及种子以post方式发布
#---------------------------------------#
#---get desc---#
source "$ROOT_PATH/get_desc/desc.sh"    # get source site
source "$ROOT_PATH/post/parameter.sh"
source "$ROOT_PATH/post/judge.sh"
#---------------------------------------#
judge_before_upload() {
    up_status=1    # judge code
    #---judge to get away from dupe---#
    [ "$postUrl" = "${post_site[whu]}/takeupload.php" ] && \
        judge_torrent_func
    [ "$postUrl" = "${post_site[nanyangpt]}/takeupload.php" ] && \
        judge_torrent_func
    #---necessary judge---# 
    if [ "$(grep -E '禁止转载|禁转|情色' "$source_desc")" ]; then
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
            \nimdburl=${imdb_url}\
            \nuplver=${anonymous}\
            \n${postUrl%/*}\
            \n${source_site_URL}"                >> "$log_Path"
    fi
}

add_t_id_2_client() {        
    #---if get t_id then add it to tr---#
    if [ -z "$t_id" ]; then
        echo "++++++[failed to get tID]++++++++" >> "$log_Path"
    else
        echo t_id: [$t_id]                       >> "$log_Path"
        #---add torrent---#
        torrent2add="${downloadUrl}${t_id}&passkey=${passkey}"
        source "$ROOT_PATH/post/add.sh"
    fi
    unset t_id
}
#---------------------------------------#
unset_tempfiles() {
    #rm -f "$source_desc" "$source_html" "$source_desc2tjupt"
    unset source_desc source_html source_desc2tjupt
    unset douban_poster_url source_site_URL source_t_id imdb_url
    echo "++++++++++[deleted tmp]++++++++++"     >> "$log_Path"
}

#----------call function--------------#

if [ "$enable_hudbt" = 'yes' ]; then
    judge_before_upload
    source "$ROOT_PATH/post/hudbt.sh"
    add_t_id_2_client
fi

if [ "$enable_whu" = 'yes' ]; then
    judge_before_upload
    source "$ROOT_PATH/post/whu.sh"
    add_t_id_2_client
fi

if [ "$enable_npupt" = 'yes' ]; then
    judge_before_upload
    source "$ROOT_PATH/post/npupt.sh"
    add_t_id_2_client
fi

if [ "$enable_nanyangpt" = 'yes' ]; then
    judge_before_upload
    source "$ROOT_PATH/post/nanyangpt.sh"
    add_t_id_2_client
fi

if [ "$enable_byrbt" = 'yes' ]; then
    judge_before_upload
    source "$ROOT_PATH/post/byrbt.sh"
    add_t_id_2_client
fi

if [ "$enable_cmct" = 'yes' ]; then
    judge_before_upload
    source "$ROOT_PATH/post/cmct.sh"
    add_t_id_2_client
fi

if [ "$enable_tjupt" = 'yes' ]; then
    judge_before_upload
    source "$ROOT_PATH/post/tjupt.sh"
    add_t_id_2_client
fi
#-------------unset-------------------#

unset_tempfiles

#---------------------------------------#
